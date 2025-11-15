MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Green, red and blue LEDs
  --
  MCU: MCX-N947
  Board: FRDM-MCXN947
  --
  * LEDs are active low.
  * LEDs are parts of an RGB LED, so colours get visually mixed.
  --
  Usage:
  * Via procedures:
    LED.Set({LED.Green})
    LED.Clear({LED.Red})
    LED.Toggle({LED.Blue})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.LSET0, {LED.Green})
    SYSTEM.PUT(LED.LCLR0, {LED.Red})
    SYSTEM.PUT(LED.LXOR1, {LED.Blue})
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, StartUp, GPIO;

  CONST
    LEDgreenPinNo = 27; (* port 0 *)
    LEDredPinNo = 10;   (* port 0 *)
    LEDbluePinNo = 2;   (* port 1 *)

    Pico* = LEDgreenPinNo;
    Green* = LEDgreenPinNo;
    Red* = LEDredPinNo;
    Blue* = LEDbluePinNo;

    LEDx = {LEDredPinNo, LEDgreenPinNo, LEDbluePinNo};
    LED0 = {LEDredPinNo, LEDgreenPinNo};
    LED1 = {LEDbluePinNo};

    (* red and green *)
    LSET0* = MCU.GPIO0_BASE + MCU.GPIO_PCOR_Offset; (* clear pin for LED = on *)
    LCLR0* = MCU.GPIO0_BASE + MCU.GPIO_PSOR_Offset;
    LXOR0* = MCU.GPIO0_BASE + MCU.GPIO_PTOR_Offset;

    (* blue *)
    LSET1* = MCU.GPIO1_BASE + MCU.GPIO_PCOR_Offset; (* clear pin for LED = on *)
    LCLR1* = MCU.GPIO1_BASE + MCU.GPIO_PSOR_Offset;
    LXOR1* = MCU.GPIO1_BASE + MCU.GPIO_PTOR_Offset;


  PROCEDURE* Set*(leds: SET);
  BEGIN
    IF ~(Blue IN leds) THEN
      SYSTEM.PUT(LSET0, leds)
    ELSE
      EXCL(leds, Blue);
      SYSTEM.PUT(LSET0, leds);
      SYSTEM.PUT(LSET1, {Blue})
    END
  END Set;

  PROCEDURE* Clear*(leds: SET);
  BEGIN
    IF ~(Blue IN leds) THEN
      SYSTEM.PUT(LCLR0, leds)
    ELSE
      EXCL(leds, Blue);
      SYSTEM.PUT(LCLR0, leds);
      SYSTEM.PUT(LCLR1, {Blue})
    END
  END Clear;

  PROCEDURE* Toggle*(leds: SET);
  BEGIN
    IF ~(Blue IN leds) THEN
      SYSTEM.PUT(LXOR0, leds)
    ELSE
      EXCL(leds, Blue);
      SYSTEM.PUT(LXOR0, leds);
      SYSTEM.PUT(LXOR1, {Blue})
    END
  END Toggle;


  PROCEDURE init;
  BEGIN
    StartUp.EnableClock(MCU.DEV_PORT0);
    StartUp.EnableClock(MCU.DEV_GPIO0);
    GPIO.EnableOutput(MCU.GPIO0, LED0);
    StartUp.EnableClock(MCU.DEV_PORT1);
    StartUp.EnableClock(MCU.DEV_GPIO1);
    GPIO.EnableOutput(MCU.GPIO1, LED1);
    Clear(LEDx)
  END init;

BEGIN
  init
END LED.
