MODULE UARTd;
(**
  Oberon RTK Framework
  * initialisation of device data structure
  * configure IO bank and pads, baudrate
  * enable physical device
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2023 Gray gray@grayraven.org
**)

  IMPORT SYSTEM, Error, MCU := MCU2, GPIO, Resets, TextIO;

  CONST
    UART0* = 0;
    UART1* = 1;

    Enabled* = 1;
    Disabled* = 0;
    None* = 0;

    Wlen8* = 3;
    Wlen7* = 2;
    Wlen6* = 1;
    Wlen5* = 0;

    Stop1* = 0;
    Stop2* = 1;

    CR_RXE = 9;
    CR_TXE = 8;
    CR_UARTEN = 0;

    FR_TXFE* = 7;  (* transmit FIFO empty *)
    FR_RXFF* = 6;  (* receive FIFO full *)
    FR_TXFF* = 5;  (* transmit FIFO full *)
    FR_RXFE* = 4;  (* receive FIFO empty *)

    UART0txPinNo = {0, 12, 16, 28};
    UART0rxPinNo = {1, 13, 17, 29};
    UART1txPinNo = {4, 8, 20, 24};
    UART1rxPinNo = {5, 9, 21, 25};
    UARTtxPinNo = UART0txPinNo + UART1txPinNo;
    UARTrxPinNo = UART0rxPinNo + UART1rxPinNo;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartNo*: INTEGER;
      devNo: INTEGER;
      txPinNo, rxPinNo: INTEGER;
      CR, IBRD, FBRD, LCR_H: INTEGER;
      TDR*, RDR*, FR*: INTEGER
    END;


  PROCEDURE Init*(dev: Device; uartNo, txPinNo, rxPinNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Error.PreCond);
    ASSERT(uartNo IN {UART0, UART1});
    ASSERT(txPinNo IN UARTtxPinNo);
    ASSERT(rxPinNo IN UARTrxPinNo);
    dev.uartNo := uartNo;
    dev.txPinNo := txPinNo;
    dev.rxPinNo := rxPinNo;
    CASE uartNo OF
      UART0: base := MCU.UART0_Base; dev.devNo := MCU.RESETS_UART0
    | UART1: base := MCU.UART1_Base; dev.devNo := MCU.RESETS_UART1
    END;
    dev.TDR   := base + MCU.UART_DR_Offset;
    dev.RDR   := base + MCU.UART_DR_Offset;
    dev.FR    := base + MCU.UART_FR_Offset;
    dev.IBRD  := base + MCU.UART_IBRD_Offset;
    dev.FBRD  := base + MCU.UART_FBRD_Offset;
    dev.CR    := base + MCU.UART_CR_Offset;
    dev.LCR_H := base + MCU.UART_LCR_H_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; baudrate: INTEGER);
  (* basic configuration: 8 bits, 1 stop bit, no parity, fifos enabled *)
    VAR x, intDiv, fracDiv: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Error.PreCond);

    (* config UART device *)
    Resets.Release(dev.devNo);
    SYSTEM.PUT(dev.CR, {}); (* disable *)

    x := (MCU.PeriClkFreq * 8) DIV baudrate;
    intDiv := LSR(x, 7);
    IF intDiv = 0 THEN
      intDiv := 1; fracDiv := 0
    ELSIF intDiv >= 65535 THEN
      intDiv := 65535; fracDiv := 0
    ELSE
      fracDiv := ((intDiv MOD 0100H) + 1) DIV 2
    END;
    SYSTEM.PUT(dev.IBRD, intDiv);
    SYSTEM.PUT(dev.FBRD, fracDiv);

    (* note: LCR_H cfg MUST appear after baudrate cfg, 4.2.7.1, p426*)
    x := 0;
    BFI(x, 6, 5, Wlen8);
    BFI(x, 4, Enabled); (* enable fifos *)
    SYSTEM.PUT(dev.LCR_H, x);

    (* config GPIO device *)
    GPIO.SetFunction(dev.txPinNo, GPIO.Fuart);
    GPIO.SetFunction(dev.rxPinNo, GPIO.Fuart)
  END Configure;


  PROCEDURE ConfigureRaw*(dev: Device; lcrhValue: SET);
  (* extended configuration *)
  BEGIN
    ASSERT(dev # NIL, Error.PreCond);
    SYSTEM.PUT(dev.LCR_H, lcrhValue)
  END ConfigureRaw;


  PROCEDURE ConfigPads*(dev: Device; cfg: GPIO.PadConfig);
  (* if a non-reset = non-default pad config shall be used *)
  BEGIN
    ASSERT(dev # NIL, Error.PreCond);
    GPIO.ConfigurePad(dev.txPinNo, cfg);
    GPIO.ConfigurePad(dev.rxPinNo, cfg)
  END ConfigPads;


  PROCEDURE Enable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Error.PreCond);
    SYSTEM.PUT(dev.CR, {CR_UARTEN, CR_RXE, CR_TXE})
  END Enable;

  PROCEDURE Disable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Error.PreCond);
    SYSTEM.PUT(dev.CR, {})
  END Disable;

END UARTd.
