MODULE EcsControlBaseV1;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v1 -- One System, Many Entities

  Four LEDs, each with its own blink period. The Component instances
  become arrays; BlinkSystem and StateSystem iterate over all
  instances of their Component types; the report lists four measured
  states. The crossing is untouched against v0: same single buffer,
  same drain, same handshake.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, C := Components, BlinkSystem, StateSystem, LEDext, TextIO,
    BUFstr, UARTbinding, DrainSystem, SIOgpio, GPIO;

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
    TextIO.OpenWriter(C.txBufWriter.writer, C.txData.device, BUFstr.PutString);
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
      txData: C.TxData; txCursor: C.TxCursor; statusSource: C.StatusSource;
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
    txData := C.txData;
    txData.seq := 0;
    txCursor := C.txCursor;
    txCursor.done := TRUE;
    txCursor.pos := 0;
    txCursor.seqDone := 0;
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
END EcsControlBaseV1.
