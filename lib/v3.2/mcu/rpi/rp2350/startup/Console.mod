MODULE Console;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Program-wide text IO consoles, one per core (via Out/In).
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, UART, UARTstr, TextIO, Out, In, RuntimeErrorsOut, Errors;

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
    Ws* = ARRAY NumSysTerms OF TextIO.Writer;
    Rs* = ARRAY NumSysTerms OF TextIO.Reader;

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


  PROCEDURE Install*(sysTerm: INTEGER);
    VAR uartDev: UART.Device; uartCfg: UART.DeviceCfg; uartNo, baudrate: INTEGER;
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

    (* cfg UART *)
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;
    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    initUART(uartDev, uartNo, uartCfg, baudrate);

    (* install system terminal *)
    installTerm(sysTerm, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys[sysTerm]);
    In.Open(Rsys[sysTerm]);

    (* run-time errors console output *)
    RuntimeErrorsOut.SetWriter(Werr[sysTerm])
  END Install;

BEGIN
  Wsys[0] := NIL; Rsys[0] := NIL; Werr[0] := NIL;
  Wsys[1] := NIL; Rsys[1] := NIL; Werr[1] := NIL
END Console.
