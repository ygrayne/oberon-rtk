MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Red, blue, orange and green user LEDs
  --
  Type: Board
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
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, CLK, GPIO;

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

    (* red and blue *)
    LSET0* = MCU.GPIOF_BASE + MCU.GPIO_BRR_Offset;
    LCLR0* = MCU.GPIOF_BASE + MCU.GPIO_BSRR_Offset;

    (* orange and green *)
    LSET1* = MCU.GPIOI_BASE + MCU.GPIO_BRR_Offset;
    LCLR1* = MCU.GPIOI_BASE + MCU.GPIO_BSRR_Offset;

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


  PROCEDURE* Toggle*(leds: SET);
    VAR led0, led1, val, rst, set: SET;
  BEGIN
    led0 := leds * LED0;
    IF led0 # {} THEN
      SYSTEM.GET(MCU.GPIOF_BASE + MCU.GPIO_ODR_Offset, val);
      val := val * led0;
      rst := BITS(LSL(ORD(val), 16));
      set := val / led0;
      val := set + rst;
      SYSTEM.PUT(MCU.GPIOF_BASE + MCU.GPIO_BSRR_Offset, val)
    END;
    led1 := leds * LED1;
    IF led1 # {} THEN
      SYSTEM.GET(MCU.GPIOI_BASE + MCU.GPIO_ODR_Offset, val);
      val := val * led1;
      rst := BITS(LSL(ORD(val), 16));
      set := val / led1;
      val := set + rst;
      SYSTEM.PUT(MCU.GPIOI_BASE + MCU.GPIO_BSRR_Offset, val)
    END
  END Toggle;


  PROCEDURE init;
    VAR cfg: GPIO.PadCfg;
  BEGIN
    cfg.mode := GPIO.ModeOut;
    cfg.type := GPIO.TypePushPull;
    cfg.speed := GPIO.SpeedLow;
    cfg.pulls := GPIO.PullNone;
    CLK.EnableBusClock(MCU.DEV_GPIOF);
    GPIO.ConfigurePad(MCU.PORTF, LEDredPinNo, cfg);
    GPIO.ConfigurePad(MCU.PORTF, LEDbluePinNo, cfg);
    CLK.EnableBusClock(MCU.DEV_GPIOI);
    GPIO.ConfigurePad(MCU.PORTI, LEDorangePinNo, cfg);
    GPIO.ConfigurePad(MCU.PORTI, LEDgreenPinNo, cfg);
    Clear(LEDx)
  END init;

BEGIN
  init
END LED.
