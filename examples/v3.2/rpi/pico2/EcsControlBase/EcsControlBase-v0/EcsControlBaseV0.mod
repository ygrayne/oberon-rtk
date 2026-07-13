MODULE EcsControlBaseV0;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v0 -- The Minimal World

  One LED. BlinkSystem drives the pin; StateSystem reads the measured
  pin state back and formats a report; DrainSystem copies the report
  out of a single buffer and feeds the UART across the ticks,
  coordinating with the producer via a completion handshake in the
  store. The minimal ECS program: all state in Components, stateless
  Systems on a tick, the report output handled by a synchronous
  adaptation unit.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, C := Components, BlinkSystem, StateSystem, LEDext, TextIO,
    BUFstr, UARTbinding, DrainSystem, GPIO, SIOgpio;

  CONST
    BlinkPeriod = 400;
    StatePeriod = 1000;
    TickPeriod = 10;


  PROCEDURE build;
    VAR ledBinding: C.LedBinding; ledGpioBinding: C.LedGpioBinding;
  BEGIN
    C.Create;
    TextIO.OpenWriter(C.txBufWriter.writer, C.txData.device, BUFstr.PutString);
    UARTbinding.Config(C.uartBinding.device);
    LEDext.Config;
    ledBinding := C.ledBinding;
    ledBinding.led := 0;
    ledGpioBinding := C.ledGpioBinding;
    ledGpioBinding.ledPin := LEDext.LED[ledBinding.led];
    ledGpioBinding.ledPinPort := SIOgpio.GPIOA;
    GPIO.ConnectInput(C.ledGpioBinding.ledPin)
  END build;


  PROCEDURE value;
    VAR
      ledState: C.LedState; blinkConfig: C.BlinkConfig;
      txData: C.TxData; txCursor: C.TxCursor;
  BEGIN
    ledState := C.ledState;
    ledState.value := 0;
    blinkConfig := C.blinkConfig;
    blinkConfig.period := BlinkPeriod;
    blinkConfig.ticker := BlinkPeriod;
    txData := C.txData;
    txData.seq := 0;
    txCursor := C.txCursor;
    txCursor.done := TRUE;
    txCursor.pos := 0;
    txCursor.seqDone := 0
  END value;


  PROCEDURE propagate;
  BEGIN
    LEDext.SetLedBits(C.ledState.value, C.ledBinding.led, C.ledBinding.led);
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
END EcsControlBaseV0.
