MODULE LED;
(**
  Oberon RTK Framework v2
  --
  Green LED on Pico and Pico2
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Usage:
  * Via SIO:
    GPIO.Set({LED.Pico}),
    GPIO.Clear({LED.Pico},
    GPIO.Toggle({LED.Pico})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.LSET, {LED.Pico}),
    SYSTEM.PUT(LED.LCLR, {LED.Pico}),
    SYSTEM.PUT(LED.LXOR, {LED.Pico})
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT MCU := MCU2, GPIO;

  CONST
    LEDpinNo = 25;
    Green* = LEDpinNo; (* Pico2-Ice compatibility *)
    Pico* = LEDpinNo;
    LSET* = MCU.SIO_GPIO_OUT_SET;
    LCLR* = MCU.SIO_GPIO_OUT_CLR;
    LXOR* = MCU.SIO_GPIO_OUT_XOR;

  PROCEDURE init;
  BEGIN
    GPIO.SetFunction(LEDpinNo, MCU.IO_BANK0_Fsio);
    GPIO.Clear({LEDpinNo});
    GPIO.OutputEnable({LEDpinNo})
  END init;

BEGIN
  init
END LED.
