MODULE BlinkSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v7
  --
  LED blink system
  Components:
  * locked: LedBinding
  * owned: BlinkConfig, LedState
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, LEDext, Kernel;

  PROCEDURE Run*;
    VAR i: INTEGER; bc: C.BlinkConfig; ls: C.LedState; lb: C.LedBinding;
  BEGIN
    i := 0;
    WHILE i < C.NumLed DO
      ls := C.ledState[i];
      bc := C.blinkConfig[i];
      lb := C.ledBinding[i];
      DEC(bc.ticker, Kernel.TickPeriod);
      IF bc.ticker < 0 THEN
        ls.value := ORD(BITS(ls.value) / {0}); (* XOR toggle *)
        LEDext.SetLedBits(ls.value, lb.led, lb.led);
        INC(bc.ticker, bc.period)
      END;
      INC(i)
    END
  END Run;

END BlinkSystem.
