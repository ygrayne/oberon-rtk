MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Green LED on Pico and Pico2
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Usage:
  * Via procedures:
    LED.Set,
    LED.Clear,
    LED.Toggle
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.LSET, {LED.Pico}),
    SYSTEM.PUT(LED.LCLR, {LED.Pico}),
    SYSTEM.PUT(LED.LXOR, {LED.Pico})
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, GPIO, SIO := SIOgpio, SIO_DEV;

  CONST
    LEDpinNo = 25;

    Green* = LEDpinNo;
    Pico* = LEDpinNo;

    LSET* = SIO_DEV.SIO_GPIO_OUT_SET;
    LCLR* = SIO_DEV.SIO_GPIO_OUT_CLR;
    LXOR* = SIO_DEV.SIO_GPIO_OUT_XOR;

  PROCEDURE* Set*;
  BEGIN
    SYSTEM.PUT(LSET, {LEDpinNo})
  END Set;

  PROCEDURE* Clear*;
  BEGIN
    SYSTEM.PUT(LCLR, {LEDpinNo})
  END Clear;

  PROCEDURE* Toggle*;
  BEGIN
    SYSTEM.PUT(LXOR, {LEDpinNo})
  END Toggle;


  PROCEDURE Config*;
  BEGIN
    GPIO.SetFunction(LEDpinNo, GPIO.Fsio);
    SIO.EnableOutput(SIO.GPIOA, {LEDpinNo});
    Clear
  END Config;

END LED.
