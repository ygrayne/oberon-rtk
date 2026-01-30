MODULE NS;
(**
  Oberon RTK Framework v3.0
  --
  Experimental program Secure1
  https://oberon-rtk.org/docs/examples/v3/secure1/
  Non-secure program, uses Secure module S0
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, S0 := NS_S0, Main;

  CONST
    (* Non-secure GPIOH registers *)
    GPIOH_BSSR = MCU.GPIOH_BASE + MCU.GPIO_BSRR_Offset;
    GPIOH_MODER = MCU.GPIOH_BASE + MCU.GPIO_MODER_Offset;
    GPIOH_OSPEEDR = MCU.GPIOH_BASE + MCU.GPIO_OSPEEDR_Offset;

    LEDgreen = 7; (* GPIOH *)
    LEDred   = 6;
    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE cfgGPIO; (* Non-secure part *)
  (* set-up GPIOH for Non-secure pin LEDgreen *)
  BEGIN
    (* bus clock has been enabled by Secure program *)
    (* GPIOH pins have been set Non-secure by Secure program *)
    S0.SetBits2(LEDgreen, GPIOH_MODER, MODER_Out);
    S0.SetBits2(LEDgreen, GPIOH_OSPEEDR, OSPEED_High);
    SYSTEM.PUT(GPIOH_BSSR, {LEDgreen})
  END cfgGPIO;


  PROCEDURE toggleLED(VAR led: SET);
    CONST Mask = {LEDgreen, LEDgreen + 16};
  BEGIN
    SYSTEM.PUT(GPIOH_BSSR, led);
    led := led / Mask
  END toggleLED;


  PROCEDURE run;
    VAR i: INTEGER; ledRed, ledGreen: SET;
  BEGIN
    ledRed := {LEDred};
    ledGreen := {LEDgreen + 16};
    REPEAT
      S0.ToggleLED(ledRed);
      toggleLED(ledGreen);
      i := 0;
      WHILE i < 100000 DO INC(i) END
    UNTIL FALSE
  END run;

BEGIN
  cfgGPIO;
  run
END NS.
