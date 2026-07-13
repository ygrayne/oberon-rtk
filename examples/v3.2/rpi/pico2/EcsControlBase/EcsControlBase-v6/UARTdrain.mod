MODULE UARTdrain;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v6
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, UART, Exceptions;


  CONST
    TxIntBit = UART.IMSC_TXIM;


  PROCEDURE* Full*(dev: UART.Device): BOOLEAN;
    RETURN SYSTEM.BIT(dev.FR, UART.FR_TXFF)
  END Full;


  PROCEDURE* Put*(dev: UART.Device; ch: CHAR);
  BEGIN
    SYSTEM.PUT(dev.TDR, ch)
  END Put;


  PROCEDURE* EnableTxInt*(dev: UART.Device);
  BEGIN
    SYSTEM.PUT(dev.IMSC + BASE.ASET, {TxIntBit})
  END EnableTxInt;


  PROCEDURE* ClearTxInt*(dev: UART.Device);
  BEGIN
    SYSTEM.PUT(dev.ICR + BASE.ASET, {TxIntBit})
  END ClearTxInt;


  PROCEDURE Kick*(dev: UART.Device);
  BEGIN
    Exceptions.SetPendingInt(dev.irqNo)
  END Kick;

END UARTdrain.
