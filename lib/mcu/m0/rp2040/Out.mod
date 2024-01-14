MODULE Out;
(**
  Oberon RTK Framework
  Output to core-dedicated serial Terminal => UART
  --
  Copyright (c) 2020-2023 Gray gray@grayraven.org
**)

  IMPORT SYSTEM, MCU := MCU2, TextIO, Texts;

  CONST
    NumTerminals = 2;

  VAR
    W: ARRAY NumTerminals OF TextIO.Writer; (* module var ok: read only *)


  PROCEDURE Open*(W0, W1: TextIO.Writer);
  BEGIN
    W[0] := W0;
    W[1] := W1
  END Open;


  PROCEDURE Char*(ch: CHAR);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.Write(W[cid], ch)
  END Char;


  PROCEDURE String*(s: ARRAY OF CHAR);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.WriteString(W[cid], s)
  END String;


  PROCEDURE Ln*;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.WriteLn(W[cid])
  END Ln;


  PROCEDURE Int*(n, width: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.WriteInt(W[cid], n, width)
  END Int;


  PROCEDURE Hex*(n, width: INTEGER);
   VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.WriteHex(W[cid], n, width)
  END Hex;


  PROCEDURE Bin*(n, width: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.WriteBin(W[cid], n, width)
  END Bin;

END Out.