MODULE BUFstr;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v0
  --
  String output buffer via TextIO.Writer
  Implemented as virtual device, same output API as UARTstr
  Note: device definition and usage API in the same module, unlike UART and UARTstr
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO;

  CONST
    BufSize* = 256;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      buf: ARRAY BufSize OF CHAR;
      ix: INTEGER
    END;


  PROCEDURE* PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: Device; i: INTEGER;
  BEGIN
    dev0 := dev(Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE (i < numChar) & (dev0.ix < BufSize) DO
      dev0.buf[dev0.ix] := s[i];
      INC(i); INC(dev0.ix)
    END
  END PutString;


  PROCEDURE* GetString*(dev: TextIO.Device; VAR s: ARRAY OF CHAR; VAR numChar, res: INTEGER);
    VAR dev0: Device;
  BEGIN
    dev0 := dev(Device);
    numChar := 0; res := TextIO.NoError;
    WHILE (numChar < dev0.ix) & (numChar < LEN(s)) DO
      s[numChar] := dev0.buf[numChar];
      INC(numChar)
    END;
    IF dev0.ix > numChar THEN
      (* should not happen if communicating buffer sizes are well-designed *)
      res := TextIO.BufferOverflow
    END
  END GetString;


  PROCEDURE* Reset*(dev: TextIO.Device);
    VAR dev0: Device;
  BEGIN
    dev0 := dev(Device);
    dev0.ix := 0
  END Reset;

END BUFstr.
