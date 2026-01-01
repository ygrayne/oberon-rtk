MODULE Stacktrace;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Create stack trace amd read stack registers based on error data
  collected by run-time error handling RuntimeErrors.
  --
  MCU: MCXA346
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  Portions copyright (c) 2008-2024 CFB Software, https://www.astrobe.com
  Used with permission.
  Please refer to the licensing conditions as defined at the end of this file.
**)

  IMPORT SYSTEM, MCU := MCU2, Config, RuntimeErrors;

  CONST
    TraceDepth = 16;

    ExcRetMask = 0FFFFFFE3H;
    ExcRetVal = 0FFFFFFA0H;

    AnnNone* = 0;
    AnnStackframe* = -1;

    StackTraceNotLR = 0;
    StackTraceLineNo = 1;
    StackTraceNoLineNo = 2;

    (* stack context sizes *)
    StateContextSize = 8 * 4;
    (* unused
    ExtStateContextSize = 10 * 4;
    *)
    FPcontextSize = 18 * 4;

    (* register offsets from stacked r0 *)
    PSRoffset = 28;
    PCoffset = 24;
    LRoffset = 20;

    StackSeal = 0FEF5EDA5H;


    (* EXC_RETURN bits *)
    (*EXC_RET_S     = 6;*)  (* = 1: secure stack frame, faulty code was running in secure domain *)
    (*EXC_RET_DCRS  = 5;*)  (* = 0: all CPU regs stacked by hardware, extended state context *)
    EXC_RET_FType = 4;  (* = 0: all FPU regs stacked by hardware, extended FPU context *)
    (*EXC_RET_Mode  = 3; *) (* = 1: thread mode, faulty code was running in thread mode *)
    (*EXC_RET_SPSEL = 2; *) (* = 1: PSP used for stacking *)
    (*EXC_RET_ES    = 0;*)  (* = 1: exception running in secure domain *)

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

    StackedRegs* = RECORD
      r0*, r1*, r2*, r3*, r12*: INTEGER;
      lr*, pc*, xpsr*, sp*: INTEGER
    END;


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
      IF (lr >= Config.CodeMem.start + 100H) & (lr < Config.CodeMem.end) THEN
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

  PROCEDURE* traceStart(stackframeBase, excRetVal: INTEGER): INTEGER;
    CONST StackAlign = 9; (* in stacked PSR *)
    VAR startAddr: INTEGER;
  BEGIN
    startAddr := stackframeBase + StateContextSize;
    IF ~(EXC_RET_FType IN BITS(excRetVal)) THEN (* FP context *)
      startAddr := startAddr + FPcontextSize
    END;
    IF SYSTEM.BIT(stackframeBase + PSRoffset, StackAlign) THEN
      INC(startAddr, 4)
    END
    RETURN startAddr
  END traceStart;


  PROCEDURE getAddr(VAR stackAddr, excRetVal: INTEGER; VAR isStackFrame: BOOLEAN);
    CONST R11 = 11;
    VAR stackVal, lr, res: INTEGER;
  BEGIN
    isStackFrame := FALSE;
    SYSTEM.GET(stackAddr, stackVal);
    IF BITS(stackVal) * BITS(ExcRetMask) = BITS(ExcRetVal) THEN
      (* if a potential EXC_RETURN value *)
      excRetVal := stackVal; (* only valid if 'isStackFrame' *)
      SYSTEM.GET(stackAddr + 4, stackVal);
      IF stackVal = StackSeal THEN
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
      stackVal, retAddr, excRetVal, res, lr, traceDepth: INTEGER;
      (*addr, val: INTEGER; (* debug *)*)
      tp: TracePoint; isStackFrame: BOOLEAN;
  BEGIN
    CLEAR(tp);
    traceDepth := LEN(trace.tp);
    SYSTEM.GET(stackAddr, stackVal);
    WHILE (stackVal # StackSeal) & (trace.count <= traceDepth) DO
      (* debug *)
      (*
      Out.Hex(stackAddr, 13); Out.Hex(stackVal, 13); Out.Ln;
      *)
      (* debug end *)
      getAddr(stackAddr, excRetVal, isStackFrame);
      IF isStackFrame THEN
        SYSTEM.GET(stackAddr + PCoffset, retAddr);
        tp.address := retAddr;
        tp.annotation := AnnStackframe;
        tp.stackAddr := stackAddr;
        (* addr := stackAddr; (* debug *) *)
        stackAddr := traceStart(stackAddr, excRetVal);
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


  PROCEDURE CreateTrace*(er: RuntimeErrors.ErrorDesc; VAR tr: Trace);
    VAR tp: TracePoint;
  BEGIN
    tp.address := er.errAddr;
    tp.lineNo := er.errLineNo;
    tp.stackAddr := 0;
    tp.annotation := 0;
    tr.tp[0] := tp;
    tr.count := 1;
    tr.more := FALSE;
    stacktrace(traceStart(er.stackframeBase, er.excRetVal), tr)
  END CreateTrace;


  PROCEDURE ReadRegisters*(er: RuntimeErrors.ErrorDesc; VAR sr: StackedRegs);
    VAR stackframeBase: INTEGER;
  BEGIN
    stackframeBase := er.stackframeBase;
    SYSTEM.GET(stackframeBase, sr.r0);
    SYSTEM.GET(stackframeBase + 4, sr.r1);
    SYSTEM.GET(stackframeBase + 8, sr.r2);
    SYSTEM.GET(stackframeBase + 12, sr.r3);
    SYSTEM.GET(stackframeBase + 16, sr.r12);
    SYSTEM.GET(stackframeBase + 20, sr.lr);
    SYSTEM.GET(stackframeBase + 24, sr.pc);
    SYSTEM.GET(stackframeBase + 28, sr.xpsr);
    sr.sp := stackframeBase
  END ReadRegisters;

END Stacktrace.

(**
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  Copyright (c) 2008-2024 CFB Software, https://www.astrobe.com

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

