MODULE UARTdrain;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v5
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, UART;

  CONST
    TxIntBit = UART.IMSC_TXIM;


  PROCEDURE* Put*(dev: UART.Device; ch: CHAR);
  BEGIN
    SYSTEM.PUT(dev.TDR, ch)
  END Put;


  PROCEDURE* EnableTxInt*(dev: UART.Device);
  BEGIN
    SYSTEM.PUT(dev.IMSC + BASE.ASET, {TxIntBit})
  END EnableTxInt;


  PROCEDURE* DisableTxInt*(dev: UART.Device);
  BEGIN
    SYSTEM.PUT(dev.IMSC + BASE.ACLR, {TxIntBit})
  END DisableTxInt;


  PROCEDURE* ClearTxInt*(dev: UART.Device);
  BEGIN
    SYSTEM.PUT(dev.ICR + BASE.ASET, {TxIntBit})
  END ClearTxInt;


  PROCEDURE* TxIntEnabled*(dev: UART.Device): BOOLEAN;
    RETURN SYSTEM.BIT(dev.IMSC, TxIntBit)
  END TxIntEnabled;


  PROCEDURE* IsTxInt*(dev: UART.Device): BOOLEAN;
    RETURN SYSTEM.BIT(dev.MIS, TxIntBit)
  END IsTxInt;

END UARTdrain.
