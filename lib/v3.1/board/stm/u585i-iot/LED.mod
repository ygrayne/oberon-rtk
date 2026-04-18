MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Green and red user LEDs
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  * Two LEDs, active low.
  --
  Usage:
  * Via procedures:
    LED.Set({LED.Green})
    LED.Clear({LED.Green})
    LED.Toggle({LED.Green})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LED.LSET, {LED.Green})
    SYSTEM.PUT(LED.LCLR, {LED.Red})
    (* no XOR in hardware *)
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, GPIO, DEV := GPIO_DEV;

  CONST
    LEDredPinNo = 6; (* port H *)
    LEDgreenPinNo = 7; (* port H *)

    Pico* = LEDgreenPinNo;
    Green* = LEDgreenPinNo;
    Red* = LEDredPinNo;

    LEDx* = {LEDredPinNo, LEDgreenPinNo};

    (* note: active low *)
    LSET* = DEV.GPIOH_BASE + DEV.GPIO_BRR_Offset;
    LCLR* = DEV.GPIOH_BASE + DEV.GPIO_BSRR_Offset;


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


  PROCEDURE Toggle*(leds: SET);
  BEGIN
    leds := leds * LEDx;
    GPIO.Toggle(GPIO.PORTH, leds)
  END Toggle;


  PROCEDURE Config*;
    VAR cfg: GPIO.PinCfg;
  BEGIN
    GPIO.GetPinBaseCfg(cfg);
    cfg.mode := GPIO.ModeOut;
    GPIO.ConfigurePin(GPIO.PORTH, LEDredPinNo, cfg);
    GPIO.ConfigurePin(GPIO.PORTH, LEDgreenPinNo, cfg);
    Clear(LEDx)
  END Config;

END LED.
