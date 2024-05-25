MODULE UARTdev;
(**
  Oberon RTK Framework
  --
  UART device
  * initialisation of device data structure
  * configure IO bank and pads, baudrate
  * enable physical device
  Other modules implement the actual specific IO functionality. 'UARTstr'
  implements string/text IO, a module 'UARTdata' could implement binary data IO.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, GPIO, StartUp, TextIO;

  CONST
    UART0* = 0;
    UART1* = 1;

    (* generic values *)
    Enabled* = 1;
    Disabled* = 0;
    None* = 0;

    (* CR bits *)
    CR_RXE = 9;
    CR_TXE = 8;
    CR_UARTEN = 0;

    (* LCR_H bits/values *)
    LCR_H_WLEN1* = 6; (* [6:5] transmit/receive word length *)
    LCR_H_WLEN0* = 5;
    WLENval_8* = 3;
    WLENval_7* = 2;
    WLENval_6* = 1;
    WLENval_5* = 0; (* reset *)
    LCR_H_FEN* = 4;  (* fifo enable, reset = disabled *)
    LCR_H_STP2* = 3; (* two stop bits select, reset = disabled, ie. one stop bit *)
    LCR_H_EPS* = 2;  (* even parity select, reset = disabled, ie. odd parity *)
    LCR_H_PEN* = 1;  (* parity enable, reset = disabled *)

    DataBits8* = WLENval_8;
    DataBits7* = WLENval_7;
    DataBits6* = WLENval_6;
    DataBits5* = WLENval_5;

    StopBits1* = 0;
    StopBits2* = 1;

    FifoOff* = Disabled;
    FifoOn* = Enabled;

    EvenParityOff* = Disabled;
    EvenParityOn* = Enabled;

    ParityOff* = Disabled;
    ParityOn* = Enabled;

    (* FR bits *)
    FR_TXFE* = 7;  (* transmit FIFO empty *)
    FR_RXFF* = 6;  (* receive FIFO full *)
    FR_TXFF* = 5;  (* transmit FIFO full *)
    FR_RXFE* = 4;  (* receive FIFO empty *)

    (* RSR bits *)
    RSR_OR*  = 3;  (* receive fifo overrun *)

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartNo: INTEGER;
      devNo: INTEGER;
      CR, IBRD, FBRD, LCR_H: INTEGER;
      TDR*, RDR*, FR*, RSR*: INTEGER
      (* interrupt/dma regs will be added as/when needed *)
    END;

    DeviceCfg* = RECORD
      baudrate*: INTEGER;
      dataBits*, stopBits*: INTEGER;
      parity*, evenParity*: INTEGER;
      fifo*: INTEGER
    END;


  PROCEDURE Init*(dev: Device; uartNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(uartNo IN {UART0, UART1});
    dev.uartNo := uartNo;
    CASE uartNo OF
      UART0: base := MCU.UART0_Base; dev.devNo := MCU.RESETS_UART0
    | UART1: base := MCU.UART1_Base; dev.devNo := MCU.RESETS_UART1
    END;
    dev.CR    := base + MCU.UART_CR_Offset;
    dev.IBRD  := base + MCU.UART_IBRD_Offset;
    dev.FBRD  := base + MCU.UART_FBRD_Offset;
    dev.LCR_H := base + MCU.UART_LCR_H_Offset;
    dev.TDR   := base + MCU.UART_DR_Offset;
    dev.RDR   := base + MCU.UART_DR_Offset;
    dev.FR    := base + MCU.UART_FR_Offset;
    dev.RSR   := base + MCU.UART_RSR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg; txPinNo, rxPinNo: INTEGER);
  (**
    Basic configuration: 8 bits, 1 stop bit, no parity, fifos enabled
  **)
    VAR x, intDiv, fracDiv: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(cfg.dataBits IN {DataBits5 .. DataBits8}, Errors.PreCond);
    ASSERT(cfg.stopBits IN {StopBits1, StopBits2}, Errors.PreCond);
    ASSERT(cfg.parity IN {ParityOff, ParityOn}, Errors.PreCond);
    ASSERT(cfg.evenParity IN {EvenParityOff, EvenParityOn}, Errors.PreCond);
    ASSERT(cfg.fifo IN {FifoOff, FifoOn}, Errors.PreCond);

    StartUp.ReleaseReset(dev.devNo);
    StartUp.AwaitReleaseDone(dev.devNo);
    SYSTEM.PUT(dev.CR, {}); (* disable *)

    x := (MCU.PeriClkFreq * 8) DIV cfg.baudrate;
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

    (* note: LCR_H cfg MUST appear after baudrate cfg, 4.2.7.1, p426 *)
    x := 0;
    BFI(x, LCR_H_WLEN1, LCR_H_WLEN0, cfg.dataBits);
    BFI(x, LCR_H_FEN, cfg.fifo);
    BFI(x, LCR_H_STP2, cfg.stopBits);
    BFI(x, LCR_H_EPS, cfg.evenParity);
    BFI(x, LCR_H_PEN, cfg.parity);
    SYSTEM.PUT(dev.LCR_H, x);

    GPIO.SetFunction(txPinNo, GPIO.Fuart);
    GPIO.SetFunction(rxPinNo, GPIO.Fuart)
  END Configure;



  PROCEDURE ConfigureRaw*(dev: Device; lcrhValue: SET);
  (**
    Extended configuration: directly write 'LCR_H'
  **)
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.PUT(dev.LCR_H, lcrhValue)
  END ConfigureRaw;


  PROCEDURE Enable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.PUT(dev.CR + MCU.ASET, {CR_UARTEN, CR_RXE, CR_TXE})
  END Enable;


  PROCEDURE Disable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.PUT(dev.CR + MCU.ACLR, {CR_UARTEN, CR_RXE, CR_TXE})
  END Disable;


  PROCEDURE Flags*(dev: Device): SET;
    VAR flags: SET;
  BEGIN
    SYSTEM.GET(dev.FR, flags)
    RETURN flags
  END Flags;

END UARTdev.
