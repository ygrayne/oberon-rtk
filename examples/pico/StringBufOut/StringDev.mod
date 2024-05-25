MODULE StringDev;
(**
  Oberon RTK Framework
  --
  String device
  * TextIO-compatible PutString to write to the device buffer
  * flush the buffer "into" a TextIO.Writer
  * on buffer full, ignore input not fitting
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, Errors;

  CONST
    BufSize* = 32;

  TYPE
    Buffer = ARRAY BufSize OF CHAR;
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      buf: Buffer;
      outW: TextIO.Writer;
      numChars: INTEGER
    END;


  PROCEDURE Init*(dev: Device; outW: TextIO.Writer);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(outW # NIL, Errors.PreCond);
    dev.outW := outW;
    dev.numChars := 0
  END Init;


  PROCEDURE PutString*(dev: TextIO.Device; string: ARRAY OF CHAR; numChars: INTEGER);
    VAR dev0: Device; i, j: INTEGER;
  BEGIN
    dev0 := dev(Device);
    IF dev0.numChars + numChars > BufSize THEN
      numChars := BufSize - dev0.numChars
    END;
    i := 0;
    j := dev0.numChars;
    WHILE i < numChars DO
      dev0.buf[j] := string[i];
      INC(i); INC(j)
    END;
    dev0.numChars := j
  END PutString;


  PROCEDURE FlushOut*(dev: TextIO.Device);
    VAR dev0: Device;
  BEGIN
    dev0 := dev(Device);
    dev0.outW.putString(dev0.outW.dev, dev0.buf, dev0.numChars);
    dev0.numChars := 0
  END FlushOut;

END StringDev.
