MODULE Stacktrace;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Create stack trace and read stack registers based on error data
  collected by run-time error handling RuntimeErrors.
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  Portions copyright (c) 2008-2024 CFB Software, https://www.astrobe.com
  Used with permission.
  Please refer to the licensing conditions as defined at the end of this file.
**)

  IMPORT SYSTEM, ProgData, RuntimeErrors;

  CONST
    TraceDepth* = 16;

    (* procedure prolog handling *)
    (* push (PUSH T1) identification *)
    PushT2mask  = 0FE00H;
    PushT2val   = 0B400H;

    (* push.w (STMDB T1) identification *)
    PushWstmdb  = 0E92DH;

    (* push.w (STR T4) identification *)
    PushWstr    = 0F84DH;

    (* sub (SUB(SP) T1) identification *)
    SubT1mask   = 0FF80H;
    SubT1val    = 0B080H;

    (* sub.w (SUB(SP) T2) identification *)
    SubT2mask   = 0FBEFH;
    SubT2val    = 0F1ADH;
    SubT2rdMask = 08F00H;
    SubT2rdVal  = 00D00H;


    (* trace capturing *)
    ExcRetPattern = 01FFFFFFH; (* [31:7] *)
    LineNoBranch = 0E000H; (* B,0 instruction before line number *)
    StackSeal = 0FEF5EDA5H;

    AnnNone* = 0;
    AnnStackframe* = -1;

    (* stack context sizes and EXC_RETURN flags *)
    StateContextSize = 8 * 4;
    (*ExtStateContextSize = 10 * 4;*) (* already accounted for by RuntimeErrors.excHandler *)
    FPcontextSize = 18 * 4;
    FPadditionalSize = 16 * 4;
    EXC_RET_DCRS  = 5;      (* = 0: all CPU regs stacked by hardware, extended state context *)
    EXC_RET_FType = 4;      (* = 0: all FPU regs stacked by hardware, extended FPU context *)

    (* register offsets from stacked r0 *)
    PSRoffset = 28;
    PCoffset = 24;


  TYPE
    TracePoint* = RECORD
      address*: INTEGER;
      lineNo*: INTEGER;
      stackAddr*: INTEGER;
      frameSize*: INTEGER;
      annotation*: INTEGER
    END;

    Trace* = RECORD
      tp*: ARRAY TraceDepth OF TracePoint;
      count*: INTEGER;
      more*: BOOLEAN;
      error*: BOOLEAN
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

  (* --- Astrobe code end --- *)


  PROCEDURE* bitCount(val, n: INTEGER): INTEGER;
  (* count set bits in the lowest n bits of val *)
    VAR count, i: INTEGER;
  BEGIN
    count := 0; i := 0;
    WHILE i < n DO
      IF ODD(val) THEN INC(count) END;
      val := LSR(val, 1);
      INC(i)
    END
    RETURN count
  END bitCount;


  PROCEDURE* decodeThumbModImm(hw1, hw2: INTEGER): INTEGER;
  (* decode Thumb32 modified immediate from SUB(SP) T2 *)
  (* hw1: first halfword, hw2: second halfword *)
  (* extracts i:imm3:imm8 and decodes per ARM T32ExpandImm *)
    VAR imm12, base, rot, result: INTEGER;
  BEGIN
    imm12 := LSL(BFX(hw1, 10, 10), 11) + LSL(BFX(hw2, 14, 12), 8) + BFX(hw2, 7, 0);

    IF BFX(imm12, 11, 10) = 0 THEN
      (* non-rotated forms, sub-selected by imm12[9:8] *)
      base := BFX(imm12, 7, 0);
      IF BFX(imm12, 9, 8) = 0 THEN
        (* 00 00: plain 8-bit value *)
        result := base
      ELSIF BFX(imm12, 9, 8) = 1 THEN
        (* 00 01: 00XY00XY *)
        result := LSL(base, 16) + base
      ELSIF BFX(imm12, 9, 8) = 2 THEN
        (* 00 10: XY00XY00 *)
        base := LSL(base, 8);
        result := LSL(base, 16) + base
      ELSE
        (* 00 11: XYXYXYXY *)
        result := LSL(base, 24) + LSL(base, 16) + LSL(base, 8) + base
      END
    ELSE
      (* imm12[11:10] != 00: rotated 1:imm12[6:0] by imm12[11:7] *)
      rot := BFX(imm12, 11, 7);
      base := 80H + BFX(imm12, 6, 0);
      result := ROR(base, rot)
    END
    RETURN result
  END decodeThumbModImm;


  PROCEDURE getFrameSize(addr: INTEGER; VAR frameSize: INTEGER);
  (* addr: procedure entry address (from ProgData)
     frameSize: total frame size in bytes (push + sub)
     saved LR is always at sp + frameSize - 4 *)
    VAR hw1, hw2, nPush, nSub, subAddr: INTEGER;
  BEGIN
    nPush := 0; nSub := 0; subAddr := 0;
    getHalfWord(addr, hw1);
    IF BITS(hw1) * BITS(PushT2mask) = BITS(PushT2val) THEN
      (* push(PUSH T2): 16-bit, bits [8:0] = register list *)
      nPush := bitCount(hw1, 9);
      subAddr := addr + 2
    ELSIF hw1 = PushWstmdb THEN
      (* push.w(STMDB T1): 32-bit, register list in second halfword *)
      getHalfWord(addr + 2, hw2);
      IF BITS(hw2) * BITS(0A000H) = {} THEN (* bits 15 and 13 must be (0) *)
        nPush := bitCount(hw2, 15);
        subAddr := addr + 4
      END
    ELSIF hw1 = PushWstr THEN
      (* push.w(STR T4): 32-bit, single register *)
      nPush := 1;
      subAddr := addr + 4
    END;
    IF nPush > 0 THEN
      (* check for sub/sub.w immediately after push *)
      getHalfWord(subAddr, hw1);
      IF BITS(hw1) * BITS(SubT1mask) = BITS(SubT1val) THEN
        (* sub (SUB(SP) T1): 16-bit, bits [6:0] = immediate / 4 *)
        nSub := BFX(hw1, 6, 0)
      ELSIF BITS(hw1) * BITS(SubT2mask) = BITS(SubT2val) THEN
        (* sub.w (SUB(SP) T2): 32-bit, check Rd = SP *)
        getHalfWord(subAddr + 2, hw2);
        IF BITS(hw2) * BITS(SubT2rdMask) = BITS(SubT2rdVal) THEN
          nSub := decodeThumbModImm(hw1, hw2) DIV 4
        END
      END
    END;
    frameSize := (nPush + nSub) * 4
  END getFrameSize;


  PROCEDURE* isExcReturn(val: INTEGER): BOOLEAN;
    RETURN BFX(val, 31, 7) = ExcRetPattern
  END isExcReturn;


  PROCEDURE getLineNo(addr: INTEGER; VAR lineNo: INTEGER);
  (* check if instruction at addr is B,0 (line number follows) *)
    VAR instr: INTEGER;
  BEGIN
    lineNo := 0;
    getHalfWord(addr, instr);
    IF instr = LineNoBranch THEN
      getHalfWord(addr + 2, lineNo)
    END
  END getLineNo;


  PROCEDURE* addTP(VAR tr: Trace; addr, lineNo, sAddr, fSize, ann: INTEGER);
  (* add a trace point if space available *)
    VAR tp: TracePoint;
  BEGIN
    IF tr.count < TraceDepth THEN
      tp.address := addr;
      tp.lineNo := lineNo;
      tp.stackAddr := sAddr;
      tp.frameSize := fSize;
      tp.annotation := ann;
      tr.tp[tr.count] := tp;
      INC(tr.count)
    END
  END addTP;


  PROCEDURE* traceStart(stackframeBase, excRetVal: INTEGER): INTEGER;
  (* calculate the start/re-start addr for tracing above an exc stack frame *)
    CONST StackAlign = 9; (* in stacked PSR *)
    VAR startAddr: INTEGER;
  BEGIN
    startAddr := stackframeBase + StateContextSize;
    IF ~(EXC_RET_FType IN BITS(excRetVal)) THEN (* FP context *)
      startAddr := startAddr + FPcontextSize;
      IF ~(EXC_RET_DCRS IN (BITS(excRetVal))) THEN (* additional FP context *)
        startAddr := startAddr + FPadditionalSize;
      END
    END;
    IF SYSTEM.BIT(stackframeBase + PSRoffset, StackAlign) THEN
      INC(startAddr, 4)
    END
    RETURN startAddr
  END traceStart;


  PROCEDURE stacktrace(frameBaseAddr, frameSize: INTEGER; VAR trace: Trace);
    VAR
      savedLR, excFrameBase, codeAddr, lineNo: INTEGER;
      procEntry, aboveWord: INTEGER;
      done, error: BOOLEAN;
  BEGIN
    done := FALSE; error := FALSE;
    WHILE ~done & ~error & (trace.count < TraceDepth) DO
      (* each iteration starts with sp = base addr of a procedure stack frame *)
      (* and frameSize = size of that stack frame *)

      (* read saved LR from current frame *)
      (* LR is always on top of the frame *)
      SYSTEM.GET(frameBaseAddr + frameSize - 4, savedLR);

      IF isExcReturn(savedLR) THEN
        (* savedLR is EXC_RETURN: hw exception frame above current proc frame *)
        excFrameBase := frameBaseAddr + frameSize;

        (* check for MSP to PSP transition *)
        SYSTEM.GET(excFrameBase, aboveWord);
        IF aboveWord = StackSeal THEN (* MSP exhausted, exception frame is on PSP *)
          (* ASM
            mrs r11, psp -> excFrameBase
          END ASM *)
          (* +asm *)
          SYSTEM.EMIT(0F3EF8B09H);  (* mrs r11, PSP *)
          excFrameBase := SYSTEM.REG(11);  (* r11 -> excFrameBase *)
          (* -asm *)
        END;
        (* look up interrupted procedure via codeAddr *)
        (* to calculate frameSize to prep the next iteration *)
        SYSTEM.GET(excFrameBase + PCoffset, codeAddr);
        ProgData.FindEntry(codeAddr, procEntry);
        error := procEntry = 0;
        IF ~error THEN
          ProgData.GetCodeAddr(procEntry, codeAddr);
          frameBaseAddr := traceStart(excFrameBase, savedLR); (* base SP of interrupted proc *)
          getFrameSize(codeAddr, frameSize);
          error := frameSize = 0;
          IF ~error THEN
            addTP(trace, codeAddr, 0, frameBaseAddr, frameSize, AnnStackframe);
          END
        END

      ELSE
        (* saved LR is normal code address *)
        (* while in frame defined by frameBaseAddr and frameSize *)
        (* we create the TP for the caller *)
        error := ~ODD(savedLR); (* LR must be thumb code *)
        IF ~error THEN
          DEC(savedLR);
          (* check for stack seal above - end of call chain *)
          SYSTEM.GET(frameBaseAddr + frameSize, aboveWord);
          done := aboveWord = StackSeal;
          IF ~done THEN (* no stack seal yet, continue *)
            (* look up caller procedure via savedLR *)
            ProgData.FindEntry(savedLR, procEntry);
            done := procEntry = 0;
            IF ~done THEN (* still in address range of procs in .res meta data *)
              ProgData.GetCodeAddr(procEntry, codeAddr);
              frameBaseAddr := frameBaseAddr + frameSize;
              getFrameSize(codeAddr, frameSize);
              error := frameSize = 0;
              IF ~error THEN
                getLineNo(savedLR, lineNo);
                addTP(trace, savedLR - 4, lineNo, frameBaseAddr, frameSize, AnnNone)
              END
            END
          END
        END
      END
    END;
    trace.more := ~(done OR error);
    trace.error := error
  END stacktrace;


  PROCEDURE CreateTrace*(er: RuntimeErrors.ErrorDesc; VAR tr: Trace);
    VAR procEntry, codeAddr, frameSize, sp: INTEGER;
  BEGIN
    (* first trace point: the faulting location *)
    tr.count := 0;
    tr.more := FALSE;
    tr.error := FALSE;
    addTP(tr, er.errAddr, er.errLineNo, 0, 0, AnnNone);

    (* find faulting procedure and read its prologue *)
    ProgData.FindEntry(er.errAddr, procEntry);
    IF procEntry # 0 THEN
      ProgData.GetCodeAddr(procEntry, codeAddr);
      getFrameSize(codeAddr, frameSize);
      IF frameSize > 0 THEN
        (* skip error exception frame *)
        sp := traceStart(er.stackframeBase, er.excRetVal);
        (* walk the stack *)
        stacktrace(sp, frameSize, tr)
      END
    END
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
