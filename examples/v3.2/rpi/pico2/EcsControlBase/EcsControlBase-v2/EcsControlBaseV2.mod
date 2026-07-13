MODULE EcsControlBaseV2;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v2 -- Producer and Consumer Decoupled

  The single buffer and handshake of v0/v1 are replaced by a byte
  ring, a lock-free single-producer/single-consumer (SPSC) construct.
  StateSystem appends when there is room and clips when there is not
  (drop, never wait); DrainSystem streams out as the UART accepts.
  No handshake: each side acts on the ring's status alone, so the two
  Systems are decoupled in time -- either may run at any time, in any
  order. The ring's two indices carry fill level and drain progress;
  the cursor, sequence numbers, and done flag of v0/v1 disappear.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, C := Components, BlinkSystem, StateSystem, LEDext, TextIO,
    BUFstr, UARTbinding, DrainSystem, RingBuffer, SIOgpio, GPIO;

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
    RingBuffer.Init(C.txData.ring);
    BUFstr.Init(C.txBufWriter.device, C.txData.ring);
    TextIO.OpenWriter(C.txBufWriter.writer, C.txBufWriter.device, BUFstr.PutString);
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
      ledState: C.LedState; blinkConfig: C.BlinkConfig; statusSource: C.StatusSource;
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
END EcsControlBaseV2.
