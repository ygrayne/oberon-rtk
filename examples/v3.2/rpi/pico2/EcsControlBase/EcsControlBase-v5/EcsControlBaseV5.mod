MODULE EcsControlBaseV5;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v5 -- The Asynchronous Seam, Hybrid

  First asynchronous drain. A tick-scheduled set-up step takes a
  message and primes the first character; the UART transmit interrupt
  handler streams the rest at hardware time. The scheduled half keeps
  the message under transmission as a Component; the handler's
  byte-level progress lives below the store. The ring's marked memory
  barriers stay inactive -- one core is one observer, thread and its
  own handler included -- and the one active barrier is the DSB at
  the interrupt disarm: the mask write must have landed before the
  handler returns, or the interrupt re-enters. The transmit interrupt
  is armed by the set-up step, disarmed by the handler on the last
  character.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, C := Components, BlinkSystem, StateSystem, LEDext, UARTdrain,
    UARTbinding, DrainSystem, TextMessages, QueueingPort, Exceptions, EXC, SIOgpio, GPIO;

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
    UARTdrain.DisableTxInt(C.uartBinding.device);
    UARTdrain.ClearTxInt(C.uartBinding.device);
    Exceptions.ClearPendingInt(C.uartBinding.device.irqNo);
    Exceptions.SetIntPrio(C.uartBinding.device.irqNo, EXC.ExcPrioMedium);
    Exceptions.InstallIntHandler(C.uartBinding.device.irqNo, DrainSystem.TxHandler);
    Exceptions.EnableInt(C.uartBinding.device.irqNo);
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
END EcsControlBaseV5.
