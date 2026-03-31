MODULE Out;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Output via TextIO.Writer.
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Errors, TextIO, Texts;

  VAR
    W*: TextIO.Writer; (* module var ok: read only *)


  PROCEDURE* Open*(W0: TextIO.Writer);
  BEGIN
    ASSERT(W0 # NIL, Errors.PreCond);
    W:= W0
  END Open;


  PROCEDURE Char*(ch: CHAR);
  BEGIN
    Texts.Write(W, ch)
  END Char;


  PROCEDURE String*(s: ARRAY OF CHAR);
  BEGIN
    Texts.WriteString(W, s)
  END String;


  PROCEDURE Ln*;
  BEGIN
    Texts.WriteLn(W)
  END Ln;


  PROCEDURE Int*(n, width: INTEGER);
  BEGIN
    Texts.WriteInt(W, n, width)
  END Int;


  PROCEDURE Hex*(n, width: INTEGER);
  BEGIN
    Texts.WriteHex(W, n, width)
  END Hex;


  PROCEDURE Bin*(n, width: INTEGER);
  BEGIN
    Texts.WriteBin(W, n, width)
  END Bin;


  PROCEDURE Flush*;
  BEGIN
    Texts.FlushOut(W)
  END Flush;

BEGIN
  W := NIL
END Out.
