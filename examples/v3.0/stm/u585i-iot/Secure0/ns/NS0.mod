MODULE NS0;
(**
  Oberon RTK Framework v3.0
  --
  Experimental program
  https://oberon-rtk.org/docs/examples/v3/secure0/
  Non-secure code
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, S0 := NS_S0, Main;

  CONST
    LEDgreen = 7; (* GPIOH *)
    LEDred   = 6;

    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE init;
    VAR val: SET; reg, devNo: INTEGER;
  BEGIN
    (* enable GPIOH clock *)
    reg := MCU.DEV_GPIOH DIV 32;
    reg := MCU.RCC_AHB1ENR + (reg * 4);
    devNo := MCU.DEV_GPIOH MOD 32;
    SYSTEM.GET(reg, val);
    val := val + {devNo};
    SYSTEM.PUT(reg, val);

    (* set-up GPIOH for the leds *)
    reg := MCU.GPIOH_BASE + MCU.GPIO_MODER_Offset;
    S0.SetBits2(LEDred, reg, MODER_Out);
    S0.SetBits2(LEDgreen, reg, MODER_Out);
    reg := MCU.GPIOH_BASE + MCU.GPIO_OSPEEDR_Offset;
    S0.SetBits2(LEDred, reg, OSPEED_High);
    S0.SetBits2(LEDgreen, reg, OSPEED_High)
  END init;


  PROCEDURE run;
    VAR i: INTEGER; leds: SET;
  BEGIN
    leds := {LEDred, LEDgreen + 16};
    REPEAT
      S0.ToggleLED(leds);
      i := 0;
      WHILE i < 100000 DO INC(i) END
    UNTIL FALSE
  END run;

BEGIN
  init;
  run
END NS0.
