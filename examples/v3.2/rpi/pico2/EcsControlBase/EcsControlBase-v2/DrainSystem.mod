MODULE DrainSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v2
  --
  UART drain system
  Components:
  * locked: UartBinding
  * consumer: TxData
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, UART, UARTdrain, RingBuffer;

  PROCEDURE Run*;
    VAR ring: RingBuffer.Buffer; uartDev: UART.Device; ch: CHAR;
  BEGIN
    ring := C.txData.ring;
    uartDev := C.uartBinding.device;
    WHILE ~(RingBuffer.Empty(ring) OR UARTdrain.Full(uartDev)) DO
      RingBuffer.Get(ring, ch);
      UARTdrain.Put(uartDev, ch)
    END
  END Run;

END DrainSystem.

