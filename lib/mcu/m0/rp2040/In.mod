MODULE In;
(**
  Oberon RTK Framework
  Input from core-dedicated serial Terminal
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, TextIO, Texts;

  CONST
    NumTerminals = 2;

    (* error codes, from TextIO *)
    NoError* = TextIO.NoError;
    BufferOverflow* = TextIO.BufferOverflow;
    SyntaxError* = TextIO.SyntaxError;
    OutOfLimits* = TextIO.OutOfLimits;
    NoInput* = TextIO.NoInput;
    FifoOverrun* = TextIO.FifoOverrun;


  VAR
    R: ARRAY NumTerminals OF TextIO.Reader;

  PROCEDURE Open*(R0, R1: TextIO.Reader);
  BEGIN
    R[0] := R0;
    R[1] := R1
  END Open;


  PROCEDURE String*(VAR str: ARRAY OF CHAR; VAR res: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.ReadString(R[cid], str, res)
  END String;


  PROCEDURE Int*(VAR int, res: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Texts.ReadInt(R[cid], int, res)
  END Int;

BEGIN
  R[0] := NIL; R[1] := NIL
END In.

