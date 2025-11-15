MODULE UARTdev;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  UART device
  * initialisation of device data structure
  * configure UART hardware
  * enable physical UART device
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  MCU: MCX-N947
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, StartUp, Clocks, ClockCtrl, TextIO;

  CONST
    UART0* = 0;
    UART1* = 1;
    UART2* = 2;
    UART3* = 3;
    UART4* = 4;
    UART5* = 5;
    UART6* = 6;
    UART7* = 7;
    UART8* = 8;
    UART9* = 9;
    UARTs = {UART0 .. UART9};
    NumUART* = MCU.NumUART;

    Disabled* = 0;
    Enabled* = 1;

    ClkFreq = Clocks.SIRC_FRQ;
    ClkSel = ClockCtrl.FLEXCOM_SIRC;
    ClkDiv = 0; (* actual div is ClkDiv + 1 *)

    FifoSize* = 8;

    (* FLEXCOM bits and values *)
    PSELID_PERSEL_1 = 2;
    PSELID_PERSEL_0 = 0;
      PSELID_PERSEL_val_UART = 1;
      PSELID_PERSEL_val_SPI  = 2;
      PSELID_PERSEL_val_I2C  = 3;
      PSELID_PERSEL_val_UI   = 7; (* UART and I2C *)

    (* BAUD bits and values *)
    BAUD_OSR_1 = 28;
    BAUD_OSR_0 = 24;
    BAUD_SBR_1 = 12;
    BAUD_SBR_0 = 0;

    (* STAT bits and values *)
    STAT_TDRE* = 23;

    (* CTRL bits and values *)
    CTRL_TE = 19;
    CTRL_RE = 18;

    (* FIFO bits and values *)
    FIFO_TXEMPT* = 23;
    FIFO_RXEMPT* = 22;
    FIFO_TXFE = 7;
    FIFO_RXFE = 3;

    (* WATER bits and values *)
    WATER_RX_1 = 18;
    WATER_RX_0 = 16;
    WATER_TX_1 = 2;
    WATER_TX_0 = 0;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartNo*: INTEGER;
      devNo*, clkSel, clkDiv: INTEGER;
      BAUD, STAT*: INTEGER;
      CTRL, FIFO, WATER: INTEGER;
      DATA*: INTEGER;
      PSELID: INTEGER
    END;


    DeviceCfg* = RECORD
      osr*: INTEGER;          (* oversampling rate *)
      txfe*, rxfe*: INTEGER;  (* fifo enable *)
      txwater*, rxwater*: INTEGER;
      (* ... *)
    END;


    PROCEDURE* Init*(dev: Device; uartNo: INTEGER);
      VAR base: INTEGER;
    BEGIN
      ASSERT(dev # NIL, Errors.PreCond);
      ASSERT(uartNo IN UARTs, Errors.PreCond);
      IF uartNo < UART4 THEN
        base := MCU.FLEXCOM0_BASE + (uartNo * MCU.FLEXCOM_Offset);
        dev.devNo := MCU.DEV_FLEXCOM0 + uartNo;
        dev.clkSel := MCU.CLKSEL_FLEXCOM0 + (uartNo * MCU.CLK_FLEXCOM_Offset);
        dev.clkDiv := MCU.CLKDIV_FLEXCOM0 + (uartNo * MCU.CLK_FLEXCOM_Offset)
      ELSE
        base := MCU.FLEXCOM4_BASE + ((uartNo - 4) * MCU.FLEXCOM_Offset);
        dev.devNo := MCU.DEV_FLEXCOM0 + uartNo;
        dev.clkSel := MCU.CLKSEL_FLEXCOM4 + ((uartNo - 4) * MCU.CLK_FLEXCOM_Offset);
        dev.clkDiv := MCU.CLKDIV_FLEXCOM4 + ((uartNo - 4) * MCU.CLK_FLEXCOM_Offset)
      END;
      dev.BAUD := base + MCU.UART_BAUD_Offset;
      dev.STAT := base + MCU.UART_STAT_Offset;
      dev.CTRL := base + MCU.UART_CTRL_Offset;
      dev.DATA := base + MCU.UART_DATA_Offset;
      dev.FIFO := base + MCU.UART_FIFO_Offset;
      dev.WATER := base + MCU.UART_WATER_Offset;
      dev.PSELID := base + MCU.FLEXCOM_PSELID_Offset
    END Init;


    PROCEDURE Configure*(dev: Device; cfg: DeviceCfg; baudrate: INTEGER);
      VAR val, x: INTEGER;
    BEGIN

      (* set clock *)
      ClockCtrl.ConfigDevClock(dev.clkSel, dev.clkDiv, ClkSel, ClkDiv);
      StartUp.EnableClock(dev.devNo);

      (* configure FLEXCOM function *)
      SYSTEM.GET(dev.PSELID, val);
      BFI(val, PSELID_PERSEL_1, PSELID_PERSEL_0, PSELID_PERSEL_val_UART);
      SYSTEM.PUT(dev.PSELID, val);

      (* disable transmitter and receiver *)
      SYSTEM.GET(dev.CTRL, val);
      BFI(val, CTRL_TE, CTRL_RE, 0);
      SYSTEM.PUT(dev.CTRL, val);
      REPEAT
        SYSTEM.GET(dev.CTRL, val)
      UNTIL BFX(val, CTRL_TE, CTRL_RE) = 0;

      (* baudrate *)
      SYSTEM.GET(dev.BAUD, val);
      BFI(val, BAUD_OSR_1, BAUD_OSR_0, cfg.osr);
      x := (ClkFreq DIV (cfg.osr + 1)) DIV baudrate;
      BFI(val, BAUD_SBR_1, BAUD_SBR_0, x);
      SYSTEM.PUT(dev.BAUD, val);

      (* tx watermark *)
      SYSTEM.GET(dev.WATER, val);
      BFI(val, WATER_TX_1, WATER_TX_0, cfg.txwater);
      BFI(val, WATER_RX_1, WATER_RX_0, cfg.rxwater);
      SYSTEM.PUT(dev.WATER, val);

      (* enable fifos *)
      SYSTEM.GET(dev.FIFO, val);
      BFI(val, FIFO_TXFE, cfg.txfe);
      BFI(val, FIFO_RXFE, cfg.rxfe);
      SYSTEM.PUT(dev.FIFO, val)
    END Configure;


    PROCEDURE* GetBaseCfg*(VAR cfg: DeviceCfg);
    BEGIN
      CLEAR(cfg);
      cfg.osr := 15;
      cfg.txfe := Disabled;
      cfg.rxfe := Disabled
    END GetBaseCfg;


    PROCEDURE* Enable*(dev: Device);
      VAR val: INTEGER;
    BEGIN
      SYSTEM.GET(dev.CTRL, val);
      BFI(val, CTRL_TE, CTRL_RE, 3);
      SYSTEM.PUT(dev.CTRL, val)
    END Enable;

END UARTdev.
