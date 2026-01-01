MODULE Out;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Output via TextIO.Writer.
  --
  MCU: MCXA346
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, Texts, Errors;

  CONST
    NumTerminals = 1;

  VAR
    W*: ARRAY NumTerminals OF TextIO.Writer; (* module var ok: read only *)


  PROCEDURE* Open*(W0: TextIO.Writer);
  BEGIN
    ASSERT(W0 # NIL, Errors.PreCond);
    W[0] := W0
  END Open;


  PROCEDURE Char*(ch: CHAR);
  BEGIN
    Texts.Write(W[0], ch)
  END Char;


  PROCEDURE String*(s: ARRAY OF CHAR);
  BEGIN
    Texts.WriteString(W[0], s)
  END String;


  PROCEDURE Ln*;
  BEGIN
    Texts.WriteLn(W[0])
  END Ln;


  PROCEDURE Int*(n, width: INTEGER);
  BEGIN
    Texts.WriteInt(W[0], n, width)
  END Int;


  PROCEDURE Hex*(n, width: INTEGER);
  BEGIN
    Texts.WriteHex(W[0], n, width)
  END Hex;


  PROCEDURE Bin*(n, width: INTEGER);
  BEGIN
    Texts.WriteBin(W[0], n, width)
  END Bin;


  PROCEDURE Flush*;
  BEGIN
    Texts.FlushOut(W[0])
  END Flush;

BEGIN
  W[0] := NIL;
END Out.
