MODULE Out;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Output via two Texts.Writerm one per core.
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Cores, Texts;

  CONST
    NumTerminals = 2;

  VAR
    writerHandles*: ARRAY NumTerminals OF INTEGER;


  PROCEDURE Open*(wh: INTEGER);
  BEGIN
    writerHandles[Cores.CoreId()] := wh
  END Open;


  PROCEDURE Char*(ch: CHAR);
  BEGIN
    Texts.Write(writerHandles[Cores.CoreId()], ch)
  END Char;


  PROCEDURE String*(s: ARRAY OF CHAR);
  BEGIN
    Texts.WriteString(writerHandles[Cores.CoreId()], s)
  END String;


  PROCEDURE Ln*;
  BEGIN
    Texts.WriteLn(writerHandles[Cores.CoreId()])
  END Ln;


  PROCEDURE Int*(n, width: INTEGER);
  BEGIN
    Texts.WriteInt(writerHandles[Cores.CoreId()], n, width)
  END Int;


  PROCEDURE Hex*(n, width: INTEGER);
  BEGIN
    Texts.WriteHex(writerHandles[Cores.CoreId()], n, width)
  END Hex;


  PROCEDURE Bin*(n, width: INTEGER);
  BEGIN
    Texts.WriteBin(writerHandles[Cores.CoreId()], n, width)
  END Bin;


  PROCEDURE Flush*;
  BEGIN
    Texts.FlushOut(writerHandles[Cores.CoreId()])
  END Flush;

BEGIN
   writerHandles[0] := Texts.NumWriters; writerHandles[1] := Texts.NumWriters
END Out.
