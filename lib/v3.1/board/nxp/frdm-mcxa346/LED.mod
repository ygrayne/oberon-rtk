MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Green, red and blue LEDs
  --
  MCU: MCXA346
  Board: FRDM-MCXA346
  --
  * LEDs are active low.
  * LEDs are parts of an RGB LED, so colours get visually mixed.
  --
  Usage:
  * Via procedures:
    LED.Set({LED.Green})
    LED.Clear({LED.Green})
    LED.Toggle({LED.Green})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.LSET, {LED.Green})
    SYSTEM.PUT(LED.LCLR, {LED.Red})
    SYSTEM.PUT(LED.LXOR, {LED.Blue})
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, RST, CLK, GPIO;

  CONST
    LEDgreenPinNo = 19; (* all on port 3 *)
    LEDredPinNo = 18;
    LEDbluePinNo = 21;

    Pico* = LEDgreenPinNo;
    Green* = LEDgreenPinNo;
    Red* = LEDredPinNo;
    Blue* = LEDbluePinNo;

    LEDx = {LEDredPinNo, LEDgreenPinNo, LEDbluePinNo};

    LSET* = MCU.GPIO3_BASE + MCU.GPIO_PCOR_Offset; (* clear pin for LED = on *)
    LCLR* = MCU.GPIO3_BASE + MCU.GPIO_PSOR_Offset;
    LXOR* = MCU.GPIO3_BASE + MCU.GPIO_PTOR_Offset;


  PROCEDURE* Set*(leds: SET);
  BEGIN
    leds := leds * LEDx;
    SYSTEM.PUT(LSET, leds)
  END Set;

  PROCEDURE* Clear*(leds: SET);
  BEGIN
    leds := leds * LEDx;
    SYSTEM.PUT(LCLR, leds)
  END Clear;

  PROCEDURE* Toggle*(leds: SET);
  BEGIN
    leds := leds * LEDx;
    SYSTEM.PUT(LXOR, leds)
  END Toggle;


  PROCEDURE init;
  BEGIN
    RST.ReleaseReset(MCU.DEV_PORT3);
    RST.ReleaseReset(MCU.DEV_GPIO3);
    CLK.EnableBusClock(MCU.DEV_PORT3);
    CLK.EnableBusClock(MCU.DEV_GPIO3);
    GPIO.EnableOutput(MCU.GPIO3, LEDx);
    Clear(LEDx)
  END init;

BEGIN
  init
END LED.
