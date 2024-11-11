MODULE RuntimeErrors;
(**
  Oberon RTK Framework v2
  --
  Exception handling: run-time errors and faults
  Multi-core
  --
  Error: run-time errors, including ASSERT, triggered by SVC calls
  Fault: hardware faults, triggered by MCU
  --
  MCU: RP2040
  --
  Note, no printing is done here, since we don't know if there's
  even a terminal connected out in the wild, and if there's an
  operator seeing the messages. All error and fault data is collected,
  and passed to an installable handler, which then can print, or just log
  (or both), or take autonomous corrective actions, such as a restart.

  See module RuntimeErrorsOut for a corresponding handler and print
  functions.
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  Portions copyright (c) 2008-2023 CFB Software, https://www.astrobe.com
  Used with permission.
  Please refer to the licensing conditions as defined at the end of this file.
**)

  IMPORT
    SYSTEM, LED, MCU := MCU2, Config, Memory;

  CONST
    NumCores* = Config.NumCores;
    TraceDepth* = 7;
    MoreTracePoints* = -1;
    StackTraceNotLR = 0;
    StackTraceLineNo = 1;
    StackTraceNoLineNo = 2;
    ErrorLed = LED.Pico;

    (* stacked registers sizes and offsets from r0 *)
    StateContextSize = 32;
    PSRoffset = 28;
    PCoffset = 24;

    (* register numbers *)
    SP = 13;
    LR = 14;
    PC = 15;

  (*
    offsets if handler is compiled as normal procedure:
    +36 +52   lower end of stack frame of interrupted proc with stack alignment
    +32 +48   lower end of stack frame of interrupted proc without stack alignment
        from here down, stacked by hardware (8 words)
    +28 +44   xPSR
    +24 +40   PC  = handler return address
    +20 +36   LR  = interrupted procs's LR
    +16 +32   R12
    +12 +28   R3
    +8  +24   R2
    +4  +20   R1
     0  +16   R0 <= stackFrameAddr
        from here down, pushed by handler prologue
        +12   LR  = EXC_RETURN
        +8    local var of handler
        +4    local var of handler
        SP => local var of handler
  *)

    (* EXC_RETURN bits *)
    EXC_RET_Mode  = 3;  (* = 1: thread mode, faulty code was running in thread mode *)
    EXC_RET_SPSEL = 2;  (* = 1: PSP used for stacking *)


  TYPE
    TracePoint* = RECORD
      address*: INTEGER;
      lineNo*: INTEGER
    END;

    Trace* = RECORD
      tp*: ARRAY TraceDepth + 1 OF TracePoint;
      count*: INTEGER
    END;

    StackedRegisters* = RECORD
      r0*, r1*, r2*, r3*, r12*: INTEGER;
      lr*, pc*, xpsr*, sp*: INTEGER
    END;

    CurrentRegisters* = RECORD
      sp*, lr*, pc*, xpsr*: INTEGER
    END;

    (* note/todo: depending on the final design decision, 'StackedRegisters'
    and 'CurrentRegisters' can be put into 'ExceptionRec' *)

    ExceptionRec* = RECORD
      code*: INTEGER;
      core*: INTEGER;
    END;

    FaultRec* = RECORD(ExceptionRec)
      address*: INTEGER;
      stackedRegs*: StackedRegisters;
      currentRegs*: CurrentRegisters
    END;

    ErrorRec* = RECORD(ExceptionRec)
      trace*: Trace;
      stackedRegs*: StackedRegisters;
      currentRegs*: CurrentRegisters
    END;

    Exception = RECORD
      faultRec: FaultRec;
      errorRec: ErrorRec;
      handleException: PROCEDURE(cpuId: INTEGER; er: ExceptionRec);
      haltOn, stackTraceOn, stackedRegsOn, currentRegsOn: BOOLEAN
    END;

    ExceptionHandler* = PROCEDURE(cpuId: INTEGER; er: ExceptionRec);


  VAR
    exc: ARRAY NumCores OF Exception;

  (* IMPORTANT: if the error/fault handler does not HALT, 'handleException' has to set an
  appropriate exception return address on the stack to continue in a reasonable way. *)

  PROCEDURE* HALT(cid: INTEGER);
  BEGIN
    IF exc[cid].haltOn THEN
      REPEAT UNTIL FALSE
    END
  END HALT;

  (* --- Astrobe code begin --- *)

  PROCEDURE getHalfWord(addr: INTEGER; VAR value: INTEGER);
  (* from Astrobe library, modified *)
  (* get 16-bit data from an address that is possibly not word-aligned *)
    VAR b1, b2: BYTE;
  BEGIN
    SYSTEM.GET(addr + 1, b1);
    SYSTEM.GET(addr, b2);
    value := LSL(b1, 8) + b2
  END getHalfWord;

  PROCEDURE isBL(codeAddr: INTEGER): BOOLEAN;
  (* from Astrobe library *)
  (* check if the instruction at 'codeAddr' is a BL instruction *)
    VAR instr: INTEGER;
  BEGIN
    getHalfWord(codeAddr, instr);
    RETURN BFX(instr, 15, 11) = 01EH
  END isBL;

  PROCEDURE isBLX(codeAddr: INTEGER): BOOLEAN;
  (* from Astrobe library *)
  (* check if the instruction at 'codeAddr' is a BLX instruction *)
    VAR instr: INTEGER;
  BEGIN
    getHalfWord(codeAddr, instr);
    RETURN (BFX(instr, 15, 7) = 08FH) & (BFX(instr, 2, 0) = 0)
  END isBLX;

  PROCEDURE getNextLR(stackAddr: INTEGER; VAR lr, res: INTEGER);
  (* from Astrobe library. modified *)
  (* Check if the value at 'stackAddr' on the stack is a link register address.
  If yes, it will point to a code address (+1 for thumb mode) which
  is preceded by a BL or BLX instruction. *)
    VAR nextInstr: INTEGER;
  BEGIN
    res := StackTraceNotLR;
    SYSTEM.GET(stackAddr, lr);
    (* must be Thumb mode *)
    IF ODD(lr) THEN
      DEC(lr);
      IF (lr >= Config.CodeStart) & (lr < Config.CodeEnd) THEN
        IF isBL(lr - 4) OR isBLX(lr - 2) THEN
          getHalfWord(lr, nextInstr);
          (* if stack trace is enabled there should be a B,0 instruction (0E0000H)
          that skips the line number after the BL instruction *)
          IF nextInstr = 0E000H THEN
            res := StackTraceLineNo
          ELSE
            res := StackTraceNoLineNo
          END
        END
      END
    END
  END getNextLR;

  (* --- Astrobe code end --- *)


  PROCEDURE Stacktrace*(stackAddr: INTEGER; VAR trace: Trace);
    VAR
      lr, x, res: INTEGER;
      tp: TracePoint;
  BEGIN
    SYSTEM.GET(stackAddr, x);
    WHILE (stackAddr # x) & (trace.count < TraceDepth) DO
      getNextLR(stackAddr, lr, res);
      IF res > StackTraceNotLR THEN
        tp.address := lr - 4;
        IF res = StackTraceLineNo THEN
          getHalfWord(lr + 2, tp.lineNo)
        ELSE
          tp.lineNo := 0
        END;
        trace.tp[trace.count] := tp;
        INC(trace.count)
      END;
      INC(stackAddr, 4);
      SYSTEM.GET(stackAddr, x)
    END;
    IF trace.count = TraceDepth THEN
      trace.tp[TraceDepth].address := MoreTracePoints
    END
  END Stacktrace;


  PROCEDURE extractError(stackFrameBase: INTEGER; VAR errorRec: ErrorRec);
  (* collect error data, fill in top trace point *)
    VAR tp: TracePoint; addr: INTEGER;
  BEGIN
    SYSTEM.GET(stackFrameBase + PCoffset, addr); (* return address for exc handler (PC on stack) *)
    getHalfWord(addr, tp.lineNo); (* source code line number *)
    DEC(addr, 2); (* address of SVC instruction *)
    tp.address := addr; (* SCV instruction address = error address *)
    getHalfWord(addr, errorRec.code); (* SCV instruction *)
    errorRec.code := BFX(errorRec.code, 7, 0); (* error code *)
    errorRec.trace.tp[0] := tp;
    errorRec.trace.count := 1
  END extractError;


  PROCEDURE extractFault(stackFrameBase: INTEGER; VAR faultRec: FaultRec);
  BEGIN
    SYSTEM.GET(stackFrameBase + PCoffset, faultRec.address);
    SYSTEM.EMIT(MCU.MRS_R11_IPSR);
    faultRec.code := SYSTEM.REG(11);
  END extractFault;


  PROCEDURE readRegs(stackFrameBase: INTEGER; VAR stackedRegs: StackedRegisters);
  BEGIN
    SYSTEM.GET(stackFrameBase, stackedRegs.r0);
    SYSTEM.GET(stackFrameBase + 4, stackedRegs.r1);
    SYSTEM.GET(stackFrameBase + 8, stackedRegs.r2);
    SYSTEM.GET(stackFrameBase + 12, stackedRegs.r3);
    SYSTEM.GET(stackFrameBase + 16, stackedRegs.r12);
    SYSTEM.GET(stackFrameBase + 20, stackedRegs.lr);
    SYSTEM.GET(stackFrameBase + 24, stackedRegs.pc);
    SYSTEM.GET(stackFrameBase + 28, stackedRegs.xpsr);
    stackedRegs.sp := stackFrameBase
  END readRegs;


  PROCEDURE traceStart(stackFrameBase: INTEGER): INTEGER;
    CONST StackAlign = 9; (* in stacked PSR *)
    VAR addr: INTEGER;
  BEGIN
    addr := stackFrameBase + StateContextSize;
    IF SYSTEM.BIT(stackFrameBase + PSRoffset, StackAlign) THEN
      INC(addr, 4)
    END
    RETURN addr
  END traceStart;


  PROCEDURE stackFrameBase(stackAddr, exc_return: INTEGER): INTEGER;
  (* address of stacked R0 *)
    VAR addr: INTEGER;
  BEGIN
    IF EXC_RET_SPSEL IN BITS(exc_return) THEN (* PSP used for stacking *)
      SYSTEM.EMIT(MCU.MRS_R11_PSP);
      addr := SYSTEM.REG(11)
    ELSE (* MSP used *)
      addr := stackAddr
    END
    RETURN addr
  END stackFrameBase;


  PROCEDURE errorHandler;
  (* via compiler-inserted SVC instruction *)
  (* in main stack *)
    VAR stackFrameAddr, cid, exc_return: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    IF exc[cid].currentRegsOn THEN
      exc[cid].errorRec.currentRegs.pc := SYSTEM.REG(PC); (* pretty useless *)
      exc[cid].errorRec.currentRegs.sp := SYSTEM.REG(SP);
      exc[cid].errorRec.currentRegs.lr := SYSTEM.REG(LR);
      SYSTEM.EMIT(MCU.MRS_R11_XPSR);
      exc[cid].errorRec.currentRegs.xpsr := SYSTEM.REG(11);
    END;
    exc_return := SYSTEM.REG(LR);
    exc[cid].errorRec.core := cid;
    stackFrameAddr := stackFrameBase(SYSTEM.REG(SP) + 16, exc_return); (* SP: + 16 for lr, stackFrameAddr, cid, exc_return *)
    IF exc[cid].stackedRegsOn THEN
      readRegs(stackFrameAddr, exc[cid].errorRec.stackedRegs)
    END;
    extractError(stackFrameAddr, exc[cid].errorRec);
    IF exc[cid].stackTraceOn THEN
      Stacktrace(traceStart(stackFrameAddr), exc[cid].errorRec.trace)
    END;
    exc[cid].handleException(cid, exc[cid].errorRec);
    (*ASSERT(FALSE);*)  (* trigger hard fault for testing *)
    HALT(cid)
  END errorHandler;


  PROCEDURE faultHandler;
  (* via MCU hardware-generated exception *)
  (* in main stack *)
    VAR stackFrameAddr, cid, exc_return: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    IF exc[cid].currentRegsOn THEN
      exc[cid].faultRec.currentRegs.pc := SYSTEM.REG(PC);
      exc[cid].faultRec.currentRegs.sp := SYSTEM.REG(SP);
      exc[cid].faultRec.currentRegs.lr := SYSTEM.REG(LR);
      SYSTEM.EMIT(MCU.MRS_R11_XPSR);
      exc[cid].faultRec.currentRegs.xpsr := SYSTEM.REG(11)
    END;
    exc_return := SYSTEM.REG(LR);
    exc[cid].faultRec.core := cid;
    stackFrameAddr := stackFrameBase(SYSTEM.REG(SP) + 16, exc_return); (* SP: + 16 for lr, stackFrameAddr, cid, exc_return *)
    IF exc[cid].stackedRegsOn THEN
      readRegs(stackFrameAddr, exc[cid].faultRec.stackedRegs)
    END;
    extractFault(stackFrameAddr, exc[cid].faultRec);
    exc[cid].handleException(cid, exc[cid].faultRec);
    HALT(cid)
  END faultHandler;


  PROCEDURE* SetHandler*(cpuId: INTEGER; eh: ExceptionHandler);
  BEGIN
    exc[cpuId].handleException := eh
  END SetHandler;

  PROCEDURE* SetHalt*(cpuId: INTEGER; on: BOOLEAN);
  BEGIN
    exc[cpuId].haltOn := on
  END SetHalt;

  PROCEDURE SetStacktraceOn*(cpuId: INTEGER; on: BOOLEAN);
  BEGIN
    exc[cpuId].stackTraceOn := on
  END SetStacktraceOn;

  PROCEDURE SetStackedRegsOn*(cpuId: INTEGER; on: BOOLEAN);
  BEGIN
    exc[cpuId].stackedRegsOn := on
  END SetStackedRegsOn;

  PROCEDURE SetCurrentRegsOn*(cpuId: INTEGER; on: BOOLEAN);
  BEGIN
    exc[cpuId].currentRegsOn := on
  END SetCurrentRegsOn;


  PROCEDURE* install(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END install;


  PROCEDURE ledOnAndHalt(cid: INTEGER; er: ExceptionRec);
  (* simplistic default handler *)
  BEGIN
    SYSTEM.PUT(LED.LSET, ErrorLed);
    REPEAT UNTIL FALSE (* HALT in any case *)
  END ledOnAndHalt;


  PROCEDURE init;
    CONST Core0 = 0;
    VAR i, addr, vectorTableBase, vectorTableTop: INTEGER;
  BEGIN
    i := 0;
    WHILE i < NumCores DO
      (* mark top of main stack *)
      SYSTEM.PUT(Memory.DataMem[i].stackStart, Memory.DataMem[i].stackStart);

      (* set core 0 VTOR register to core 0 SRAM bottom *)
      IF i = Core0 THEN
        (* VTOR of other cores will be set by core wake-up sequence *)
        SYSTEM.PUT(MCU.PPB_VTOR, Memory.DataMem[Core0].dataStart)
      END;

      (* initialise vector table *)
      vectorTableBase := Memory.DataMem[i].dataStart;
      vectorTableTop := vectorTableBase + MCU.VectorTableSize;
      install(vectorTableBase + MCU.NMIhandlerOffset, faultHandler);
      install(vectorTableBase + MCU.HardFaultHandlerOffset, faultHandler);
      install(vectorTableBase + MCU.SVChandlerOffset, errorHandler);
      addr := vectorTableBase + MCU.PendSVhandlerOffset;
      WHILE addr < vectorTableTop DO
        install(addr, faultHandler); INC(addr, 4)
      END;
      INC(i)
    END;

    (* default options *)
    i := 0;
    WHILE i < NumCores DO
      exc[i].handleException := ledOnAndHalt;
      exc[i].haltOn := TRUE;
      exc[i].stackedRegsOn := TRUE;
      exc[i].currentRegsOn := TRUE;
      exc[i].stackTraceOn := TRUE;
      INC(i)
    END;
  END init;

BEGIN
  init
END RuntimeErrors.


(**
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  Copyright (c) 2008-2023 CFB Software, https://www.astrobe.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**)
