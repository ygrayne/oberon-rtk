MODULE BlinkSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v0
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
    VAR ledState: C.LedState; blinkConfig: C.BlinkConfig;
  BEGIN
    blinkConfig := C.blinkConfig;
    DEC(blinkConfig.ticker, Kernel.TickPeriod);
    IF blinkConfig.ticker < 0 THEN
      ledState := C.ledState;
      ledState.value := ORD(BITS(ledState.value) / {0}); (* XOR toggle *)
      LEDext.SetLedBits(ledState.value, C.ledBinding.led, C.ledBinding.led);
      INC(blinkConfig.ticker, blinkConfig.period)
    END
  END Run;

END BlinkSystem.
