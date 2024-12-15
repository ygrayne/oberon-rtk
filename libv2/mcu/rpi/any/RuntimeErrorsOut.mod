MODULE RuntimeErrorsOut;
(**
  Oberon RTK Framework v2
  --
  Human-readable output for exceptions.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT RuntimeErrors, TextIO, Texts, Errors, ProgData;

  CONST
    NoValue = -1;
    NumCores = RuntimeErrors.NumCores;

  TYPE
    Name = ProgData.EntryString;

  VAR
    W: ARRAY NumCores OF TextIO.Writer;


  PROCEDURE printStackTrace(W: TextIO.Writer; tr: RuntimeErrors.Trace);
    VAR
      i: INTEGER;
      moduleName, procName: Name;
  BEGIN
    IF tr.count > 1 THEN
      Texts.WriteString(W, "trace:"); Texts.WriteLn(W);
      i := 0;
      ProgData.GetNames(tr.tp[i].address, moduleName, procName);
      WHILE i < tr.count DO
        Texts.WriteString(W, "  "); Texts.WriteString(W, moduleName); Texts.WriteString(W, "."); Texts.WriteString(W, procName);
        Texts.WriteString(W, "  "); Texts.WriteHex(W, tr.tp[i].address, 0);
        IF tr.tp[i].lineNo > 0 THEN
          Texts.WriteString(W, "  "); Texts.WriteInt(W, tr.tp[i].lineNo, 4);
        END;
        Texts.WriteLn(W);
        INC(i);
        IF procName = ".init" THEN
          moduleName := "start"; procName := "up"
        ELSE
          ProgData.GetNames(tr.tp[i].address, moduleName, procName)
        END
      END;
      IF tr.tp[i].address = RuntimeErrors.MoreTracePoints THEN
        Texts.Write(W, " "); Texts.WriteString(W, "--- more ---"); Texts.WriteLn(W)
      END
    ELSE
      Texts.WriteString(W, "no trace"); Texts.WriteLn(W)
    END
  END printStackTrace;


  PROCEDURE regOut(W: TextIO.Writer; label: ARRAY OF CHAR; value: INTEGER);
  BEGIN
    Texts.Write(W, " "); Texts.WriteString(W, label);
    Texts.WriteHex(W, value, 10); (*Out.Bin(value, 37);*)
    Texts.WriteLn(W)
  END regOut;


  PROCEDURE printStackedRegs(W: TextIO.Writer; stackedRegs: RuntimeErrors.StackedRegisters);
  BEGIN
    Texts.WriteString(W, "stacked registers:"); Texts.WriteLn(W);
    regOut(W, "  r0:", stackedRegs.r0);
    regOut(W, "  r1:", stackedRegs.r1);
    regOut(W, "  r2:", stackedRegs.r2);
    regOut(W, "  r3:", stackedRegs.r3);
    regOut(W, " r12:", stackedRegs.r12);
    regOut(W, "  lr:", stackedRegs.lr);
    regOut(W, "  pc:", stackedRegs.pc);
    regOut(W, "xpsr:", stackedRegs.xpsr);
    regOut(W, "  sp:", stackedRegs.sp)
  END printStackedRegs;


  PROCEDURE printCurrentRegs(W: TextIO.Writer; currentRegs: RuntimeErrors.CurrentRegisters);
  BEGIN
    Texts.WriteString(W, "current registers:"); Texts.WriteLn(W);
    regOut(W, "  sp:", currentRegs.sp);
    regOut(W, "  lr:", currentRegs.lr);
    regOut(W, "  pc:", currentRegs.pc);
    regOut(W, "xpsr:", currentRegs.xpsr)
  END printCurrentRegs;


  PROCEDURE PrintException*(W: TextIO.Writer; er: RuntimeErrors.ExceptionRec);
    VAR
      code, core, address, lineNo: INTEGER;
      moduleName, procName: Name;
      msg: Errors.String;
  BEGIN
    CASE er OF
      RuntimeErrors.FaultRec:
        code := -er.code;
        core := er.core;
        address := er.address;
        lineNo := NoValue;
    | RuntimeErrors.ErrorRec:
        code := er.code;
        core := er.core;
        address := er.trace.tp[0].address;
        lineNo := er.trace.tp[0].lineNo
    END;
    Errors.GetExceptionType(code, msg);
    Texts.WriteString(W, "exception: "); Texts.WriteString(W, msg);
    Errors.Msg(code, msg);
    Texts.Write(W, " "); Texts.WriteInt(W, code, 0); Texts.WriteString(W, " core: ");
    Texts.WriteInt(W, core, 0); Texts.WriteLn(W);
    Texts.WriteString(W, msg); Texts.WriteLn(W);
    ProgData.GetNames(address, moduleName, procName);
    Texts.WriteString(W, moduleName); Texts.Write(W, "."); Texts.WriteString(W, procName);
    Texts.WriteString(W, "  a: "); Texts.WriteHex(W, address, 0);
    IF lineNo # NoValue THEN
      Texts.WriteString(W, "  ln: "); Texts.WriteInt(W, lineNo, 0)
    END;
    Texts.WriteLn(W);
    CASE er OF
      RuntimeErrors.ErrorRec:
        printStackTrace(W, er.trace);
        printStackedRegs(W, er.stackedRegs);
        printCurrentRegs(W, er.currentRegs)
    | RuntimeErrors.FaultRec:
        printStackedRegs(W, er.stackedRegs);
        printCurrentRegs(W, er.currentRegs)
    END
  END PrintException;


  (* RuntimeErrors-compatible handler *)

  PROCEDURE HandleException*(cpuId: INTEGER;  er: RuntimeErrors.ExceptionRec);
  BEGIN
    ASSERT(cpuId < NumCores, Errors.PreCond);
    PrintException(W[cpuId], er)
  END HandleException;

  (* plug a writer *)

  PROCEDURE SetWriter*(coreId: INTEGER; Wr: TextIO.Writer);
  BEGIN
    ASSERT(coreId < NumCores, Errors.PreCond);
    W[coreId] := Wr
  END SetWriter;

END RuntimeErrorsOut.

