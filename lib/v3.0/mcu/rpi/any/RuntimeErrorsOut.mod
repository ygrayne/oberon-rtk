MODULE RuntimeErrorsOut;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Human-readable output for run-time errors.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    RuntimeErrors, Stacktrace, Cores, TextIO, Texts, Errors, ProgData, Config;

  CONST
    NumCores = Config.NumCoresUsed;

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
    IF ann = Stacktrace.AnnStackframe THEN
      Texts.WriteString(W, "  --- exc ---"); Texts.WriteLn(W)
    END
  END printAnnotation;


  PROCEDURE PrintStacktrace*(tr: Stacktrace.Trace);
    VAR
      i, modEntryAddr, procEntryAddr, startSeqAddr: INTEGER;
      moduleName, procName: Name;
      tp: Stacktrace.TracePoint;
      We: TextIO.Writer;
  BEGIN
    We := W[Cores.CoreId()];
    startSeqAddr := Config.ResMem.start - 8;
    IF tr.count > 1 THEN
      Texts.WriteString(We, "trace:"); Texts.WriteLn(We);
      i := 0;
      WHILE i < tr.count DO
        tp := tr.tp[i];
        printAnnotation(We, tp.annotation);
        IF tp.address # startSeqAddr THEN
          ProgData.FindProcEntries(tp.address, modEntryAddr, procEntryAddr);
          ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
        ELSE
          moduleName := "start"; procName := "sequence";
        END;
        printTraceLine(We, moduleName, procName, tp.address, tp.lineNo, tp.stackAddr);
        INC(i)
      END;
      IF tr.more THEN
        Texts.WriteString(We, "  --- more ---"); Texts.WriteLn(We)
      END
    ELSE
      Texts.WriteString(We, "no trace"); Texts.WriteLn(We)
    END
  END PrintStacktrace;


  PROCEDURE printReg(W: TextIO.Writer; label: ARRAY OF CHAR; value: INTEGER);
  BEGIN
    Texts.Write(W, " "); Texts.WriteString(W, label);
    Texts.WriteHex(W, value, 10);
    Texts.WriteLn(W)
  END printReg;


  PROCEDURE PrintStackedRegs*(stackedRegs: Stacktrace.StackedRegs);
    VAR We: TextIO.Writer;
  BEGIN
    We := W[Cores.CoreId()];
    Texts.WriteString(We, "stacked registers:"); Texts.WriteLn(We);
    printReg(We, "xpsr:", stackedRegs.xpsr);
    printReg(We, "  pc:", stackedRegs.pc);
    printReg(We, "  lr:", stackedRegs.lr);
    printReg(We, " r12:", stackedRegs.r12);
    printReg(We, "  r3:", stackedRegs.r3);
    printReg(We, "  r2:", stackedRegs.r2);
    printReg(We, "  r1:", stackedRegs.r1);
    printReg(We, "  r0:", stackedRegs.r0);
    printReg(We, "  sp:", stackedRegs.sp)
  END PrintStackedRegs;


  PROCEDURE PrintError*(er: RuntimeErrors.ErrorDesc);
    VAR
      modEntryAddr, procEntryAddr: INTEGER;
      moduleName, procName: Name;
      msg: Errors.String;
      We: TextIO.Writer;
  BEGIN
    We := W[Cores.CoreId()];
    Errors.GetErrorType(er.errType, msg);
    Texts.WriteString(We, msg);
    Texts.WriteString(We, ": "); Texts.WriteInt(We, ABS(er.errCode), 0);
    Texts.WriteString(We, " core: ");
    Texts.WriteInt(We, er.core, 0); Texts.WriteLn(We);
    Errors.GetErrorMsg(er.errType, er.errCode, msg);
    Texts.WriteString(We, msg); Texts.WriteLn(We);
    ProgData.FindProcEntries(er.errAddr, modEntryAddr, procEntryAddr);
    ProgData.GetNames(modEntryAddr, procEntryAddr, moduleName, procName);
    Texts.WriteString(We, moduleName); Texts.Write(We, "."); Texts.WriteString(We, procName);
    Texts.WriteString(We, "  addr: "); Texts.WriteHex(We, er.errAddr, 0);
    IF er.errLineNo > 0 THEN
      Texts.WriteString(We, "  line: "); Texts.WriteInt(We, er.errLineNo, 0)
    END;
    Texts.WriteLn(We)
  END PrintError;


  PROCEDURE PrintLogEntry*(er: RuntimeErrors.ErrorDesc);
    VAR We: TextIO.Writer;
  BEGIN
    We := W[Cores.CoreId()];
    Texts.WriteString(We, "run-time error:");
    Texts.WriteInt(We, er.core, 2);
    Texts.WriteInt(We, er.errType, 2);
    Texts.WriteInt(We, er.errCode, 4);
    Texts.WriteHex(We, er.errAddr, 10);
    Texts.WriteInt(We, er.errLineNo, 6);
    Texts.WriteHex(We, er.stackframeBase, 12);
    Texts.WriteHex(We, er.excRetVal, 12);
    Texts.WriteLn(We)
  END PrintLogEntry;


  (* RuntimeErrors-compatible handler *)

  PROCEDURE ErrorHandler*[0];
  (* print error data and halt *)
    VAR cid: INTEGER; trace: Stacktrace.Trace; regs: Stacktrace.StackedRegs;
  BEGIN
    Cores.GetCoreId(cid);
    PrintLogEntry(RuntimeErrors.ErrorRec[cid]);
    Stacktrace.CreateTrace(RuntimeErrors.ErrorRec[cid], trace);
    Stacktrace.ReadRegisters(RuntimeErrors.ErrorRec[cid], regs);
    PrintError(RuntimeErrors.ErrorRec[cid]);
    PrintStackedRegs(regs);
    PrintStacktrace(trace);
    REPEAT UNTIL FALSE
  END ErrorHandler;


  (* plug a writer to use for error output *)

  PROCEDURE* SetWriter*(cid: INTEGER; Wr: TextIO.Writer);
  BEGIN
    ASSERT(cid < NumCores, Errors.PreCond);
    W[cid] := Wr
  END SetWriter;

END RuntimeErrorsOut.

