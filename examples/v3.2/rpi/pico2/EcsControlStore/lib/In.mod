MODULE In;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Input via two Texts.Reader, one per core.
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Cores, Texts;

  CONST
    NumTerminals = 2;

    (* error codes, from Texts *)
    NoError* = Texts.NoError;
    BufferOverflow* = Texts.BufferOverflow;
    SyntaxError* = Texts.SyntaxError;
    OutOfLimits* = Texts.OutOfLimits;
    NoInput* = Texts.NoInput;
    FifoOverrun* = Texts.FifoOverrun;


  VAR
    readerHandles: ARRAY NumTerminals OF INTEGER;


  PROCEDURE Open*(rh: INTEGER);
  BEGIN
    readerHandles[Cores.CoreId()] := rh
  END Open;


  PROCEDURE String*(VAR str: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN
    Texts.ReadString(readerHandles[Cores.CoreId()], str, res)
  END String;


  PROCEDURE Int*(VAR int, res: INTEGER);
  BEGIN
    Texts.ReadInt(readerHandles[Cores.CoreId()], int, res)
  END Int;

BEGIN
  readerHandles[0] := Texts.NumReaders; readerHandles[1] := Texts.NumReaders
END In.
