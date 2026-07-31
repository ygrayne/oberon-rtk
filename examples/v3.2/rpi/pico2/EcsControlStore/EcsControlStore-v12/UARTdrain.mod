MODULE UARTdrain;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UART;


  PROCEDURE* Full*(uartHandle: INTEGER): BOOLEAN;
    VAR dev: UART.Device;
  BEGIN
    dev := UART.Devices[uartHandle];
    RETURN SYSTEM.BIT(dev.FR, UART.FR_TXFF)
  END Full;


  PROCEDURE* Put*(uartHandle: INTEGER; ch: CHAR);
    VAR dev: UART.Device;
  BEGIN
    dev := UART.Devices[uartHandle];
    SYSTEM.PUT(dev.TDR, ch)
  END Put;

END UARTdrain.
