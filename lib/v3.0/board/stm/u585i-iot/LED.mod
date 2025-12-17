MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Green, red and blue LEDs
  --
  Type: Board
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
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, CLK, GPIO;

  CONST
    LEDredPinNo = 6; (* port H *)
    LEDgreenPinNo = 7;

    Pico* = LEDgreenPinNo;
    Green* = LEDgreenPinNo;
    Red* = LEDredPinNo;

    LEDx = {LEDredPinNo, LEDgreenPinNo};

    LSET* = MCU.GPIOH_BASE + MCU.GPIO_BRR_Offset;
    LCLR* = MCU.GPIOH_BASE + MCU.GPIO_BSRR_Offset;


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


  PROCEDURE* Toggle*(leds: SET);
    VAR val, rst, set: SET;
  BEGIN
    SYSTEM.GET(MCU.GPIOH_BASE + MCU.GPIO_ODR_Offset, val);
    leds := leds * LEDx;
    val := val * leds;
    rst := BITS(LSL(ORD(val), 16));
    set := val / leds;
    val := set + rst;
    SYSTEM.PUT(MCU.GPIOH_BASE + MCU.GPIO_BSRR_Offset, val)
  END Toggle;


  PROCEDURE init;
    VAR cfg: GPIO.PadCfg;
  BEGIN
    cfg.mode := GPIO.ModeOut;
    cfg.type := GPIO.TypePushPull;
    cfg.speed := GPIO.SpeedLow;
    cfg.pulls := GPIO.PullNone;
    CLK.EnableBusClock(MCU.DEV_GPIOH);
    GPIO.ConfigurePad(MCU.PORTH, LEDredPinNo, cfg);
    GPIO.ConfigurePad(MCU.PORTH, LEDgreenPinNo, cfg);
    Clear(LEDx)
  END init;

BEGIN
  init
END LED.
