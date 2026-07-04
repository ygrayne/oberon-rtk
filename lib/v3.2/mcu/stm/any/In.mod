MODULE In;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Input via TextIO.Reader.
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Errors, TextIO, Texts;

  CONST
    (* error codes, from TextIO *)
    NoError* = TextIO.NoError;
    BufferOverflow* = TextIO.BufferOverflow;
    SyntaxError* = TextIO.SyntaxError;
    OutOfLimits* = TextIO.OutOfLimits;
    NoInput* = TextIO.NoInput;
    FifoOverrun* = TextIO.FifoOverrun;


  VAR R: TextIO.Reader;

  PROCEDURE Open*(R0: TextIO.Reader);
  BEGIN
    ASSERT(R0 # NIL, Errors.PreCond);
    R := R0
  END Open;


  PROCEDURE String*(VAR str: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN
    Texts.ReadString(R, str, res)
  END String;


  PROCEDURE Int*(VAR int, res: INTEGER);
  BEGIN
    Texts.ReadInt(R, int, res)
  END Int;

BEGIN
  R := NIL
END In.
