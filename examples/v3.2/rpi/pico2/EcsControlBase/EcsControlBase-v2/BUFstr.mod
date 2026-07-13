MODULE BUFstr;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v2
  --
  String output into a buffer via a 'TextIO.Writer'.
  Virtual output device: the same output API as 'UARTstr', the buffer being
  a ring buffer ('RingBuffer'); this device is the producer end of it.
  --
  * 'PutString' appends the characters to the ring (producer end). A full
    ring drops the remaining characters -- overflow, to be surfaced as a
    disturbance (the output is sized to fit in steady state by design).
  * the consumer end is drained elsewhere (eg. by 'UARTdrain') straight
    from the same 'RingBuffer'; this module is the formatting/producer side
    only, decoupled from the transport.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, RingBuffer;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD (TextIO.DeviceDesc)
      ring: RingBuffer.Buffer
    END;


  PROCEDURE* Init*(dev: Device; ring: RingBuffer.Buffer);
  BEGIN
    dev.ring := ring
  END Init;


  PROCEDURE PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: Device; i: INTEGER;
  BEGIN
    dev0 := dev(Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE (i < numChar) & ~(RingBuffer.Full(dev0.ring)) DO (* if ring full, the rest is dropped *)
      RingBuffer.Put(dev0.ring, s[i]);
      INC(i)
    END
  END PutString;

END BUFstr.
