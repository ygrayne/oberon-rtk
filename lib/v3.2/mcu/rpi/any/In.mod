MODULE In;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Input via two TextIO.Reader.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Cores, TextIO, Texts;

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


  PROCEDURE Open*(Rt: TextIO.Reader);
  BEGIN
    R[Cores.CoreId()] := Rt
  END Open;


  PROCEDURE String*(VAR str: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN
    Texts.ReadString(R[Cores.CoreId()], str, res)
  END String;


  PROCEDURE Int*(VAR int, res: INTEGER);
  BEGIN
    Texts.ReadInt(R[Cores.CoreId()], int, res)
  END Int;

BEGIN
  R[0] := NIL; R[1] := NIL
END In.
