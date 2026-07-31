MODULE Console;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Program-wide text IO consoles, one per core (via Out/In).
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, UART, UARTstr, Texts, Out, In, RuntimeErrorsOut, Errors;

  CONST
    SYSTERM0* = 0;
    SYSTERM1* = 1;
    NumSysTerms* = 2;
    Baudrate0 = 38400;
    Baudrate1 = 38400;
    UART0 = UART.UART0;
    UART1 = UART.UART1;
    SYSTERM0_UART = UART0;
    SYSTERM1_UART = UART1;
    UART0_TxPinNo = 0;
    UART0_RxPinNo = 1;
    UART1_TxPinNo = 4;
    UART1_RxPinNo = 5;

  TYPE
    Ws* = ARRAY NumSysTerms OF INTEGER;
    Rs* = ARRAY NumSysTerms OF INTEGER;

  VAR
    Wsys*, Werr*: Ws;
    Rsys*: Rs;

  (* UART *)
  PROCEDURE cfgPins(txPin, rxPin: INTEGER);
    VAR pinCfg: GPIO.PinCfg;
  BEGIN
    GPIO.GetPinBaseCfg(pinCfg);
    pinCfg.pullupEn := GPIO.Enabled;
    pinCfg.pulldownEn := GPIO.Disabled;
    GPIO.Attach;
    GPIO.ConfigurePin(txPin, pinCfg);
    GPIO.ConfigurePin(rxPin, pinCfg);
    GPIO.ConnectInput(rxPin);
    GPIO.SetFunction(txPin, GPIO.Fuart);
    GPIO.SetFunction(rxPin, GPIO.Fuart)
  END cfgPins;


  PROCEDURE initUART(dev: UART.Device; uartHandle, uartNo: INTEGER; uartCfg: UART.DeviceCfg; baudrate: INTEGER);
  BEGIN
    UART.Init(dev, uartHandle, uartNo);
    UART.Configure(uartHandle, uartCfg, baudrate);
    UART.Enable(uartHandle)
  END initUART;


  (* terminal *)
  PROCEDURE installTerm(termNo: INTEGER; uartHandle, whWsys, whRsys, whWerr: INTEGER; pspStd, pspErr: Texts.PutStringProc; gspStd: Texts.GetStringProc);
    VAR W: Texts.Writer; R: Texts.Reader;
  BEGIN
    NEW(W); ASSERT(W # NIL, Errors.HeapOverflow);
    Wsys[termNo] := whWsys;
    Texts.OpenWriter(W, Wsys[termNo], uartHandle, pspStd, NIL);

    NEW(R); ASSERT(R # NIL, Errors.HeapOverflow);
    Rsys[termNo] := whRsys;
    Texts.OpenReader(R, Rsys[termNo], uartHandle, gspStd);

    NEW(W); ASSERT(W # NIL, Errors.HeapOverflow);
    Werr[termNo] := whWerr;
    Texts.OpenWriter(W, Werr[termNo], uartHandle, pspErr, NIL)
  END installTerm;


  PROCEDURE Install*(sysTerm: INTEGER);
    VAR
      uartDev: UART.Device; uartCfg: UART.DeviceCfg;
      uartNo, uartHandle, baudrate, writerHandleWsys, readerHandleRsys, writerHandleWerr: INTEGER;
  BEGIN
    ASSERT(sysTerm IN {SYSTERM0, SYSTERM1}, Errors.ProgError);

    (* cfg pins, uartNo, baudrate *)
    IF sysTerm = SYSTERM0 THEN
      cfgPins(UART0_TxPinNo, UART0_RxPinNo);
      uartNo := SYSTERM0_UART;
      baudrate := Baudrate0
    ELSE
      cfgPins(UART1_TxPinNo, UART1_RxPinNo);
      uartNo := SYSTERM1_UART;
      baudrate := Baudrate1
    END;

    (* handles: assigned from the top, two writers + one reader per terminal *)
    uartHandle := UART.NumUART - 1 - sysTerm;
    writerHandleWsys := Texts.NumWriters - (2 * sysTerm) - 1;
    writerHandleWerr := Texts.NumWriters - (2 * sysTerm) - 2;
    readerHandleRsys := Texts.NumReaders - sysTerm - 1;

    (* cfg UART *)
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;
    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    initUART(uartDev, uartHandle, uartNo, uartCfg, baudrate);

    (* install system terminal *)
    installTerm(sysTerm, uartHandle, writerHandleWsys, readerHandleRsys, writerHandleWerr, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys[sysTerm]);
    In.Open(Rsys[sysTerm]);

    (* run-time errors console output *)
    RuntimeErrorsOut.SetWriter(Werr[sysTerm])
  END Install;

END Console.
