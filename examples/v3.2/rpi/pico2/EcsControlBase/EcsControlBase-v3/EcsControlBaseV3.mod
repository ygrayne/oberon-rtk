MODULE EcsControlBaseV3;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v3 -- The Message Form

  The byte ring becomes a message ring: the producer acquires a
  message from a pool, prints the report into its payload, and emits
  it to a queue; the drain sends the content across the ticks and
  returns the message to the pool. Queue and pool are both SPSC rings
  (the pool with reversed roles), and both are Components -- as is
  the drain's per-message send progress, which thereby stays part of
  the observable state (think: a restartable telemetry dump).
  Variable-length text through a record-shaped carrier is a
  deliberate data-shape mismatch; v7 shows the matched case.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, C := Components, BlinkSystem, StateSystem, LEDext,
    UARTbinding, DrainSystem, RingBuffer, TextMessages, GPIO, SIOgpio;

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
    RingBuffer.Init(C.textMsgQueue.ring);
    RingBuffer.Init(C.textMsgPool.ring);
    WHILE ~RingBuffer.Full(C.textMsgPool.ring) DO
      RingBuffer.Put(C.textMsgPool.ring, TextMessages.MakeMsg())
    END;
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
    txCursor.done := TRUE;
    txCursor.pos := 0;
    txCursor.numChar := 0;
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
END EcsControlBaseV3.
