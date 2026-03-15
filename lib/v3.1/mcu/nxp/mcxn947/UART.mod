MODULE UART;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  UART device driver
  --
  Type: MCU
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  MCU: MCXN947
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, CLK, TextIO;

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

    (* functional clock values *)
    CLK_NONE* = 0;
    CLK_SPLL_DIV* = 1;
    CLK_CLK12M* = 2;
    CLK_CLKHF_DIV* = 3;
    CLK_CLK1M* = 4;
    CLK_UPLL* = 5;
    CLK_CLK16K* = 6;

    FifoSize* = 8;

    (* STAT bits and values *)
    STAT_TDRE* = 23;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartNo*: INTEGER;
      devNo*, clkSelReg, clkDivReg: INTEGER;
      BAUD, STAT*: INTEGER;
      CTRL, FIFO, WATER: INTEGER;
      DATA*: INTEGER;
      PSELID: INTEGER
    END;


    DeviceCfg* = RECORD
      osr*: INTEGER;          (* oversampling rate *)
      txfe*, rxfe*: INTEGER;  (* fifo enable *)
      txwater*, rxwater*: INTEGER;
      clkSel*: INTEGER;
      clkDiv*: INTEGER;
      clkFreq*: INTEGER
    END;


    PROCEDURE* Init*(dev: Device; uartNo: INTEGER);
      VAR base: INTEGER;
    BEGIN
      ASSERT(dev # NIL, Errors.PreCond);
      ASSERT(uartNo IN UARTs, Errors.PreCond);
      dev.uartNo := uartNo;
      IF uartNo < UART4 THEN
        base := MCU.FLEXCOM0_BASE + (uartNo * MCU.FLEXCOM_Offset);
        dev.devNo := MCU.DEV_FLEXCOM0 + uartNo;
        dev.clkSelReg := MCU.CLKSEL_FLEXCOM0 + (uartNo * MCU.CLK_FLEXCOM_Offset);
        dev.clkDivReg := MCU.CLKDIV_FLEXCOM0 + (uartNo * MCU.CLK_FLEXCOM_Offset)
      ELSE
        base := MCU.FLEXCOM4_BASE + ((uartNo - UART4) * MCU.FLEXCOM_Offset);
        dev.devNo := MCU.DEV_FLEXCOM0 + uartNo;
        dev.clkSelReg := MCU.CLKSEL_FLEXCOM4 + ((uartNo - UART4) * MCU.CLK_FLEXCOM_Offset);
        dev.clkDivReg := MCU.CLKDIV_FLEXCOM4 + ((uartNo - UART4) * MCU.CLK_FLEXCOM_Offset)
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
      CONST PSELID_PERSEL_val_UART = 1; CTRL_TE = 19; CTRL_RE = 18;
      VAR val, x: INTEGER;
    BEGIN

      (* set clock *)
      CLK.ConfigDevClock(cfg.clkSel, cfg.clkDiv, dev.clkSelReg, dev.clkDivReg);
      CLK.EnableBusClock(dev.devNo);

      (* configure FLEXCOM function *)
      SYSTEM.GET(dev.PSELID, val);
      BFI(val, 2, 0, PSELID_PERSEL_val_UART);
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
      BFI(val, 28, 24, cfg.osr);
      x := (cfg.clkFreq DIV (cfg.osr + 1)) DIV baudrate;
      BFI(val, 12, 0, x);
      SYSTEM.PUT(dev.BAUD, val);

      (* tx watermark *)
      SYSTEM.GET(dev.WATER, val);
      BFI(val, 2, 0, cfg.txwater);
      BFI(val, 18, 16, cfg.rxwater);
      SYSTEM.PUT(dev.WATER, val);

      (* enable fifos *)
      SYSTEM.GET(dev.FIFO, val);
      BFI(val, 7, cfg.txfe);
      BFI(val, 3, cfg.rxfe);
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
      CONST CTRL_TE = 19; CTRL_RE = 18;
      VAR val: INTEGER;
    BEGIN
      SYSTEM.GET(dev.CTRL, val);
      BFI(val, CTRL_TE, CTRL_RE, 3);
      SYSTEM.PUT(dev.CTRL, val)
    END Enable;

END UART.
