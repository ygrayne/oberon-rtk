MODULE In;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Input via TextIO.Reader.
  --
  MCU: MCXA346
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, Texts;

  CONST
    NumTerminals = 1;

    (* error codes, from TextIO *)
    NoError* = TextIO.NoError;
    BufferOverflow* = TextIO.BufferOverflow;
    SyntaxError* = TextIO.SyntaxError;
    OutOfLimits* = TextIO.OutOfLimits;
    NoInput* = TextIO.NoInput;
    FifoOverrun* = TextIO.FifoOverrun;


  VAR
    R: ARRAY NumTerminals OF TextIO.Reader;

  PROCEDURE Open*(R0: TextIO.Reader);
  BEGIN
    R[0] := R0
  END Open;


  PROCEDURE String*(VAR str: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN
    Texts.ReadString(R[0], str, res)
  END String;


  PROCEDURE Int*(VAR int, res: INTEGER);
  BEGIN
    Texts.ReadInt(R[0], int, res)
  END Int;

BEGIN
  R[0] := NIL
END In.
