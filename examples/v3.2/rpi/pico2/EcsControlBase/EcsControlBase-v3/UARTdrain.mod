MODULE UARTdrain;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v3
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UART;

  PROCEDURE* PutBytes*(dev: UART.Device; s: ARRAY OF BYTE; pos, num: INTEGER; VAR acc: INTEGER);
  BEGIN
    acc := 0;
    WHILE (acc < num) & ~SYSTEM.BIT(dev.FR, UART.FR_TXFF) DO
      SYSTEM.PUT(dev.TDR, s[pos]);
      INC(pos); INC(acc)
    END
  END PutBytes;

END UARTdrain.
