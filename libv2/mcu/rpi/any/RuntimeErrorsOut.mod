MODULE RuntimeErrorsOut;
(**
  Oberon RTK Framework v2
  --
  Human-readable output for exceptions.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    RuntimeErrors, TextIO, Texts, Errors, ProgData, Memory;

  CONST
    NumCores = RuntimeErrors.NumCores;

  TYPE
    Name = ProgData.EntryString;

  VAR
    W: ARRAY NumCores OF TextIO.Writer;


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
    IF ann = RuntimeErrors.AnnStackframe THEN
      Texts.WriteString(W, "  --- exc ---"); Texts.WriteLn(W)
    END
  END printAnnotation;


  PROCEDURE PrintStacktrace*(W: TextIO.Writer; tr: RuntimeErrors.Trace; cid: INTEGER);
    VAR
      i, modEntryAddr, procEntryAddr, topMainStackEntry: INTEGER;
      moduleName, procName: Name;
      tp: RuntimeErrors.TracePoint;
  BEGIN
    IF tr.count > 1 THEN
      Texts.WriteString(W, "trace:"); Texts.WriteLn(W);
      i := 0;
      topMainStackEntry := Memory.DataMem[cid].stackStart - 4;
      WHILE i < tr.count DO
        tp := tr.tp[i];
        printAnnotation(W, tp.annotation);
        IF tp.stackAddr < topMainStackEntry THEN
          ProgData.FindProcEntries(tp.address, modEntryAddr, procEntryAddr);
          ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
        ELSE
          moduleName := "Startup"; procName := "Sequence";
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


  PROCEDURE printStackedRegs(W: TextIO.Writer; stackedRegs: RuntimeErrors.StackedRegisters);
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
  END printStackedRegs;


  PROCEDURE printCurrentRegs(W: TextIO.Writer; currentRegs: RuntimeErrors.CurrentRegisters);
  BEGIN
    Texts.WriteString(W, "current registers:"); Texts.WriteLn(W);
    printReg(W, " sp:", currentRegs.sp);
    printReg(W, " lr:", currentRegs.lr);
    printReg(W, " pc:", currentRegs.pc);
    printReg(W, "psr:", currentRegs.xpsr)
  END printCurrentRegs;


  PROCEDURE PrintException*(W: TextIO.Writer; er: RuntimeErrors.ExceptionRec);
    VAR
      modEntryAddr, procEntryAddr: INTEGER;
      moduleName, procName: Name;
      msg: Errors.String;
  BEGIN
    Errors.GetExceptionType(er.excType, msg);
    Texts.WriteString(W, msg);
    Texts.WriteString(W, ": "); Texts.WriteInt(W, ABS(er.code), 0);
    Texts.WriteString(W, " core: ");
    Texts.WriteInt(W, er.core, 0); Texts.WriteLn(W);
    Errors.GetExceptionMsg(er.code, msg);
    Texts.WriteString(W, msg); Texts.WriteLn(W);
    ProgData.FindProcEntries(er.address, modEntryAddr, procEntryAddr);
    ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
    Texts.WriteString(W, moduleName); Texts.Write(W, "."); Texts.WriteString(W, procName);
    Texts.WriteString(W, "  addr: "); Texts.WriteHex(W, er.address, 0);
    IF er.lineNo > 0 THEN
      Texts.WriteString(W, "  ln: "); Texts.WriteInt(W, er.lineNo, 0)
    END;
    Texts.WriteLn(W);
    PrintStacktrace(W, er.trace, er.core);
    printStackedRegs(W, er.stackedRegs);
    printCurrentRegs(W, er.currentRegs)
  END PrintException;


  (* RuntimeErrors-compatible handler *)

  PROCEDURE HandleException*(er: RuntimeErrors.ExceptionRec);
  BEGIN
    IF er.core < NumCores THEN
      PrintException(W[er.core], er)
    END
  END HandleException;

  (* plug a writer *)

  PROCEDURE* SetWriter*(coreId: INTEGER; Wr: TextIO.Writer);
  BEGIN
    ASSERT(coreId < NumCores, Errors.PreCond);
    W[coreId] := Wr
  END SetWriter;

END RuntimeErrorsOut.

