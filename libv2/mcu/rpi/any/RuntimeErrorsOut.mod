MODULE RuntimeErrorsOut;
(**
  Oberon RTK Framework v2
  --
  Human-readable output for exceptions.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  Portions copyright (c) 2008-2023 CFB Software, https://www.astrobe.com
  Used with permission.
  Please refer to the licensing conditions as defined at the end of this file.
**)

  IMPORT RuntimeErrors, TextIO, Texts, Errors, ResData;

  CONST
    NoValue = -1;
    NumCores = RuntimeErrors.NumCores;

  TYPE
    Name* = ARRAY 16 OF CHAR;

  VAR
    W: ARRAY NumCores OF TextIO.Writer;


  (* --- Astrobe code begin --- *)

  PROCEDURE* intArrayToChars(a: ARRAY OF BYTE; VAR chars: ARRAY OF CHAR);
  (* from Astrobe library *)
    VAR i: INTEGER;
  BEGIN
    FOR i := 0 TO LEN(a) - 1 DO
      chars[i] := CHR(a[i])
    END
  END intArrayToChars;


  PROCEDURE GetName*(target: INTEGER; VAR modName, procName: Name);
  (* from Astrobe library *)
    CONST ItemSize = 6;
    VAR
      r: ResData.Resource;
      i, index, count, addr, resSize, nItems, recType: INTEGER;
      a: ARRAY 4 OF INTEGER;
      modIdx, foundIdx: INTEGER;
  BEGIN
    ResData.Open(r, ".ref");
    resSize := ResData.Size(r);
    nItems := resSize DIV (ItemSize * 4);
    i := 0;
    addr := 0;
    index := 0;
    modIdx := nItems - 1;
    foundIdx := nItems - 1;
    WHILE (i < nItems) DO
      ResData.GetInt(r, index, recType);
      ResData.GetInt(r, index + 5, addr);
      IF addr > target THEN
        foundIdx := i - 1;
        i := nItems
      ELSIF recType = 0 THEN
        modIdx := i
      END;
      index := index + ItemSize;
      INC(i)
    END;
    count := ResData.GetIntArray(r, modIdx * ItemSize + 1, LEN(a), a);
    intArrayToChars(a, modName);
    count := ResData.GetIntArray(r, foundIdx * ItemSize + 1, LEN(a), a);
    intArrayToChars(a, procName)
  END GetName;

  (* --- Astrobe code end --- *)

  PROCEDURE printStackTrace(W: TextIO.Writer; tr: RuntimeErrors.Trace);
    VAR
      i: INTEGER;
      moduleName, procName: Name;
  BEGIN
    IF tr.count > 1 THEN
      Texts.WriteString(W, "trace:"); Texts.WriteLn(W);
      i := 0;
      GetName(tr.tp[i].address, moduleName, procName);
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
          GetName(tr.tp[i].address, moduleName, procName)
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
    GetName(address, moduleName, procName);
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
