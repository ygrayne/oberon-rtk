MODULE LED;
(**
  Oberon RTK Framework
  Green LED on Pico
  --
  MCU: RP2040
  Board: Pico
  --
  Usage:
  * Via SIO:
    GPIO.Set({LED.Green}),
    GPIO.Clear({LED.Green},
    GPIO.Toggle({LED.Green})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.SET, {LED.Green}),
    SYSTEM.PUT(LED.CLR, {LED.Green}),
    SYSTEM.PUT(LED.XOR, {LED.Green})
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, MCU := MCU2;

  CONST
    LEDpinNo = 25;
    Green* = LEDpinNo;
    SET* = MCU.SIO_GPIO_OUT_SET;
    CLR* = MCU.SIO_GPIO_OUT_CLR;
    XOR* = MCU.SIO_GPIO_OUT_XOR;

  PROCEDURE init;
  BEGIN
    GPIO.SetFunction(LEDpinNo, GPIO.Fsio);
    GPIO.OutputEnable({LEDpinNo})
  END init;

BEGIN
  init
END LED.
