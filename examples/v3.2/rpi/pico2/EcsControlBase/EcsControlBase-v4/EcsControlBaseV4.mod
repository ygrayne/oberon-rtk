MODULE EcsControlBaseV4;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v4 -- Machinery Below the Store

  The queue and pool move out of Components into a queueing-port
  module of their own, behind an Emit/Receive interface; only the
  port reference remains a Component. The drain reads the text
  character by character directly from the held message (no
  copy-out), so the transmit status leaves the observable state --
  the v3 decision taken the other way. Still fully cooperative:
  relocation is orthogonal to the asynchronous switch of v5.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, C := Components, BlinkSystem, StateSystem, LEDext,
    UARTbinding, DrainSystem, TextMessages, QueueingPort, SIOgpio, GPIO;

  CONST
    BlinkPeriod0 = 400;
    BlinkPeriod1 = 650;
    BlinkPeriod2 = 1100;
    BlinkPeriod3 = 1400;
    StatePeriod = 1000;
    TickPeriod = 10;


  PROCEDURE build;
    VAR
      i: INTEGER;
      ledBinding: C.LedBinding; ledGpioBinding: C.LedGpioBinding;
  BEGIN
    C.Create;
    QueueingPort.Init(C.outputPort.port, TextMessages.MakeMsg);
    UARTbinding.Config(C.uartBinding.device);
    LEDext.Config;
    i := 0;
    WHILE i < C.NumLed DO
      ledBinding := C.ledBinding[i];
      ledBinding.led := i;
      ledGpioBinding := C.ledGpioBinding[i];
      ledGpioBinding.ledPin := LEDext.LED[i];
      ledGpioBinding.ledPinPort := SIOgpio.GPIOA;
      GPIO.ConnectInput(ledGpioBinding.ledPin);
      INC(i)
    END
  END build;


  PROCEDURE value;
    VAR
      i: INTEGER; periods: ARRAY C.NumLed OF INTEGER;
      ledState: C.LedState; blinkConfig: C.BlinkConfig;
      txCursor: C.TxCursor; statusSource: C.StatusSource;
  BEGIN
    periods[0] := BlinkPeriod0;
    periods[1] := BlinkPeriod1;
    periods[2] := BlinkPeriod2;
    periods[3] := BlinkPeriod3;
    i := 0;
    WHILE i < C.NumLed DO
      ledState := C.ledState[i];
      ledState.value := 0;
      blinkConfig := C.blinkConfig[i];
      blinkConfig.period := periods[i];
      blinkConfig.ticker := periods[i];
      INC(i)
    END;
    txCursor := C.txCursor;
    txCursor.msg := NIL;
    statusSource := C.statusSource;
    statusSource.leds := {0, 1, 3}
  END value;


  PROCEDURE propagate;
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < C.NumLed DO
      LEDext.SetLedBits(C.ledState[i].value, C.ledBinding[i].led, C.ledBinding[i].led);
      INC(i)
    END
  END propagate;


  PROCEDURE addSystems;
  (* add the systems in scheduling order *)
  (* with the fully built Kernel, this order will be determined algorithmically *)
  (* using the producer -> consumer relationships of the Components *)
  BEGIN
    Kernel.AddSystem(BlinkSystem.Run, 0);
    Kernel.AddSystem(StateSystem.Run, StatePeriod);
    Kernel.AddSystem(DrainSystem.Run, 0)
  END addSystems;

BEGIN
  build;
  value;
  propagate;
  Kernel.Install(TickPeriod);
  addSystems;
  Kernel.Run
END EcsControlBaseV4.
