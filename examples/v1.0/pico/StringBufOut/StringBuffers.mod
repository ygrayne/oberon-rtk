MODULE StringBuffers;
(**
  Oberon RTK Framework
  --
  Terminal-like string buffers that can be written via a TextIO.Writer
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, StringDev, Errors;

  CONST
    NumBuffers = 2;
    BufSize* = StringDev.BufSize;
    BUF0* = 0;
    BUF1* = 1;

  TYPE
    Ws* = ARRAY NumBuffers OF TextIO.Writer;
    Rs* = ARRAY NumBuffers OF TextIO.Reader;

  VAR
    W*: Ws;
    R*: Rs;


  PROCEDURE InitStrDev*(VAR dev: StringDev.Device; outW: TextIO.Writer);
  BEGIN
    NEW(dev); ASSERT(dev # NIL, Errors.HeapOverflow);
    StringDev.Init(dev, outW)
  END InitStrDev;


  PROCEDURE Open*(bufNo: INTEGER; dev: TextIO.Device; psp: TextIO.PutStringProc; fop: TextIO.FlushOutProc);
  BEGIN
    ASSERT(bufNo IN {BUF0, BUF1}, Errors.PreCond);
    ASSERT(dev # NIL, Errors.PreCond);
    IF W[bufNo] = NIL THEN
      NEW(W[bufNo]); ASSERT(W[bufNo] # NIL, Errors.HeapOverflow);
      TextIO.OpenWriter(W[bufNo], dev, psp);
      TextIO.InstallFlushOutProc(W[bufNo], fop)
    END
  END Open;

BEGIN
  W[0] := NIL; W[1] := NIL;
  R[0] := NIL; R[1] := NIL
END StringBuffers.
