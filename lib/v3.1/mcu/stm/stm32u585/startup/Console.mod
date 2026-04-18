MODULE Console;
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

  IMPORT GPIO, UART, UARTstr, TextIO, Out, In, Errors, RuntimeErrorsOut;

  CONST
    SYSTERM0* = 0;
    NumSysTerms* = 1;
    Baudrate0 = 115200;
    UART0 = UART.USART1;
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
    VAR pinCfg: GPIO.PinCfg;
  BEGIN
    pinCfg.mode := GPIO.ModeAlt;
    pinCfg.type := GPIO.TypePushPull;
    pinCfg.speed := GPIO.SpeedHigh;
    pinCfg.pulls := GPIO.PullUp;
    GPIO.ConfigurePin(GPIO.PORTA, txPin, pinCfg);
    GPIO.ConfigurePin(GPIO.PORTA, rxPin, pinCfg);
    GPIO.SetFunction(GPIO.PORTA, txPin, AF);
    GPIO.SetFunction(GPIO.PORTA, rxPin, AF);
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


  PROCEDURE Install*(UARTclkFreq: INTEGER);
    VAR uartDev: UART.Device; uartCfg: UART.DeviceCfg;
  BEGIN
    (* config UART pins and pads *)
    cfgPins(UART0_TxPinNo, UART0_RxPinNo);

    (* config UART *)
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;
    uartCfg.over8En := UART.Disabled;
    uartCfg.clkSel := UART.CLK_SYSCLK;
    uartCfg.presc := UART.Presc_16;
    uartCfg.clkFreq := UARTclkFreq;
    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    initUART(uartDev, UART0, uartCfg, Baudrate0);

    (* install one system terminal *)
    installTerm(SYSTERM0, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys[SYSTERM0]);
    In.Open(Rsys[SYSTERM0]);

    (* run-time errors console output *)
    RuntimeErrorsOut.SetWriter(Werr[SYSTERM0])
  END Install;

BEGIN
  Wsys[0] := NIL; Rsys[0] := NIL; Werr[0] := NIL
END Console.
