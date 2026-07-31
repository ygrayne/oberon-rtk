MODULE PrintBuffers;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Implementation of a linear string buffer, based on StrBuffer:
  * this module:
    * buffer, state
    * Texts.mod Writer/Reader-compatible API
    * buffer handle management
  * StrBuffer: algorithm
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT StrBuffer, Errors;

  CONST
    BufSize* = 128;
    NumDevices = 4;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      handle*: INTEGER;
      buf: ARRAY BufSize OF CHAR;
      state: StrBuffer.State
    END;

  VAR
    Devices*: ARRAY NumDevices OF Device;


  PROCEDURE Init*(dev: Device; bufHandle: INTEGER);
  BEGIN
    ASSERT((bufHandle >= 0) & (bufHandle < NumDevices), Errors.PreCond);
    ASSERT((Devices[bufHandle] = NIL) OR (Devices[bufHandle] = dev), Errors.ConsCheck);
    dev.handle := bufHandle;
    StrBuffer.Init(dev.state);
    Devices[bufHandle] := dev
  END Init;


  PROCEDURE* IsValid*(dev: Device; bufHandle: INTEGER): BOOLEAN;
    RETURN (dev # NIL) &
           (bufHandle >= 0) & (bufHandle < NumDevices) &
           (Devices[bufHandle] = dev)
  END IsValid;


  PROCEDURE* Bound*(bufHandle: INTEGER): BOOLEAN;
    RETURN (bufHandle >= 0) & (bufHandle < NumDevices) &
           (Devices[bufHandle] # NIL)
  END Bound;


  PROCEDURE PutString*(bufHandle: INTEGER; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    StrBuffer.Put(dev.state, dev.buf, s, numChar)
  END PutString;


  PROCEDURE GetString*(bufHandle: INTEGER; VAR s: ARRAY OF CHAR; VAR numChar: INTEGER);
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    StrBuffer.Get(dev.state, dev.buf, s, numChar);
  END GetString;


  PROCEDURE Reset*(bufHandle: INTEGER);
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    StrBuffer.Reset(dev.state)
  END Reset;


  PROCEDURE* init;
    VAR bufHandle: INTEGER;
  BEGIN
    bufHandle := 0;
    WHILE bufHandle < NumDevices DO
      Devices[bufHandle] := NIL;
      INC(bufHandle)
    END
  END init;

BEGIN
  init
END PrintBuffers.
