MODULE UARTdev;
(**
  Oberon RTK Framework
  --
  UART device
  * initialisation of device data structure
  * configure UART hardware
  * enable physical UART device
  * configure and enable interrupts
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, StartUp, TextIO;

  CONST
    UART0* = 0;
    UART1* = 1;
    NumUART* = 2;

    (* generic values *)
    Enabled* = 1;
    Disabled* = 0;
    None* = 0;

    (* CR bits *)
    CR_RXE = 9;
    CR_TXE = 8;
    CR_UARTEN = 0;

    (* LCR_H bits/values *)
    LCR_H_SPS*      = 7;
    LCR_H_WLEN1*    = 6; (* [6:5] transmit/receive word length *)
    LCR_H_WLEN0*    = 5;
      WLEN_val_8* = 3;
      WLEN_val_7* = 2;
      WLEN_val_6* = 1;
      WLEN_val_5* = 0;    (* reset value *)
    LCR_H_FEN*      = 4;  (* fifo enable, reset = disabled *)
    LCR_H_STP2*     = 3;  (* two stop bits select, reset = disabled, ie. one stop bit *)
    LCR_H_EPS*      = 2;  (* even parity select, reset = disabled, ie. odd parity *)
    LCR_H_PEN*      = 1;  (* parity enable, reset = disabled *)
    LCR_H_BRK*      = 0;

    (* value aliases *)
    DataBits8* = WLEN_val_8;
    DataBits7* = WLEN_val_7;
    DataBits6* = WLEN_val_6;
    DataBits5* = WLEN_val_5;

    (* FR bits *)
    FR_TXFE* = 7;  (* transmit FIFO empty *)
    FR_RXFF* = 6;  (* receive FIFO full *)
    FR_TXFF* = 5;  (* transmit FIFO full *)
    FR_RXFE* = 4;  (* receive FIFO empty *)

    (* RSR bits *)
    RSR_OR*  = 3;  (* receive fifo overrun *)

    (* DMACR bits *)
    DMACR_DMAONERR* = 2;
    DMACR_TXDMAE*   = 1; (* transmit via DMA enabled *)
    DMACR_RXDMAE*   = 0; (* receive via DMA enabled *)

    (* IFLS bits and values: FIFO levels *)
    IFLS_RXIFLSEL1*     = 5;
    IFLS_RXIFLSEL0*     = 3;
      RXIFLSEL_val_18* = 000H; (* 1/8 full:        4 items in fifo *)
      RXIFLSEL_val_28* = 001H; (* 2/8 = 1/4 full:  8 *)
      RXIFLSEL_val_48* = 002H; (* 4/8 = 1/2 full: 16 *)
      RXIFLSEL_val_68* = 003H; (* 6/8 = 3/4 full: 24 *)
      RXIFLSEL_val_78* = 004H; (* 7/8 full:       28 *)
    IFLS_TXIFLSEL1*     = 2;
    IFLS_TXIFLSEL0*     = 0;
      TXIFLSEL_val_18* = 000H; (* 1/8 full:        4 items in fifo *)
      TXIFLSEL_val_28* = 001H; (* 2/8 = 1/4 full:  8 *)
      TXIFLSEL_val_48* = 002H; (* 4/8 = 1/2 full: 16 *)
      TXIFLSEL_val_68* = 003H; (* 6/8 = 3/4 full: 24 *)
      TXIFLSEL_val_78* = 004H; (* 7/8 full:       28 *)

    (* IMSC bits: int mask set/clr *)
    IMSC_OEIM* = 10;  (* FIFO overrrun *)
    IMSC_RTIM* = 6;   (* receive timeout *)
    IMSC_TXIM* = 5;   (* tramsmit *)
    IMSC_RXIM* = 4;   (* receive *)

    (* MIS bits: int status *)
    MIS_OEMIS* = IMSC_OEIM;
    MIS_RTMIS* = IMSC_RTIM;
    MIS_TXMIS* = IMSC_TXIM;
    MIS_RXMIS* = IMSC_RXIM;

    (* ICR bits: interrupt clear *)
    ICR_OEIC* = IMSC_OEIM;
    ICR_RTIC* = IMSC_RTIM;
    ICR_TXIC* = IMSC_TXIM;
    ICR_RXIC* = IMSC_RXIM;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartNo*: INTEGER;
      devNo: INTEGER;
      intNo*: INTEGER;
      CR, IBRD, FBRD, LCR_H: INTEGER;
      TDR*, RDR*, FR*, RSR*: INTEGER;
      DMACR, IFLS, IMSC*, MIS*, ICR*: INTEGER
    END;

    DeviceCfg* = RECORD (* see ASSERTs in 'Configure' for valid values *)
      (* reg LCR_H *)
      stickyParityEn*: INTEGER;
      dataBits*: INTEGER;
      fifoEn*: INTEGER;
      twoStopBitsEn*: INTEGER;
      evenParityEn*: INTEGER;
      parityEn*: INTEGER;
      sendBreak*: INTEGER
    END;


  PROCEDURE Init*(dev: Device; uartNo: INTEGER);
  (**
    Init device data.
  **)
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(uartNo IN {UART0, UART1});
    dev.uartNo := uartNo;
    CASE uartNo OF
      UART0: base := MCU.UART0_Base; dev.devNo := MCU.RESETS_UART0; dev.intNo := MCU.NVIC_UART0_IRQ
    | UART1: base := MCU.UART1_Base; dev.devNo := MCU.RESETS_UART1; dev.intNo := MCU.NVIC_UART1_IRQ
    END;
    dev.CR    := base + MCU.UART_CR_Offset;
    dev.IBRD  := base + MCU.UART_IBRD_Offset;
    dev.FBRD  := base + MCU.UART_FBRD_Offset;
    dev.LCR_H := base + MCU.UART_LCR_H_Offset;
    dev.TDR   := base + MCU.UART_DR_Offset;
    dev.RDR   := base + MCU.UART_DR_Offset;
    dev.FR    := base + MCU.UART_FR_Offset;
    dev.RSR   := base + MCU.UART_RSR_Offset;
    dev.DMACR := base + MCU.UART_DMACR_Offset;
    dev.IFLS  := base + MCU.UART_IFLS_Offset;
    dev.IMSC  := base + MCU.UART_IMSC_Offset;
    dev.MIS   := base + MCU.UART_MIS_Offset;
    dev.ICR   := base + MCU.UART_ICR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg; baudrate: INTEGER);
  (**
    Configure UART hardware, after 'Init'.
  **)
    VAR x, intDiv, fracDiv: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(cfg.stickyParityEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.dataBits IN {DataBits5 .. DataBits8}, Errors.PreCond);
    ASSERT(cfg.fifoEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.twoStopBitsEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.evenParityEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.parityEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.sendBreak IN {Disabled, Enabled}, Errors.PreCond);

    (* release reset on UART device *)
    StartUp.ReleaseReset(dev.devNo);
    StartUp.AwaitReleaseDone(dev.devNo);

    (* disable *)
    SYSTEM.PUT(dev.CR, {});

    (* baudrate *)
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

    (* note: LCR_H cfg MUST appear after baudrate cfg, 4.2.7.1, p426 *)
    x := 0;
    BFI(x, LCR_H_SPS, cfg.stickyParityEn);
    BFI(x, LCR_H_WLEN1, LCR_H_WLEN0, cfg.dataBits);
    BFI(x, LCR_H_FEN, cfg.fifoEn);
    BFI(x, LCR_H_STP2, cfg.twoStopBitsEn);
    BFI(x, LCR_H_EPS, cfg.evenParityEn);
    BFI(x, LCR_H_PEN, cfg.parityEn);
    BFI(x, LCR_H_BRK, cfg.sendBreak);
    SYSTEM.PUT(dev.LCR_H, x)
  END Configure;


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

  (* configuration data *)

  PROCEDURE GetBaseCfg*(VAR cfg: DeviceCfg);
  (**
    stickyParityEn = Disabled,   hardware reset value
    dataBits       = WLENval_8,  hardware reset override
    fifoEn         = Disabled,   hardware reset value
    twoStopBitsEn  = Disabled,   hardware reset value
    evenParityEn   = Disabled,   hardware reset value
    parityEn       = Disabled,   hardware reset value
    sendBreak      = Disabled,   hardware reset value
    --
    See ASSERTs in 'Configure' for valid values.
  **)
  BEGIN
    CLEAR(cfg);
    cfg.dataBits := WLEN_val_8
  END GetBaseCfg;


  PROCEDURE GetCurrentCfg*(dev: Device; VAR cfg: DeviceCfg);
    VAR x: INTEGER;
  BEGIN
    SYSTEM.GET(dev.LCR_H, x);
    cfg.stickyParityEn := BFX(x, LCR_H_SPS);
    cfg.dataBits := BFX(x, LCR_H_WLEN1, LCR_H_WLEN0);
    cfg.fifoEn := BFX(x, LCR_H_FEN);
    cfg.twoStopBitsEn := BFX(x, LCR_H_STP2);
    cfg.evenParityEn := BFX(x, LCR_H_EPS);
    cfg.parityEn := BFX(x, LCR_H_PEN);
    cfg.sendBreak := BFX(x, LCR_H_BRK)
  END GetCurrentCfg;

  (* interrupts *)

  PROCEDURE SetFifoLvl*(dev: Device; txFifoLvl, rxFifoLvl: INTEGER);
    VAR x: INTEGER;
  BEGIN
    ASSERT(txFifoLvl IN {TXIFLSEL_val_18 .. TXIFLSEL_val_78});
    ASSERT(rxFifoLvl IN {RXIFLSEL_val_18 .. RXIFLSEL_val_78});
    x := txFifoLvl;
    x := x + LSL(rxFifoLvl, IFLS_RXIFLSEL0);
    SYSTEM.PUT(dev.IFLS, x)
  END SetFifoLvl;


  PROCEDURE EnableInt*(dev: Device; intMask: SET);
  BEGIN
    SYSTEM.PUT(dev.IMSC + MCU.ASET, intMask)
  END EnableInt;


  PROCEDURE DisableInt*(dev: Device; intMask: SET);
  BEGIN
    SYSTEM.PUT(dev.IMSC + MCU.ACLR, intMask)
  END DisableInt;


  PROCEDURE GetEnabledInt*(dev: Device; VAR enabled: SET);
  BEGIN
    SYSTEM.GET(dev.IMSC, enabled)
  END GetEnabledInt;


  PROCEDURE GetIntStatus*(dev: Device; VAR status: SET);
  BEGIN
    SYSTEM.GET(dev.MIS, status)
  END GetIntStatus;


  PROCEDURE ClearInt*(dev: Device; intMask: SET);
  BEGIN
    SYSTEM.PUT(dev.ICR + MCU.ASET, intMask)
  END ClearInt;

END UARTdev.
