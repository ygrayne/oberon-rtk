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
    Baudrate0 = 38400;
    UART0 = UART.USART1;
    UART0_TxPinNo = 9; (* GPIOA *)
    UART0_RxPinNo = 10;

  VAR
    Wsys*, Werr*: TextIO.Writer;
    Rsys*: TextIO.Reader;

  (* UART *)
  PROCEDURE cfgPins(txPin, rxPin: INTEGER);
    CONST AF = 7;
    VAR pinCfg: GPIO.PinCfg;
  BEGIN
    pinCfg.mode := GPIO.ModeAlt;
    pinCfg.type := GPIO.TypePushPull;
    pinCfg.speed := GPIO.SpeedHigh;
    pinCfg.pulls := GPIO.PullUp;
    GPIO.Attach(GPIO.PORTA);
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
  PROCEDURE installTerm(dev: TextIO.Device; pspStd, pspErr: TextIO.PutStringProc; gspStd: TextIO.GetStringProc);
  BEGIN
    NEW(Wsys); ASSERT(Wsys # NIL, Errors.HeapOverflow);
    NEW(Rsys); ASSERT(Rsys # NIL, Errors.HeapOverflow);
    NEW(Werr); ASSERT(Werr # NIL, Errors.HeapOverflow);
    TextIO.OpenWriter(Wsys, dev, pspStd);
    TextIO.OpenReader(Rsys, dev, gspStd);
    TextIO.OpenWriter(Werr, Wsys.dev, pspErr)
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
    installTerm(uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys);
    In.Open(Rsys);

    (* run-time errors console output *)
    RuntimeErrorsOut.SetWriter(Werr)
  END Install;

BEGIN
  Wsys := NIL; Rsys := NIL; Werr := NIL
END Console.
