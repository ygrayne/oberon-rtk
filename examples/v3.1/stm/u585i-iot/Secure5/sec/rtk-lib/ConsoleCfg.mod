MODULE ConsoleCfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-wide text IO console.
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, GPIOdef, UART, UARTdef, UARTstr, TextIO, Out, In, Errors;

  CONST
    SYSTERM0* = 0;
    NumSysTerms* = 1;
    Baudrate0 = 115200;
    UART0 = UARTdef.USART1;
    UART0_TxPinNo = 9; (* GPIOA *)
    UART0_RxPinNo = 10;

  TYPE
    Ws* = ARRAY NumSysTerms OF TextIO.Writer;
    Rs* = ARRAY NumSysTerms OF TextIO.Reader;

  VAR
    Wsys*, Werr*: Ws;
    Rsys*: Rs;

  (* UART *)
  PROCEDURE cfgPins(txPin, rxPin: INTEGER);
    CONST AF = 7;
    VAR padCfg: GPIO.PadCfg; port: GPIO.Port;
  BEGIN
    NEW(port); ASSERT(port # NIL);
    GPIO.Init(port, GPIOdef.PORTA);
    padCfg.mode := GPIO.ModeAlt;
    padCfg.type := GPIO.TypePushPull;
    padCfg.speed := GPIO.SpeedHigh;
    padCfg.pulls := GPIO.PullUp;
    GPIO.ConfigurePin(port, txPin, padCfg);
    GPIO.ConfigurePin(port, rxPin, padCfg);
    GPIO.SetFunction(port, txPin, AF);
    GPIO.SetFunction(port, rxPin, AF)
  END cfgPins;

  PROCEDURE initUART(dev: UART.Device; uartNo: INTEGER; uartCfg: UART.DeviceCfg; baudrate: INTEGER);
  BEGIN
    UART.Init(dev, uartNo);
    UART.Configure(dev, uartCfg, baudrate);
    UART.Enable(dev)
  END initUART;


  (* terminal *)
  PROCEDURE installTerm(termNo: INTEGER; dev: TextIO.Device; pspStd, pspErr: TextIO.PutStringProc; gspStd: TextIO.GetStringProc);
  BEGIN
    NEW(Wsys[termNo]); ASSERT(Wsys[termNo] # NIL, Errors.HeapOverflow);
    NEW(Rsys[termNo]); ASSERT(Rsys[termNo] # NIL, Errors.HeapOverflow);
    NEW(Werr[termNo]); ASSERT(Werr[termNo] # NIL, Errors.HeapOverflow);
    TextIO.OpenWriter(Wsys[termNo], dev, pspStd);
    TextIO.OpenReader(Rsys[termNo], dev, gspStd);
    TextIO.OpenWriter(Werr[termNo], Wsys[termNo].dev, pspErr)
  END installTerm;


  PROCEDURE Init*(SYSCLK_FRQ: INTEGER);
    VAR uartDev: UART.Device; uartCfg: UART.DeviceCfg;
  BEGIN
    (* config UART pins and pads *)
    cfgPins(UART0_TxPinNo, UART0_RxPinNo);

    (* config UART *)
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;
    uartCfg.over8En := UART.Disabled;
    uartCfg.clkSel := UARTdef.CLK_SYSCLK;
    uartCfg.presc := UART.Presc_16;
    uartCfg.clkFreq := SYSCLK_FRQ;
    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    initUART(uartDev, UART0, uartCfg, Baudrate0);

    (* install one system terminal *)
    installTerm(SYSTERM0, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys[SYSTERM0]);
    In.Open(Rsys[SYSTERM0])
  END Init;

BEGIN
  Wsys[0] := NIL; Rsys[0] := NIL; Werr[0] := NIL
END ConsoleCfg.
