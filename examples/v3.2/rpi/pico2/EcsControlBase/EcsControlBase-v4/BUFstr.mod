MODULE BUFstr;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v4
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

  IMPORT TextIO, Errors;

  CONST
    BufSize* = 256;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      buf: ARRAY BufSize OF CHAR;
      writeIx: INTEGER;
      readIx: INTEGER
    END;


  PROCEDURE* PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: Device; i: INTEGER;
  BEGIN
    dev0 := dev(Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE (i < numChar) & (dev0.writeIx < BufSize) DO
      dev0.buf[dev0.writeIx] := s[i];
      INC(i); INC(dev0.writeIx)
    END
  END PutString;


  PROCEDURE* Reset*(dev: TextIO.Device);
    VAR dev0: Device;
  BEGIN
    dev0 := dev(Device);
    dev0.writeIx := 0
  END Reset;


  PROCEDURE* InitGetChar*(dev: TextIO.Device; VAR numChar: INTEGER);
    VAR dev0: Device;
  BEGIN
    dev0 := dev(Device);
    dev0.readIx := 0;
    numChar := dev0.writeIx
  END InitGetChar;


  PROCEDURE* GetNextChar*(dev: TextIO.Device; VAR ch: CHAR; VAR last: BOOLEAN);
    VAR dev0: Device;
  BEGIN
    dev0 := dev(Device);
    ASSERT(dev0.readIx < dev0.writeIx, Errors.PreCond);
    ch := dev0.buf[dev0.readIx];
    INC(dev0.readIx);
    last := dev0.readIx = dev0.writeIx
  END GetNextChar;

END BUFstr.
