MODULE Out;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Output via two TextIO.Writer.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Cores, TextIO, Texts;

  CONST
    NumTerminals = 2;

  VAR
    W*: ARRAY NumTerminals OF TextIO.Writer; (* module var ok: read only *)


  PROCEDURE Open*(Wt: TextIO.Writer);
  BEGIN
    W[Cores.CoreId()] := Wt
  END Open;


  PROCEDURE Char*(ch: CHAR);
  BEGIN
    Texts.Write(W[Cores.CoreId()], ch)
  END Char;


  PROCEDURE String*(s: ARRAY OF CHAR);
  BEGIN
    Texts.WriteString(W[Cores.CoreId()], s)
  END String;


  PROCEDURE Ln*;
  BEGIN
    Texts.WriteLn(W[Cores.CoreId()])
  END Ln;


  PROCEDURE Int*(n, width: INTEGER);
  BEGIN
    Texts.WriteInt(W[Cores.CoreId()], n, width)
  END Int;


  PROCEDURE Hex*(n, width: INTEGER);
  BEGIN
    Texts.WriteHex(W[Cores.CoreId()], n, width)
  END Hex;


  PROCEDURE Bin*(n, width: INTEGER);
  BEGIN
    Texts.WriteBin(W[Cores.CoreId()], n, width)
  END Bin;


  PROCEDURE Flush*;
  BEGIN
    Texts.FlushOut(W[Cores.CoreId()])
  END Flush;

BEGIN
  W[0] := NIL; W[1] := NIL
END Out.
