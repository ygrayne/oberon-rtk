MODULE UARTdrain;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v7
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UART;


  PROCEDURE* Empty*(dev: UART.Device): BOOLEAN;
    RETURN SYSTEM.BIT(dev.FR, UART.FR_TXFE)
  END Empty;

  PROCEDURE* Put*(dev: UART.Device; ch: CHAR);
  BEGIN
    SYSTEM.PUT(dev.TDR, ch)
  END Put;

END UARTdrain.
