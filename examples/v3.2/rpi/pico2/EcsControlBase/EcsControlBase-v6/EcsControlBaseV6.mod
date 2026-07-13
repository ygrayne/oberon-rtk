MODULE EcsControlBaseV6;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v6 -- The Asynchronous Seam, Pure

  Derived from v2. The byte ring returns, drained entirely by
  the UART transmit interrupt handler: a trivial character pump, one
  interrupt per character (FIFO disabled), each transmitted byte
  pulling the next; from idle, Texts.FlushOut kicks the draining via
  a software interrupt. Against v5: a byte stream needs no
  per-message set-up, so the handler does everything -- the seam
  itself is trivial.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, C := Components, BlinkSystem, StateSystem, LEDext, TextIO,
    BUFstr, UARTbinding, DrainHandler, UARTdrain, RingBuffer, Exceptions, EXC, SIOgpio, GPIO;

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
    TextIO.InstallFlushOutProc(C.txBufWriter.writer, DrainHandler.Flush);
    UARTbinding.Config(C.uartBinding.device);
    UARTdrain.EnableTxInt(C.uartBinding.device);
    UARTdrain.ClearTxInt(C.uartBinding.device);
    Exceptions.ClearPendingInt(C.uartBinding.device.irqNo);
    Exceptions.SetIntPrio(C.uartBinding.device.irqNo, EXC.ExcPrioMedium);
    Exceptions.InstallIntHandler(C.uartBinding.device.irqNo, DrainHandler.TxHandler);
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
    Kernel.AddSystem(StateSystem.Run, StatePeriod)
  END addSystems;

BEGIN
  build;
  value;
  propagate;
  Kernel.Install(TickPeriod);
  addSystems;
  Kernel.Run
END EcsControlBaseV6.
