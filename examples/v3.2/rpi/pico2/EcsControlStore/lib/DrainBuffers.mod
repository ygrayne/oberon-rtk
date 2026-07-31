MODULE DrainBuffers;
(**
  Oberon RTK Framework
  Version v4.0
  --
  Implementation of a char ring buffer, based on CharRingBuffer:
  * this module:
    * buffer, state
    * buffer handle management
  * CharRingBuffer: algorithm
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT CharRingBuffer, Errors;

  CONST
    BufSize* = 1024;
    NumDevices = 4;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      handle*: INTEGER;
      buf: ARRAY BufSize OF CHAR;
      state: CharRingBuffer.State
    END;

  VAR
    Devices*: ARRAY NumDevices OF Device;


  PROCEDURE Init*(dev: Device; bufHandle: INTEGER);
  BEGIN
    ASSERT((bufHandle >= 0) & (bufHandle < NumDevices), Errors.PreCond);
    ASSERT((Devices[bufHandle] = NIL) OR (Devices[bufHandle] = dev), Errors.ConsCheck);
    dev.handle := bufHandle;
    CharRingBuffer.Init(dev.state, BufSize);
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


  PROCEDURE Full*(bufHandle: INTEGER): BOOLEAN;
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    RETURN CharRingBuffer.Full(dev.state)
  END Full;


  PROCEDURE Empty*(bufHandle: INTEGER): BOOLEAN;
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    RETURN CharRingBuffer.Empty(dev.state)
  END Empty;


  PROCEDURE Count*(bufHandle: INTEGER): INTEGER;
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    RETURN CharRingBuffer.Count(dev.state)
  END Count;


  PROCEDURE Put*(bufHandle: INTEGER; ch: CHAR);
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    CharRingBuffer.Put(dev.state, dev.buf, ch)
  END Put;


  PROCEDURE Get*(bufHandle: INTEGER; VAR ch: CHAR);
    VAR dev: Device;
  BEGIN
    dev := Devices[bufHandle];
    CharRingBuffer.Get(dev.state, dev.buf, ch)
  END Get;


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
END DrainBuffers.
