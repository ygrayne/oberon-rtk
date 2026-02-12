MODULE NS;
(**
  Oberon RTK Framework v3.0
  --
  Exploration program Secure2
  https://oberon-rtk.org/docs/examples/v3/secure2/
  Non-secure program
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, MCU := MCU2, NS_S0;

  CONST
    LEDpico = 25;
    LSET = MCU.SIO_GPIO_OUT_SET;
    LED0 = 27;


  PROCEDURE run;
    VAR i, x: INTEGER;
  BEGIN
    SYSTEM.PUT(LSET, {LED0});
    REPEAT
      x := NS_S0.ToggleLED(LEDpico); (* Secure call *)
      i := 0;
      WHILE i < 1000000 DO INC(i) END
    UNTIL FALSE
  END run;

BEGIN
  run
END NS.
