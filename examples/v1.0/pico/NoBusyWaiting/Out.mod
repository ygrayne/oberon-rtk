MODULE Out;
(**
  Oberon RTK Framework
  Output to thread-dedicated serial terminal
  Custom module for example 'NoBusyWaiting'
  --
  For two threads only, tid = 0 and 1
  Only use on one core!
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Kernel, TextIO, Texts;

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
    VAR tid: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    ASSERT(tid IN {0, 1});
    Texts.Write(W[tid], ch)
  END Char;


  PROCEDURE String*(s: ARRAY OF CHAR);
    VAR tid: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    ASSERT(tid IN {0, 1});
    Texts.WriteString(W[tid], s)
  END String;


  PROCEDURE Ln*;
    VAR tid: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    ASSERT(tid IN {0, 1});
    Texts.WriteLn(W[tid])
  END Ln;


  PROCEDURE Int*(n, width: INTEGER);
    VAR tid: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    ASSERT(tid IN {0, 1});
    Texts.WriteInt(W[tid], n, width)
  END Int;


  PROCEDURE Hex*(n, width: INTEGER);
   VAR tid: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    ASSERT(tid IN {0, 1});
    Texts.WriteHex(W[tid], n, width)
  END Hex;


  PROCEDURE Bin*(n, width: INTEGER);
    VAR tid: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    ASSERT(tid IN {0, 1});
    Texts.WriteBin(W[tid], n, width)
  END Bin;

END Out.
