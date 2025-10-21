MODULE In;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Input via two TextIO.Reader.
  --
  MCU: MCX-A346
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Cores, Errors, TextIO, Texts;

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
    ASSERT(R0 # NIL, Errors.PreCond);
    R[0] := R0;
    R[1] := R1
  END Open;


  PROCEDURE String*(VAR str: ARRAY OF CHAR; VAR res: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    Texts.ReadString(R[cid], str, res)
  END String;


  PROCEDURE Int*(VAR int, res: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    Texts.ReadInt(R[cid], int, res)
  END Int;

BEGIN
  R[0] := NIL; R[1] := NIL
END In.
