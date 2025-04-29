MODULE RuntimeErrorsOut;
(**
  Oberon RTK Framework v2.1
  --
  Human-readable output for run-time errors.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    RuntimeErrors, Stacktrace, MultiCore, TextIO, Texts, Errors, ProgData, Memory;

  CONST NumCores = RuntimeErrors.NumCores;

  TYPE Name = ProgData.EntryString;

  VAR W: ARRAY NumCores OF TextIO.Writer;


  PROCEDURE nameLength(s: Name): INTEGER;
    VAR l: INTEGER;
  BEGIN
    l := 0;
    WHILE (l < LEN(s)) & (s[l] # 0X) DO INC(l) END;
    RETURN l
  END nameLength;


  PROCEDURE printTraceLine(W: TextIO.Writer; modName, procName: Name; addr, lineNo, stkAddr: INTEGER);
    VAR l: INTEGER;
  BEGIN
    Texts.WriteString(W, "  "); Texts.WriteString(W, modName);
    Texts.WriteString(W, "."); Texts.WriteString(W, procName);
    l := nameLength(modName) + nameLength(procName) + 1;
    Texts.WriteHex(W, addr, 36 - l);
    IF lineNo > 0 THEN
      Texts.WriteInt(W, lineNo, 6);
    ELSE
      Texts.WriteString(W, "      ")
    END;
    IF stkAddr > 0 THEN
      Texts.WriteHex(W, stkAddr, 12);
    END;
    Texts.WriteLn(W)
  END printTraceLine;


  PROCEDURE printAnnotation(W: TextIO.Writer; ann: INTEGER);
  BEGIN
    IF ann = Stacktrace.AnnStackframe THEN
      Texts.WriteString(W, "  --- exc ---"); Texts.WriteLn(W)
    END
  END printAnnotation;


  PROCEDURE PrintStacktrace*(W: TextIO.Writer; tr: Stacktrace.Trace; stackTopAddr: INTEGER);
    VAR
      i, modEntryAddr, procEntryAddr: INTEGER;
      moduleName, procName: Name;
      tp: Stacktrace.TracePoint;
  BEGIN
    IF tr.count > 1 THEN
      Texts.WriteString(W, "trace:"); Texts.WriteLn(W);
      i := 0;
      WHILE i < tr.count DO
        tp := tr.tp[i];
        printAnnotation(W, tp.annotation);
        IF tp.stackAddr < stackTopAddr THEN
          ProgData.FindProcEntries(tp.address, modEntryAddr, procEntryAddr);
          ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
        ELSE
          moduleName := "start"; procName := "sequence";
        END;
        printTraceLine(W, moduleName, procName, tp.address, tp.lineNo, tp.stackAddr);
        INC(i)
      END;
      IF tr.more THEN
        Texts.WriteString(W, "  --- more ---"); Texts.WriteLn(W)
      END
    ELSE
      Texts.WriteString(W, "no trace"); Texts.WriteLn(W)
    END
  END PrintStacktrace;


  PROCEDURE printReg(W: TextIO.Writer; label: ARRAY OF CHAR; value: INTEGER);
  BEGIN
    Texts.Write(W, " "); Texts.WriteString(W, label);
    Texts.WriteHex(W, value, 10);
    Texts.WriteLn(W)
  END printReg;


  PROCEDURE PrintStackedRegs*(W: TextIO.Writer; stackedRegs: Stacktrace.StackedRegs);
  BEGIN
    Texts.WriteString(W, "stacked registers:"); Texts.WriteLn(W);
    printReg(W, "psr:", stackedRegs.xpsr);
    printReg(W, " pc:", stackedRegs.pc);
    printReg(W, " lr:", stackedRegs.lr);
    printReg(W, "r12:", stackedRegs.r12);
    printReg(W, " r3:", stackedRegs.r3);
    printReg(W, " r2:", stackedRegs.r2);
    printReg(W, " r1:", stackedRegs.r1);
    printReg(W, " r0:", stackedRegs.r0);
    printReg(W, " sp:", stackedRegs.sp)
  END PrintStackedRegs;


  PROCEDURE PrintError*(W: TextIO.Writer; er: RuntimeErrors.ErrorDesc);
    VAR
      modEntryAddr, procEntryAddr: INTEGER;
      moduleName, procName: Name;
      msg: Errors.String;
  BEGIN
    Errors.GetErrorType(er.errType, msg);
    Texts.WriteString(W, msg);
    Texts.WriteString(W, ": "); Texts.WriteInt(W, ABS(er.errCode), 0);
    Texts.WriteString(W, " core: ");
    Texts.WriteInt(W, er.core, 0); Texts.WriteLn(W);
    Errors.GetErrorMsg(er.errType, er.errCode, msg);
    Texts.WriteString(W, msg); Texts.WriteLn(W);
    ProgData.FindProcEntries(er.errAddr, modEntryAddr, procEntryAddr);
    ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
    Texts.WriteString(W, moduleName); Texts.Write(W, "."); Texts.WriteString(W, procName);
    Texts.WriteString(W, "  addr: "); Texts.WriteHex(W, er.errAddr, 0);
    IF er.errLineNo > 0 THEN
      Texts.WriteString(W, "  line: "); Texts.WriteInt(W, er.errLineNo, 0)
    END;
    Texts.WriteLn(W)
  END PrintError;


  (* RuntimeErrors-compatible handler *)

  PROCEDURE ErrorHandler*[0];
  (* print error data and halt *)
    VAR cid: INTEGER; trace: Stacktrace.Trace; regs: Stacktrace.StackedRegs;
  BEGIN
    cid := MultiCore.CPUid();
    Stacktrace.CreateTrace(RuntimeErrors.ErrorRec[cid], trace);
    Stacktrace.ReadRegisters(RuntimeErrors.ErrorRec[cid], regs);
    PrintError(W[cid], RuntimeErrors.ErrorRec[cid]);
    PrintStackedRegs(W[cid], regs);
    PrintStacktrace(W[cid], trace, Memory.DataMem[cid].stackStart - 4);
    REPEAT UNTIL FALSE
  END ErrorHandler;

  (* plug a writer to use for error output *)

  PROCEDURE* SetWriter*(coreId: INTEGER; Wr: TextIO.Writer);
  BEGIN
    ASSERT(coreId < NumCores, Errors.PreCond);
    W[coreId] := Wr
  END SetWriter;

END RuntimeErrorsOut.

