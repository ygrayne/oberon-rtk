MODULE RuntimeErrors;
(**
  Oberon RTK Framework v2
  --
  Exception handling: run-time errors and faults
  Multi-core
  --
  Error: run-time errors, including ASSERT, triggered by SVC calls in software
  Fault: hardware faults, triggered by MCU hardware
  --
  MCU: RP2350
  --
  NOTE:
    * for Secure, privileged code
    * implications of other MOs to be identified
  --
  Note: no terminal output is done here, since we don't know if there's
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
    NumCores* = MCU.NumCores;
    TraceDepth* = 16;
    ExcRecTypeError* = 0;
    ExcRecTypeFault* = 1;

    AnnNone* = 0;
    AnnNewContext* = -1;
    StackTraceNotLR = 0;
    StackTraceLineNo = 1;
    StackTraceNoLineNo = 2;
    ErrorLed = LED.Pico;

    (* stack frame sizes and register offsets from stacked r0 *)
    StateContextSize = 8 * 4;
    ExtStateContextSize = 10 * 4;
    FPcontextSize = 18 * 4;
    ExtFPcontextSize = 16 * 4;

    PSRoffset = 28;
    PCoffset = 24;
    LRoffset = 20;

    (* register numbers *)
    SP = 13;
    LR = 14;
    PC = 15;


    (* PPB_FPCCR bits *)
    FPCCR_TS  = 26;

    (* PPB_SHCSR bits *)
    SECUREFAULTENA  = 19;
    USGFAULTENA     = 18;
    BUSFAULTENA     = 17;
    MEMFAULTENA     = 16;

    (* EXC_RETURN bits *)
    (*EXC_RET_S     = 6;*)  (* = 1: secure stack frame, faulty code was running in secure domain *)
    EXC_RET_DCRS  = 5;  (* = 0: all CPU regs stacked by hardware, extended state context *)
    EXC_RET_FType = 4;  (* = 0: all FPU regs stacked by hardware, extended FPU context *)
    (*EXC_RET_Mode  = 3;*)  (* = 1: thread mode, faulty code was running in thread mode *)
    EXC_RET_SPSEL = 2;  (* = 1: PSP used for stacking *)
    (*EXC_RET_ES    = 0;*)  (* = 1: exception running in secure domain *)


  TYPE
    TracePoint* = RECORD
      address*: INTEGER;
      lineNo*: INTEGER;
      annotation*: INTEGER
    END;

    Trace* = RECORD
      tp*: ARRAY TraceDepth OF TracePoint;
      count*: INTEGER;
      more*: BOOLEAN
    END;

    StackedRegisters* = RECORD
      r0*, r1*, r2*, r3*, r12*: INTEGER;
      lr*, pc*, xpsr*, sp*: INTEGER
    END;

    CurrentRegisters* = RECORD
      sp*, lr*, pc*, xpsr*: INTEGER
    END;

    ExceptionRec* = RECORD
      code*: INTEGER; (* error or fault code *)
      core*: INTEGER; (* MCU core *)
      address*: INTEGER;
      lineNo*: INTEGER;
      trace*: Trace;
      stackedRegs*: StackedRegisters;
      currentRegs*: CurrentRegisters;
      excType*: INTEGER
    END;

    Exception = RECORD
      excRec: ExceptionRec;
      handleException: PROCEDURE(cpuId: INTEGER; er: ExceptionRec);
      haltOn, stacktraceOn: BOOLEAN
    END;

    ExceptionHandler* = PROCEDURE(cpuId: INTEGER; er: ExceptionRec);


  VAR
    exc: ARRAY NumCores OF Exception;

  (* IMPORTANT: if the error/fault handler does not HALT, 'handleException' has to set an
  appropriate exception return address on the stack to continue in a reasonable way. *)

  (* --- Astrobe code begin --- *)

  PROCEDURE* getHalfWord(addr: INTEGER; VAR value: INTEGER);
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
  (* check if the instruction at 'codeAddr' is a BL instruction: [31:27] = 11110 *)
  (* note how the 32 bit code is stored as two 16 bit values:
      addr[x]   = [31:16]
      addr[x+2] = [15:0]
    since we have little endian encoding, it's physically:
      addr[x]   = [23:16][31:24]
      addr[x+2] = [7:0][15:8]
    but the load instruction takes care of *that* conversion.
  *)
    VAR instr: INTEGER;
  BEGIN
    getHalfWord(codeAddr, instr);
    RETURN BFX(instr, 15, 11) = 01EH
  END isBL;

  PROCEDURE isBLX(codeAddr: INTEGER): BOOLEAN;
  (* from Astrobe library *)
  (* check if the instruction at 'codeAddr' is a BLX instruction: 010001111rrrr000 *)
    VAR instr: INTEGER;
  BEGIN
    getHalfWord(codeAddr, instr);
    RETURN (BFX(instr, 15, 7) = 08FH) & (BFX(instr, 2, 0) = 0)
  END isBLX;

  PROCEDURE getLR(stackAddr: INTEGER; VAR lr, res: INTEGER);
  (* from Astrobe library, modified *)
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
          (* if stack trace is enabled there is a B,0 instruction (0E0000H)
          that skips the line number after the BL or BLX instruction *)
          IF nextInstr = 0E000H THEN
            res := StackTraceLineNo
          ELSE
            res := StackTraceNoLineNo
          END
        END
      END
    END
  END getLR;

  (* --- Astrobe code end --- *)


  PROCEDURE* HALT(cid: INTEGER);
  BEGIN
    IF exc[cid].haltOn THEN
      REPEAT UNTIL FALSE
    END
  END HALT;


  PROCEDURE* traceStart(stackframeBase, excReturn: INTEGER): INTEGER;
    CONST StackAlign = 9; (* in stacked PSR *)
    VAR addr: INTEGER;
  BEGIN
    addr := stackframeBase + StateContextSize;
    IF ~(EXC_RET_FType IN BITS(excReturn)) THEN (* FP context *)
      addr := addr + FPcontextSize;
      IF SYSTEM.BIT(MCU.PPB_FPCCR, FPCCR_TS) THEN
        addr := addr + ExtFPcontextSize (* extended FP context *)
      END
    END;
    IF SYSTEM.BIT(stackframeBase + PSRoffset, StackAlign) THEN
      INC(addr, 4)
    END
    RETURN addr
  END traceStart;


  PROCEDURE extractError(stackframeBase: INTEGER; VAR errorRec: ExceptionRec);
  (* collect error data, fill-in initial trace point *)
    VAR tp: TracePoint; addr, lineNo: INTEGER;
  BEGIN
    SYSTEM.GET(stackframeBase + PCoffset, addr); (* return address for exc handler (PC on stack) *)
    getHalfWord(addr, lineNo); (* source code line number *)
    DEC(addr, 2); (* address of SVC instruction = error address *)
    getHalfWord(addr, errorRec.code); (* SCV instruction *)
    errorRec.code := BFX(errorRec.code, 7, 0); (* error code *)
    errorRec.lineNo := lineNo;
    errorRec.address := addr;
    tp.address := addr;
    tp.lineNo := lineNo;
    errorRec.trace.tp[0] := tp;
    errorRec.trace.count := 1
  END extractError;


  PROCEDURE* extractFault(stackframeBase: INTEGER; VAR faultRec: ExceptionRec);
  (* collect fault data, fill-in initial trace point *)
    VAR tp: TracePoint; addr: INTEGER;
  BEGIN
    SYSTEM.GET(stackframeBase + PCoffset, addr);
    SYSTEM.EMIT(MCU.MRS_R11_IPSR);
    faultRec.code := SYSTEM.REG(11);
    faultRec.lineNo := 0;
    faultRec.address := addr;
    tp.address := addr;
    tp.lineNo := 0;
    faultRec.trace.tp[0] := tp;
    faultRec.trace.count := 1
  END extractFault;


  PROCEDURE* readRegs(stackframeBase: INTEGER; VAR stackedRegs: StackedRegisters);
  BEGIN
    SYSTEM.GET(stackframeBase, stackedRegs.r0);
    SYSTEM.GET(stackframeBase + 4, stackedRegs.r1);
    SYSTEM.GET(stackframeBase + 8, stackedRegs.r2);
    SYSTEM.GET(stackframeBase + 12, stackedRegs.r3);
    SYSTEM.GET(stackframeBase + 16, stackedRegs.r12);
    SYSTEM.GET(stackframeBase + 20, stackedRegs.lr);
    SYSTEM.GET(stackframeBase + 24, stackedRegs.pc);
    SYSTEM.GET(stackframeBase + 28, stackedRegs.xpsr);
    stackedRegs.sp := stackframeBase
  END readRegs;


  PROCEDURE* stackframeBase(stackAddr, excReturn: INTEGER): INTEGER;
  (* address of stacked R0 *)
    VAR addr: INTEGER;
  BEGIN
    IF EXC_RET_SPSEL IN BITS(excReturn) THEN (* PSP used for stacking *)
      SYSTEM.EMIT(MCU.MRS_R11_PSP);
      addr := SYSTEM.REG(11)
    ELSE (* MSP used *)
      addr := stackAddr
    END;
    IF ~(EXC_RET_DCRS IN BITS(excReturn)) THEN (* extended state context *)
      addr := addr + ExtStateContextSize
    END;
    RETURN addr
  END stackframeBase;


  PROCEDURE isBaseOfStackframe(stackAddr, stackVal: INTEGER): BOOLEAN;
    VAR isBase: BOOLEAN; lr, res: INTEGER;
  BEGIN
    isBase := FALSE;
    IF (BFX(stackVal, 31, 8) = 0FFFFFFH) THEN
      getLR(stackAddr + LRoffset, lr, res);
      isBase := res > StackTraceNotLR
    END
    RETURN isBase
  END isBaseOfStackframe;

(* debug version: prints stack dump
  PROCEDURE Stacktrace*(stackAddr: INTEGER; VAR trace: Trace);
    VAR
      lr, stackVal, res, traceStart0, retAddr, sa, sv: INTEGER;
      tp: TracePoint;
  BEGIN
    trace.more := FALSE;
    SYSTEM.GET(stackAddr, stackVal);
    CLEAR(tp);
    WHILE (stackAddr # stackVal) & (trace.count <= TraceDepth) DO
      IF ~isBaseOfStackframe(stackAddr + 4, stackVal) THEN
        (* debug begin *)
        Out.Hex(stackAddr, 12); Out.Hex(stackVal, 12);
        (* debug end *)
        getLR(stackAddr, lr, res);
        IF res > StackTraceNotLR THEN
          (* debug begin *)
          Out.Hex(lr - 4, 12);
          (* debug end *)
          tp.address := lr - 4;
          IF res = StackTraceLineNo THEN
            getHalfWord(lr + 2, tp.lineNo)
          END;
        END;
        (* debug begin *)
        Out.Ln;
        (* debug end *)
        INC(stackAddr, 4)
      ELSE
        (* debug begin *)
        sa := stackAddr;
        sv := stackVal;
        (* debug end *)

        INC(stackAddr, 4);
        traceStart0 := traceStart(stackAddr, stackVal); (* stackVal = EXC_RETURN from stack *)

        (* debug begin *)
        WHILE sa < traceStart0 DO
          Out.String("> "); Out.Hex(sa, 12); Out.Hex(sv, 12); Out.Ln;
          INC(sa, 4);
          SYSTEM.GET(sa, sv)
        END;
        (* debug end *)

        SYSTEM.GET(stackAddr + PCoffset, retAddr);
        tp.address := retAddr;
        tp.annotation := AnnNewContext;
        stackAddr := traceStart0
      END;

      IF tp.address # 0 THEN (* tp is valid *)
        IF trace.count < TraceDepth THEN
          trace.tp[trace.count] := tp;
          INC(trace.count);
          CLEAR(tp)
        ELSE
          trace.more := TRUE
        END
      END;

      SYSTEM.GET(stackAddr, stackVal)
    END
  END Stacktrace;
*)

  PROCEDURE Stacktrace*(stackAddr: INTEGER; VAR trace: Trace);
    VAR
      lr, stackVal, res, retAddr: INTEGER;
      tp: TracePoint;
  BEGIN
    trace.more := FALSE;
    SYSTEM.GET(stackAddr, stackVal);
    CLEAR(tp);
    WHILE (stackAddr # stackVal) & (trace.count <= TraceDepth) DO
      IF ~isBaseOfStackframe(stackAddr + 4, stackVal) THEN
        getLR(stackAddr, lr, res);
        IF res > StackTraceNotLR THEN
          tp.address := lr - 4;
          IF res = StackTraceLineNo THEN
            getHalfWord(lr + 2, tp.lineNo)
          END;
        END;
        INC(stackAddr, 4)
      ELSE
        INC(stackAddr, 4);
        SYSTEM.GET(stackAddr + PCoffset, retAddr);
        tp.address := retAddr;
        tp.annotation := AnnNewContext;
        stackAddr := traceStart(stackAddr, stackVal); (* stackVal = EXC_RETURN from stack *)
      END;
      IF tp.address # 0 THEN (* tp is valid *)
        IF trace.count < TraceDepth THEN
          trace.tp[trace.count] := tp;
          INC(trace.count);
          CLEAR(tp)
        ELSE
          trace.more := TRUE
        END
      END;
      SYSTEM.GET(stackAddr, stackVal)
    END
  END Stacktrace;


  PROCEDURE errorHandler;
  (* via compiler-inserted SVC instruction *)
  (* in main stack *)
    VAR stackframeAddr, cid, excReturn: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    exc[cid].excRec.currentRegs.pc := SYSTEM.REG(PC);
    exc[cid].excRec.currentRegs.sp := SYSTEM.REG(SP);
    exc[cid].excRec.currentRegs.lr := SYSTEM.REG(LR);
    SYSTEM.EMIT(MCU.MRS_R11_XPSR);
    exc[cid].excRec.currentRegs.xpsr := SYSTEM.REG(11);
    excReturn := SYSTEM.REG(LR);
    exc[cid].excRec.core := cid;
    stackframeAddr := stackframeBase(SYSTEM.REG(SP) + 16, excReturn); (* SP: + 16 for lr, stackframeAddr, cid, exc_return *)
    readRegs(stackframeAddr, exc[cid].excRec.stackedRegs);
    extractError(stackframeAddr, exc[cid].excRec);
    IF exc[cid].stacktraceOn THEN
      Stacktrace(traceStart(stackframeAddr, excReturn), exc[cid].excRec.trace)
    END;
    exc[cid].excRec.excType := ExcRecTypeError;
    exc[cid].handleException(cid, exc[cid].excRec);
    (*ASSERT(FALSE);*)  (* trigger hard fault for testing *)
    HALT(cid)
  END errorHandler;


  PROCEDURE faultHandler;
  (* via MCU hardware-generated exception *)
  (* in main stack *)
    VAR stackframeAddr, cid, excReturn: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    exc[cid].excRec.currentRegs.pc := SYSTEM.REG(PC);
    exc[cid].excRec.currentRegs.sp := SYSTEM.REG(SP);
    exc[cid].excRec.currentRegs.lr := SYSTEM.REG(LR);
    SYSTEM.EMIT(MCU.MRS_R11_XPSR);
    exc[cid].excRec.currentRegs.xpsr := SYSTEM.REG(11);
    excReturn := SYSTEM.REG(LR);
    exc[cid].excRec.core := cid;
    stackframeAddr := stackframeBase(SYSTEM.REG(SP) + 16, excReturn); (* SP: + 16 for lr, stackframeAddr, cid, exc_return *)
    readRegs(stackframeAddr, exc[cid].excRec.stackedRegs);
    extractFault(stackframeAddr, exc[cid].excRec);
    IF exc[cid].stacktraceOn THEN
      Stacktrace(traceStart(stackframeAddr, excReturn), exc[cid].excRec.trace)
    END;
    exc[cid].excRec.excType := ExcRecTypeFault;
    exc[cid].handleException(cid, exc[cid].excRec);
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

  PROCEDURE* SetStacktraceOn*(cpuId: INTEGER; on: BOOLEAN);
  BEGIN
    exc[cpuId].stacktraceOn := on
  END SetStacktraceOn;


  PROCEDURE* installHandler(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END installHandler;


  PROCEDURE* ledOnAndHalt(cid: INTEGER; er: ExceptionRec);
  (* simplistic default handler *)
  BEGIN
    SYSTEM.PUT(LED.LSET, ErrorLed);
    REPEAT UNTIL FALSE (* HALT in any case *)
  END ledOnAndHalt;


  PROCEDURE init;
    CONST Core0 = 0;
    VAR i, x, addr, vectorTableBase, vectorTableTop: INTEGER;
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
      installHandler(vectorTableBase + MCU.NMIhandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.HardFaultHandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.MemMgmtFaultHandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.BusFaultHandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.UsageFaultHandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.SecureFaultHandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.SVChandlerOffset, errorHandler);
      installHandler(vectorTableBase + MCU.DebugMonitorOffset, faultHandler);
      addr := vectorTableBase + MCU.PendSVhandlerOffset;
      WHILE addr < vectorTableTop DO
        installHandler(addr, faultHandler); INC(addr, 4)
      END;
      INC(i)
    END;

    (* enable MCU faults *)
    SYSTEM.GET(MCU.PPB_SHCSR, x);
    x := x + ORD({MEMFAULTENA, BUSFAULTENA, USGFAULTENA, SECUREFAULTENA});
    SYSTEM.PUT(MCU.PPB_SHCSR, x);

    (* default options *)
    i := 0;
    WHILE i < NumCores DO
      exc[i].handleException := ledOnAndHalt;
      exc[i].haltOn := TRUE;
      exc[i].stacktraceOn := TRUE;
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
