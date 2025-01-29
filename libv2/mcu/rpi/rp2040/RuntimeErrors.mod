MODULE RuntimeErrors;
(**
  Oberon RTK Framework v2
  --
  Exception handling: run-time errors and faults
  Multi-core
  --
  * Error: run-time errors, including ASSERT, triggered by SVC calls in software
  * Fault: hardware faults, triggered by MCU hardware
  --
  MCU: RP2040
  --
  Note: no terminal output is done here, since we don't know if there's
  even a terminal connected out in the wild, and if there's an
  operator seeing the messages. All error and fault data is collected,
  and passed to an installable handler, which then can print, or just log
  (or both), or take autonomous corrective actions, such as a restart.

  See module RuntimeErrorsOut for a corresponding handler and print
  functions.
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  Portions copyright (c) 2008-2023 CFB Software, https://www.astrobe.com
  Used with permission.
  Please refer to the licensing conditions as defined at the end of this file.
**)

  IMPORT
    SYSTEM, LED, MCU := MCU2, Config, Memory, Errors;

  CONST
    NumCores* = MCU.NumCores;
    TraceDepth* = 16;

    AnnNone* = 0;
    AnnStackframe* = -1;

    StackTraceNotLR = 0;
    StackTraceLineNo = 1;
    StackTraceNoLineNo = 2;

    ErrorLed = LED.Pico;

    (* stack context size *)
    StateContextSize = 8 * 4;

    (* register offsets from stacked r0 *)
    PSRoffset = 28;
    PCoffset = 24;
    LRoffset = 20;

    (* register numbers *)
    SP = 13;
    LR = 14;
    PC = 15;

    (* EXC_RETURN bits *)
    EXC_RET_Mode  = 3;  (* = 1: thread mode, faulty code was running in thread mode *)
    EXC_RET_SPSEL = 2;  (* = 1: PSP used for stacking *)


  TYPE
    TracePoint* = RECORD
      address*: INTEGER;
      lineNo*: INTEGER;
      stackAddr*: INTEGER;
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

    (* data collected for an error/fault *)
    ExceptionRec* = RECORD
      code*: INTEGER;     (* error or fault code *)
      core*: INTEGER;     (* MCU core *)
      address*: INTEGER;  (* error/fault code address *)
      lineNo*: INTEGER;   (* error source code line no, if available *)
      excType*: INTEGER;  (* type of exception: error or fault, handler or thread mode *)
      trace*: Trace;      (* stack trace *)
      stackedRegs*: StackedRegisters; (* register values as stacked my hrdware *)
      currentRegs*: CurrentRegisters  (* register values when error/fault handler begins *)
    END;

    (* installable handler for one error/fault exception *)
    ExceptionHandler* = PROCEDURE(er: ExceptionRec);

    (* error/fault exception instance data for one core *)
    Exception = RECORD
      excRec: ExceptionRec;
      handleException: ExceptionHandler;
      haltOn, stacktraceOn: BOOLEAN
    END;


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
  (* from Astrobe library, modified *)
  (* check if the instruction at 'codeAddr' is a BLX instruction: 010001111rrrr000 *)
    CONST
      BLXmask = 0FF87H; (* 1111 1111 1000 0111 *)
      BLXval  = 04780H; (* 0100 0111 1000 0000 *)
    VAR instr: INTEGER;
  BEGIN
    getHalfWord(codeAddr, instr);
    RETURN BITS(instr) * BITS(BLXmask) = BITS(BLXval)
    (*RETURN (BFX(instr, 15, 7) = 08FH) & (BFX(instr, 2, 0) = 0)*)
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


  PROCEDURE* threadMode(excRetVal: INTEGER): BOOLEAN;
    RETURN EXC_RET_Mode IN BITS(excRetVal)
  END threadMode;


  PROCEDURE extractError(stackframeBase, excRetVal: INTEGER; VAR errorRec: ExceptionRec; VAR tp: TracePoint);
  (* collect error data, create initial trace point *)
    VAR addr, lineNo: INTEGER;
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
    tp.stackAddr := stackframeBase + PCoffset;
    IF threadMode(excRetVal) THEN
      errorRec.excType := Errors.ExcTypeErrorThread
    ELSE
      errorRec.excType := Errors.ExcTypeErrorHandler
    END
  END extractError;


  PROCEDURE extractFault(stackframeBase, excRetVal: INTEGER; VAR faultRec: ExceptionRec; VAR tp: TracePoint);
  (* collect fault data, create initial trace point *)
    VAR addr: INTEGER;
  BEGIN
    SYSTEM.GET(stackframeBase + PCoffset, addr);
    SYSTEM.EMIT(MCU.MRS_R11_IPSR);
    faultRec.code := -SYSTEM.REG(11);
    faultRec.lineNo := 0;
    faultRec.address := addr;
    tp.address := addr;
    tp.lineNo := 0;
    tp.stackAddr := stackframeBase + PCoffset;
    IF threadMode(excRetVal) THEN
      faultRec.excType := Errors.ExcTypeFaultThread
    ELSE
      faultRec.excType := Errors.ExcTypeFaultHandler
    END
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


  PROCEDURE* traceStart(stackframeBase: INTEGER): INTEGER;
    CONST StackAlign = 9; (* in stacked PSR *)
    VAR addr: INTEGER;
  BEGIN
    addr := stackframeBase + StateContextSize;
    IF SYSTEM.BIT(stackframeBase + PSRoffset, StackAlign) THEN
      INC(addr, 4)
    END
    RETURN addr
  END traceStart;


  PROCEDURE* stackframeBase(excRetAddr: INTEGER): INTEGER;
    VAR addr, excRetVal: INTEGER;
  BEGIN
    SYSTEM.GET(excRetAddr, excRetVal);
    IF EXC_RET_SPSEL IN BITS(excRetVal) THEN (* PSP used for stacking *)
      SYSTEM.EMIT(MCU.MRS_R11_PSP);
      addr := SYSTEM.REG(11)
    ELSE (* MSP used *)
      addr := excRetAddr + 4;
    END
    RETURN addr
  END stackframeBase;


  PROCEDURE getAddr(VAR stackAddr: INTEGER; VAR isStackFrame: BOOLEAN);
    CONST R11 = 11; ExcRetMask = 0FFFFFFF3H; ExcRetVal = 0FFFFFFF1H;
    VAR stackVal, lr, res, cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    isStackFrame := FALSE;
    SYSTEM.GET(stackAddr, stackVal);
    IF BITS(stackVal) * BITS(ExcRetMask) = BITS(ExcRetVal) THEN
      (* if a potential EXC_RETURN value *)
      SYSTEM.GET(stackAddr + 4, stackVal);
      IF stackVal = Memory.StackSeal THEN
        (* at top of main stack: we have an EXC_RETURN value with 'PSP used for stacking' *)
        (* switch stacks, point to stacked regs on process stack *)
          SYSTEM.EMIT(MCU.MRS_R11_PSP);
        stackAddr := SYSTEM.REG(R11);
        isStackFrame := TRUE
      ELSE
        (* point to potential stack frame on main stack*)
        INC(stackAddr, 4);
      (* stacked value at LRoffset must be either a valid LR value... *)
      getLR(stackAddr + LRoffset, lr, res);
      isStackFrame := res > StackTraceNotLR;
      (* ... or an EXC_RETURN value *)
      IF ~isStackFrame THEN
          SYSTEM.GET(stackAddr + LRoffset, stackVal);
          isStackFrame := BITS(stackVal) * BITS(ExcRetMask) = BITS(ExcRetVal)
        END
      END
    END
  END getAddr;


  PROCEDURE stacktrace(stackAddr: INTEGER; VAR trace: Trace);
    VAR
      stackVal, retAddr, res, lr, traceDepth: INTEGER;
      (* addr, val: INTEGER; (* debug *) *)
      tp: TracePoint; isStackFrame: BOOLEAN;
  BEGIN
    CLEAR(tp);
    traceDepth := LEN(trace.tp);
    SYSTEM.GET(stackAddr, stackVal);
    WHILE (stackVal # Memory.StackSeal) & (trace.count <= TraceDepth) DO
      (* debug *)
      (* Out.Hex(stackAddr, 13); Out.Hex(stackVal, 13); Out.Ln; *)
      (* debug end *)
      getAddr(stackAddr, isStackFrame);
      IF isStackFrame THEN
        SYSTEM.GET(stackAddr + PCoffset, retAddr);
        tp.address := retAddr;
        tp.annotation := AnnStackframe;
        tp.stackAddr := stackAddr;
        (* addr := stackAddr; (* debug *) *)
        stackAddr := traceStart(stackAddr);
        (* debug: print stack dump *)
        (*
        WHILE addr < stackAddr DO
          SYSTEM.GET(addr, val);
          Out.String("> "); Out.Hex(addr, 13); Out.Hex(val, 13); Out.Ln;
          INC(addr, 4)
        END
        *)
        (* debug end *)
      ELSE
        getLR(stackAddr, lr, res);
        IF res > StackTraceNotLR THEN
          tp.address := lr - 4;
          tp.stackAddr := stackAddr;
          IF res = StackTraceLineNo THEN
            getHalfWord(lr + 2, tp.lineNo)
          END
        END;
        INC(stackAddr, 4)
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
  END stacktrace;


  PROCEDURE* initTrace(VAR tr: Trace; tp: TracePoint);
  BEGIN
    tr.tp[0] := tp;
    tr.count := 1;
    tr.more := FALSE
  END initTrace;


  PROCEDURE errorHandler;
  (* via compiler-inserted SVC instruction *)
  (* in main stack *)
    VAR
      stackframeAddr, traceStartAddr, excRetVal, cid: INTEGER;
      tp: TracePoint; cr: CurrentRegisters;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    cr.pc := SYSTEM.REG(PC);
    cr.sp := SYSTEM.REG(SP);
    cr.lr := SYSTEM.REG(LR);
    SYSTEM.EMIT(MCU.MRS_R11_XPSR);
    cr.xpsr := SYSTEM.REG(11);
    exc[cid].excRec.currentRegs := cr;
    exc[cid].excRec.core := cid;
    excRetVal := SYSTEM.REG(LR);
    stackframeAddr := stackframeBase(SYSTEM.REG(SP) + 48); (* SP + 48: addr of EXC_RETURN on stack *)
    readRegs(stackframeAddr, exc[cid].excRec.stackedRegs);
    extractError(stackframeAddr, excRetVal, exc[cid].excRec, tp);
    IF exc[cid].stacktraceOn THEN
      traceStartAddr := traceStart(stackframeAddr);
      initTrace(exc[cid].excRec.trace, tp);
      stacktrace(traceStartAddr, exc[cid].excRec.trace)
    END;
    exc[cid].handleException(exc[cid].excRec);
    HALT(cid)
  END errorHandler;


  PROCEDURE faultHandler;
  (* via MCU hardware-generated exception *)
  (* in main stack *)
    VAR
      stackframeAddr, traceStartAddr, excRetVal, cid: INTEGER;
      tp: TracePoint; cr: CurrentRegisters;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    cr.pc := SYSTEM.REG(PC);
    cr.sp := SYSTEM.REG(SP);
    cr.lr := SYSTEM.REG(LR);
    SYSTEM.EMIT(MCU.MRS_R11_XPSR);
    cr.xpsr := SYSTEM.REG(11);
    exc[cid].excRec.currentRegs := cr;
    exc[cid].excRec.core := cid;
    excRetVal := SYSTEM.REG(LR);
    stackframeAddr := stackframeBase(SYSTEM.REG(SP) + 48); (* SP + 48: addr of EXC_RETURN on stack *)
    readRegs(stackframeAddr, exc[cid].excRec.stackedRegs);
    extractFault(stackframeAddr, excRetVal, exc[cid].excRec, tp);
    IF exc[cid].stacktraceOn THEN
      traceStartAddr := traceStart(stackframeAddr);
      initTrace(exc[cid].excRec.trace, tp);
      stacktrace(traceStartAddr, exc[cid].excRec.trace)
    END;
    exc[cid].handleException(exc[cid].excRec);
    HALT(cid)
  END faultHandler;


  PROCEDURE Stacktrace*(VAR tr: Trace);
  (* experimental *)
  BEGIN
    tr.count := 0;
    tr.more := FALSE;
    CLEAR(tr.tp);
    stacktrace(SYSTEM.REG(SP) + 8, tr)
  END Stacktrace;


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


  PROCEDURE* ledOnAndHalt(er: ExceptionRec);
  (* simplistic default handler *)
  BEGIN
    SYSTEM.PUT(LED.LSET, {ErrorLed});
    REPEAT UNTIL FALSE (* HALT in any case *)
  END ledOnAndHalt;


  PROCEDURE init;
    CONST Core0 = 0;
    VAR i, addr, vectorTableBase, vectorTableTop: INTEGER;
  BEGIN
    i := 0;
    WHILE i < NumCores DO
      (* set core 0 VTOR register to core 0 SRAM bottom *)
      IF i = Core0 THEN
        (* VTOR of other cores will be set by core 1 wake-up sequence *)
        SYSTEM.PUT(MCU.PPB_VTOR, Memory.DataMem[Core0].dataStart)
      END;

      (* initialise vector table *)
      (* install handlers for all errors and faults as implemented in the MCU *)
      vectorTableBase := Memory.DataMem[i].dataStart;
      vectorTableTop := vectorTableBase + MCU.VectorTableSize;
      installHandler(vectorTableBase + MCU.NMIhandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.HardFaultHandlerOffset, faultHandler);
      installHandler(vectorTableBase + MCU.SVChandlerOffset, errorHandler);

      (* install faultHandler across the rest of the vector table *)
      (* will catch any exception with a missing handler *)
      addr := vectorTableBase + MCU.PendSVhandlerOffset;
      WHILE addr < vectorTableTop DO
        installHandler(addr, faultHandler); INC(addr, 4)
      END;
      INC(i)
    END;

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
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
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
