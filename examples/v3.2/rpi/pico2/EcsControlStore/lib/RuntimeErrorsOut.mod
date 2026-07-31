MODULE RuntimeErrorsOut;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Human-readable output for run-time errors.
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    MemMap, RuntimeErrors, Stacktrace, Cores, Texts, Errors, ProgData;

  CONST
    NumCores = MemMap.NumCoresUsed;
    DataCol = 36;

  TYPE
    Name = ProgData.EntryString;

  VAR
    writerHandles: ARRAY NumCores OF INTEGER;


  PROCEDURE nameLength(s: Name): INTEGER;
    VAR l: INTEGER;
  BEGIN
    l := 0;
    WHILE (l < LEN(s)) & (s[l] # 0X) DO INC(l) END;
    RETURN l
  END nameLength;


  PROCEDURE printTraceLine(wh: INTEGER; modName, procName: Name; addr, lineNo, stkAddr, frameSize: INTEGER);
    VAR l: INTEGER;
  BEGIN
    Texts.WriteString(wh, "  "); Texts.WriteString(wh, modName);
    Texts.WriteString(wh, "."); Texts.WriteString(wh, procName);
    l := nameLength(modName) + nameLength(procName) + 1;
    Texts.WriteHex(wh, addr, DataCol - l);
    IF lineNo > 0 THEN
      Texts.WriteInt(wh, lineNo, 6);
    ELSE
      Texts.WriteString(wh, "      ")
    END;
    IF stkAddr > 0 THEN
      Texts.WriteHex(wh, stkAddr, 12);
    END;
    IF frameSize > 0 THEN
      Texts.WriteInt(wh, frameSize, 6);
    END;
    Texts.WriteLn(wh)
  END printTraceLine;


  PROCEDURE printAnnotation(wh: INTEGER; ann: INTEGER);
  BEGIN
    IF ann = Stacktrace.AnnStackframe THEN
      Texts.WriteString(wh, "  --- exc ---"); Texts.WriteLn(wh)
    END
  END printAnnotation;


  PROCEDURE PrintStacktrace*(tr: Stacktrace.Trace);
    VAR
      i, modEntryAddr, procEntryAddr: INTEGER;
      moduleName, procName: Name;
      tp: Stacktrace.TracePoint;
      we: INTEGER;
  BEGIN
    we := writerHandles[Cores.CoreId()];
    IF tr.count > 1 THEN
      Texts.WriteString(we, "trace:                       ");
      Texts.WriteString(we, "code addr    ");
      Texts.WriteString(we, "ln   ");
      Texts.WriteString(we, "frame addr  ");
      Texts.WriteString(we, "fsz ");
      Texts.WriteLn(we);
      i := 0;
      WHILE i < tr.count DO
        tp := tr.tp[i];
        printAnnotation(we, tp.annotation);
        ProgData.FindProcEntries(tp.address, modEntryAddr, procEntryAddr);
        ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
        printTraceLine(we, moduleName, procName, tp.address, tp.lineNo, tp.stackAddr, tp.frameSize);
        INC(i)
      END;
      IF tr.more THEN
        Texts.WriteString(we, "  --- more ---"); Texts.WriteLn(we)
      END
    ELSE
      Texts.WriteString(we, "trace: not captured"); Texts.WriteLn(we)
    END
  END PrintStacktrace;


  PROCEDURE printReg(wh: INTEGER; label: ARRAY OF CHAR; value: INTEGER);
  BEGIN
    Texts.Write(wh, " "); Texts.WriteString(wh, label);
    Texts.WriteHex(wh, value, 10);
    Texts.WriteLn(wh)
  END printReg;


  PROCEDURE PrintStackedRegs*(stackedRegs: Stacktrace.StackedRegs);
    VAR we: INTEGER;
  BEGIN
    we := writerHandles[Cores.CoreId()];
    Texts.WriteString(we, "stacked registers:"); Texts.WriteLn(we);
    printReg(we, "xpsr:", stackedRegs.xpsr);
    printReg(we, "  pc:", stackedRegs.pc);
    printReg(we, "  lr:", stackedRegs.lr);
    printReg(we, " r12:", stackedRegs.r12);
    printReg(we, "  r3:", stackedRegs.r3);
    printReg(we, "  r2:", stackedRegs.r2);
    printReg(we, "  r1:", stackedRegs.r1);
    printReg(we, "  r0:", stackedRegs.r0);
    printReg(we, "  sp:", stackedRegs.sp)
  END PrintStackedRegs;


  PROCEDURE PrintError*(er: RuntimeErrors.ErrorDesc);
    VAR
      modEntryAddr, procEntryAddr: INTEGER;
      moduleName, procName: Name;
      msg: Errors.String;
      we: INTEGER;
  BEGIN
    we := writerHandles[Cores.CoreId()];
    Errors.GetErrorType(er.errType, msg);
    Texts.WriteString(we, msg);
    Texts.WriteString(we, ": "); Texts.WriteInt(we, ABS(er.errCode), 0);
    Texts.WriteString(we, " core: ");
    Texts.WriteInt(we, er.core, 0); Texts.WriteLn(we);
    Errors.GetErrorMsg(er.errType, er.errCode, msg);
    Texts.WriteString(we, msg); Texts.WriteLn(we);
    ProgData.FindProcEntries(er.errAddr, modEntryAddr, procEntryAddr);
    ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
    Texts.WriteString(we, moduleName); Texts.Write(we, "."); Texts.WriteString(we, procName);
    Texts.WriteString(we, "  addr: "); Texts.WriteHex(we, er.errAddr, 0);
    IF er.errLineNo > 0 THEN
      Texts.WriteString(we, "  line: "); Texts.WriteInt(we, er.errLineNo, 0)
    END;
    Texts.WriteLn(we)
  END PrintError;


  PROCEDURE PrintLogEntry*(er: RuntimeErrors.ErrorDesc);
    VAR we: INTEGER;
  BEGIN
    we := writerHandles[Cores.CoreId()];
    Texts.WriteString(we, "run-time error:");
    Texts.WriteInt(we, er.core, 2);
    Texts.WriteInt(we, er.errType, 2);
    Texts.WriteInt(we, er.errCode, 4);
    Texts.WriteHex(we, er.errAddr, 10);
    Texts.WriteInt(we, er.errLineNo, 6);
    Texts.WriteHex(we, er.stackframeBase, 12);
    Texts.WriteHex(we, er.excRetVal, 12);
    Texts.WriteLn(we)
  END PrintLogEntry;


  (* RuntimeErrors-compatible handler *)

  PROCEDURE ErrorHandler*[0];
  (* print error data and halt *)
    VAR cid: INTEGER; trace: Stacktrace.Trace; regs: Stacktrace.StackedRegs;
  BEGIN
    Cores.GetCoreId(cid);
    (*PrintLogEntry(RuntimeErrors.ErrorRec[cid]);*)
    Stacktrace.CreateTrace(RuntimeErrors.ErrorRec[cid], trace);
    Stacktrace.ReadRegisters(RuntimeErrors.ErrorRec[cid], regs);
    PrintError(RuntimeErrors.ErrorRec[cid]);
    PrintStackedRegs(regs);
    PrintStacktrace(trace);
    REPEAT UNTIL FALSE
  END ErrorHandler;


  (* plug a writer to use for error output *)

  PROCEDURE SetWriter*(writerHandle: INTEGER);
  BEGIN
    writerHandles[Cores.CoreId()] := writerHandle
  END SetWriter;

END RuntimeErrorsOut.

