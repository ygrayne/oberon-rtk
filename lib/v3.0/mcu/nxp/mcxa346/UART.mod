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
  MCU: MCXA346
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, RST, CLK, TextIO;

  CONST
    UART0* = 0;
    UART1* = 1;
    UART2* = 2;
    UART3* = 3;
    UART4* = 4;
    UART5* = 5;
    UARTs = {UART0 .. UART5};
    NumUART* = MCU.NumUART;

    Disabled* = 0;
    Enabled* = 1;

    (* functional clock values *)
    CLK_CLKLF_DIV*  = 0;  (* fro_lf_div *)
    CLK_CLKHF_DIV*  = 2;
    CLK_CLKIN*      = 3;  (* SOSC *)
    CLK_CLK16K*     = 4;  (* ROSC *)
    CLK_CLK1M*      = 5;
    CLK_SPLL_DIV*   = 6;
    CLK_NONE*       = 7;  (* reset *)

    FifoSize* = 4;

    (* STAT bits and values *)
    STAT_TDRE* = 23;

    (* CTRL bits and values *)
    CTRL_TE = 19;
    CTRL_RE = 18;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartNo*: INTEGER;
      devNo*, clkSelReg, clkDivReg: INTEGER;
      BAUD, STAT*: INTEGER;
      FIFO, CTRL, WATER: INTEGER;
      DATA*: INTEGER
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
      IF uartNo < UART5 THEN
        base := MCU.LPUART0_BASE + (uartNo * MCU.UART_Offset);
        dev.devNo := MCU.DEV_UART0 + uartNo;
        dev.clkSelReg := MCU.CLKSEL_UART0 + (uartNo * MCU.CLK_UART_Offset);
        dev.clkDivReg := MCU.CLKDIV_UART0 + (uartNo * MCU.CLK_UART_Offset)
      ELSE
        base := MCU.LPUART5_BASE;
        dev.devNo := MCU.DEV_UART5;
        dev.clkSelReg := MCU.CLKSEL_UART5;
        dev.clkDivReg := MCU.CLKDIV_UART5
      END;
      dev.BAUD := base + MCU.UART_BAUD_Offset;
      dev.STAT := base + MCU.UART_STAT_Offset;
      dev.CTRL := base + MCU.UART_CTRL_Offset;
      dev.DATA := base + MCU.UART_DATA_Offset;
      dev.FIFO := base + MCU.UART_FIFO_Offset;
      dev.WATER := base + MCU.UART_WATER_Offset
    END Init;


    PROCEDURE Configure*(dev: Device; cfg: DeviceCfg; baudrate: INTEGER);
      VAR val, x: INTEGER;
    BEGIN

      (* release reset on UART device, set clock *)
      RST.ReleaseReset(dev.devNo);
      CLK.ConfigDevClock(cfg.clkSel, cfg.clkDiv, dev.clkSelReg, dev.clkDivReg);
      CLK.EnableBusClock(dev.devNo);

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
      BFI(val, 1, 0, cfg.txwater);
      BFI(val, 17, 16, cfg.rxwater);
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
      VAR val: INTEGER;
    BEGIN
      SYSTEM.GET(dev.CTRL, val);
      BFI(val, CTRL_TE, CTRL_RE, 3);
      SYSTEM.PUT(dev.CTRL, val)
    END Enable;

END UART.
