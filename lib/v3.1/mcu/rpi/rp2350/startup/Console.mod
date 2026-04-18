MODULE Console;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-wide text IO consoles, one per core.
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: RP2350A
  Board: Pico2
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Cores, GPIO, UART, UARTstr, TextIO, Out, In, RuntimeErrorsOut, Errors;

  CONST
    SYSTERM0* = 0;
    SYSTERM1* = 1;
    NumSysTerms* = 2;
    Baudrate0 = 38400;
    Baudrate1 = 38400;
    UART0 = UART.UART0;
    UART1 = UART.UART1;
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


  PROCEDURE Install*;
    CONST Core0 = 0;
    VAR uartDev: UART.Device; uartCfg: UART.DeviceCfg; cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    ASSERT(cid IN {0, 1}, Errors.ProgError);
    IF cid = Core0 THEN
      (* cfg pins *)
      cfgPins(UART0_TxPinNo, UART0_RxPinNo);

      (* cfg UART *)
      UART.GetBaseCfg(uartCfg);
      uartCfg.fifoEn := UART.Enabled;
      NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
      initUART(uartDev, UART0, uartCfg, Baudrate0);

      (* install system terminal *)
      installTerm(SYSTERM0, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

      (* Out/In wrappers *)
      Out.Open(Wsys[SYSTERM0]);
      In.Open(Rsys[SYSTERM0]);

      (* run-time errors console output *)
      RuntimeErrorsOut.SetWriter(Werr[SYSTERM0])
    ELSE
      (* cfg pins *)
      cfgPins(UART1_TxPinNo, UART1_RxPinNo);

      (* cfg UART *)
      UART.GetBaseCfg(uartCfg);
      uartCfg.fifoEn := UART.Enabled;
      NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
      initUART(uartDev, UART1, uartCfg, Baudrate1);

      (* install system terminal *)
      installTerm(SYSTERM1, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

      (* Out/In wrappers *)
      Out.Open(Wsys[SYSTERM1]);
      In.Open(Rsys[SYSTERM1]);

      (* run-time errors console output *)
      RuntimeErrorsOut.SetWriter(Werr[SYSTERM1])
    END
  END Install;

BEGIN
  Wsys[0] := NIL; Rsys[0] := NIL; Werr[0] := NIL;
  Wsys[1] := NIL; Rsys[1] := NIL; Werr[1] := NIL
END Console.
