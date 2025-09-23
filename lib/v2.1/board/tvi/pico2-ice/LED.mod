MODULE LED;
(**
  Oberon RTK Framework v2.1
  --
  Green, red and blue LEDs on Pico2-Ice
  --
  MCU: RRP2350B
  Board: Pico2-ICE
  --
  * LEDs are active low, so the signal is inverted (see init).
  * LEDs are parts of an RGB LED, so colours get visually mixed.
  --
  Usage:
  * Via SIO:
    GPIO.Set({LED.Green}),
    GPIO.Clear({LED.Red},
    GPIO.Toggle({LED.Blue})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.LSET, {LED.Green}),
    SYSTEM.PUT(LED.LCLR, {LED.Red}),
    SYSTEM.PUT(LED.LXOR, {LED.Blue})
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT MCU := MCU2, GPIO;

  CONST
    LEDgreenPinNo = 0;
    LEDredPinNo = 1;
    LEDbluePinNo = 9;
    Pico* = LEDgreenPinNo; (* Pico/Pico2 compatibility *)
    Green* = LEDgreenPinNo;
    Red* = LEDredPinNo;
    Blue* = LEDbluePinNo;
    LSET* = MCU.SIO_GPIO_OUT_SET;
    LCLR* = MCU.SIO_GPIO_OUT_CLR;
    LXOR* = MCU.SIO_GPIO_OUT_XOR;

  PROCEDURE init;
  BEGIN
    GPIO.SetFunction(LEDgreenPinNo, MCU.IO_BANK0_Fsio);
    GPIO.SetFunction(LEDredPinNo, MCU.IO_BANK0_Fsio);
    GPIO.SetFunction(LEDbluePinNo, MCU.IO_BANK0_Fsio);
    GPIO.SetInverters(LEDgreenPinNo, GPIO.InvOff, GPIO.InvOff, GPIO.InvOff, GPIO.InvOn);
    GPIO.SetInverters(LEDredPinNo, GPIO.InvOff, GPIO.InvOff, GPIO.InvOff, GPIO.InvOn);
    GPIO.SetInverters(LEDbluePinNo, GPIO.InvOff, GPIO.InvOff, GPIO.InvOff, GPIO.InvOn);
    GPIO.Clear({LEDgreenPinNo, LEDredPinNo, LEDbluePinNo});
    GPIO.OutputEnable({LEDgreenPinNo, LEDredPinNo, LEDbluePinNo})
  END init;

BEGIN
  init
END LED.
