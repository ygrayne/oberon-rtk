MODULE EcsControlBaseV7;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v7 -- The Interaction Made One-Shot

  Derived from v4. The message ring returns, with the report limited
  to the size of the empty UART transmit FIFO -- a stand-in for a
  fixed-size, mixed-type record (a "sensor reading"). Gated by an
  empty FIFO, the cooperative drain collapses to one shot: receive,
  write the whole message to the FIFO, return it -- no cross-tick
  state, no held progress; the FIFO holds the in-flight characters in
  silicon. Against v3..v5: the accounting there was a data-shape
  mismatch, not the message form's fault. v6 and v7 are peers.
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
      statusSource: C.StatusSource;
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
END EcsControlBaseV7.
