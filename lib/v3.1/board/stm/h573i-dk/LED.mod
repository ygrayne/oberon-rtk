MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Red, blue, orange and green user LEDs
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  * Four LEDs, active low.
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
    LEDredPinNo = 1; (* port F *)
    LEDbluePinNo = 4; (* port F *)
    LEDorangePinNo = 8; (* port I *)
    LEDgreenPinNo = 9;  (* port I *)

    Pico* = LEDgreenPinNo;
    Red* = LEDredPinNo;
    Blue* = LEDbluePinNo;
    Orange* = LEDorangePinNo;
    Green* = LEDgreenPinNo;

    LEDx = {LEDredPinNo, LEDbluePinNo, LEDorangePinNo, LEDgreenPinNo};

    (* note: active low *)
    (* red and blue *)
    LSET0* = DEV.GPIOF_BASE + DEV.GPIO_BRR_Offset;
    LCLR0* = DEV.GPIOF_BASE + DEV.GPIO_BSRR_Offset;
    (* orange and green *)
    LSET1* = DEV.GPIOI_BASE + DEV.GPIO_BRR_Offset;
    LCLR1* = DEV.GPIOI_BASE + DEV.GPIO_BSRR_Offset;

    LED0 = {LEDredPinNo, LEDbluePinNo};
    LED1 = {LEDorangePinNo, LEDgreenPinNo};


  PROCEDURE* Set*(leds: SET);
    VAR led0, led1: SET;
  BEGIN
    led0 := leds * LED0;
    led1 := leds * LED1;
    SYSTEM.PUT(LSET0, led0);
    SYSTEM.PUT(LSET1, led1)
  END Set;


  PROCEDURE* Clear*(leds: SET);
    VAR led0, led1: SET;
  BEGIN
    led0 := leds * LED0;
    led1 := leds * LED1;
    SYSTEM.PUT(LCLR0, led0);
    SYSTEM.PUT(LCLR1, led1)
  END Clear;


  PROCEDURE Toggle*(leds: SET);
    VAR led0, led1: SET;
  BEGIN
    led0 := leds * LED0;
    IF led0 # {} THEN
      GPIO.Toggle(GPIO.PORTF, led0)
    END;
    led1 := leds * LED1;
    IF led1 # {} THEN
      GPIO.Toggle(GPIO.PORTI, led1)
    END
  END Toggle;


  PROCEDURE Config*;
    VAR cfg: GPIO.PinCfg;
  BEGIN
    GPIO.GetPinBaseCfg(cfg);
    cfg.mode := GPIO.ModeOut;
    GPIO.ConfigurePin(GPIO.PORTF, LEDredPinNo, cfg);
    GPIO.ConfigurePin(GPIO.PORTF, LEDbluePinNo, cfg);
    GPIO.ConfigurePin(GPIO.PORTI, LEDorangePinNo, cfg);
    GPIO.ConfigurePin(GPIO.PORTI, LEDgreenPinNo, cfg);
    Clear(LEDx)
  END Config;

END LED.
