MODULE LEDext;
(**
  Oberon RTK Framework
  Four additional LEDs for the Pico.
  Include also the green one on the Pico for convenience.
  --
  MCU: RP2040
  Board: Pico
  --
  Usage:
  * Via SIO:
    GPIO.Set({LEDext.LED0}),
    GPIO.Clear({LEDext.LED0},
    GPIO.Toggle({LEDext.LED0})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LEDext.SET, {LEDext.LED0}),
    SYSTEM.PUT(LEDext.CLR, {LEDext.LED0}),
    SYSTEM.PUT(LEDext.XOR, {LEDext.LED0})
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, MCU := MCU2;

  CONST
    LEDpinNoPico = 25;
    LEDpinNo0 = 19;
    LEDpinNo1 = 18;
    LEDpinNo2 = 17;
    LEDpinNo3 = 16;
    LEDpico* = LEDpinNoPico;
    LED0* = LEDpinNo0;
    LED1* = LEDpinNo1;
    LED2* = LEDpinNo2;
    LED3* = LEDpinNo3;
    SET* = MCU.SIO_GPIO_OUT_SET;
    CLR* = MCU.SIO_GPIO_OUT_CLR;
    XOR* = MCU.SIO_GPIO_OUT_XOR;

  PROCEDURE init;
  BEGIN
    GPIO.SetFunction(LEDpinNoPico, GPIO.Fsio);
    GPIO.OutputEnable({LEDpinNoPico});
    GPIO.SetFunction(LEDpinNo0, GPIO.Fsio);
    GPIO.OutputEnable({LEDpinNo0});
    GPIO.SetFunction(LEDpinNo1, GPIO.Fsio);
    GPIO.OutputEnable({LEDpinNo1});
    GPIO.SetFunction(LEDpinNo2, GPIO.Fsio);
    GPIO.OutputEnable({LEDpinNo2});
    GPIO.SetFunction(LEDpinNo3, GPIO.Fsio);
    GPIO.OutputEnable({LEDpinNo3});
  END init;

BEGIN
  init
END LEDext.
