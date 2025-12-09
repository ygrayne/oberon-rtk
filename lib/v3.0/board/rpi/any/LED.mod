MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Green LED on Pico and Pico2
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Usage:
  * Via procedures:
    LED.Set({LED.Pico}),
    LED.Clear({LED.Pico},
    LED.Toggle({LED.Pico})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.LSET, {LED.Pico}),
    SYSTEM.PUT(LED.LCLR, {LED.Pico}),
    SYSTEM.PUT(LED.LXOR, {LED.Pico})
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, GPIO;

  CONST
    LEDpinNo = 25;
    Green* = LEDpinNo;
    Pico* = LEDpinNo;

    LSET* = MCU.SIO_GPIO_OUT_SET;
    LCLR* = MCU.SIO_GPIO_OUT_CLR;
    LXOR* = MCU.SIO_GPIO_OUT_XOR;

  PROCEDURE* Set*(leds: SET);
  BEGIN
    SYSTEM.PUT(LSET, leds)
  END Set;

  PROCEDURE* Clear*(leds: SET);
  BEGIN
    SYSTEM.PUT(LCLR, leds)
  END Clear;

  PROCEDURE* Toggle*(leds: SET);
  BEGIN
    SYSTEM.PUT(LXOR, leds)
  END Toggle;

  PROCEDURE init;
  BEGIN
    GPIO.SetFunction(LEDpinNo, GPIO.Fsio);
    GPIO.EnableOutput(MCU.GPIO0, {LEDpinNo});
    GPIO.Clear(MCU.GPIO0, {LEDpinNo})
  END init;

BEGIN
  init
END LED.
