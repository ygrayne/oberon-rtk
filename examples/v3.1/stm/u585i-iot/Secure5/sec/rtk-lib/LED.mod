MODULE LED;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Green and red user LEDs
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

  IMPORT SYSTEM, DEV2, DEV0;

  CONST
    LEDredPinNo = 6; (* port H *)
    LEDgreenPinNo = 7;

    Pico* = LEDgreenPinNo;
    Green* = LEDgreenPinNo;
    Red* = LEDredPinNo;

    LEDx* = {LEDredPinNo, LEDgreenPinNo};

    LSET* = DEV2.GPIOH_BASE + DEV2.GPIO_BRR_Offset;
    LCLR* = DEV2.GPIOH_BASE + DEV2.GPIO_BSRR_Offset;

    GPIOH_ODR = DEV2.GPIOH_BASE + DEV2.GPIO_ODR_Offset;
    GPIOH_BSRR = DEV2.GPIOH_BASE + DEV2.GPIO_BSRR_Offset;
    GPIOH_MODER = DEV2.GPIOH_BASE + DEV2.GPIO_MODER_Offset;
    GPIOH_BC_reg = DEV0.RCC_AHB2ENR1;
    GPIOH_BC_pos = 7;
    ModeOut = 1;

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
    SYSTEM.GET(GPIOH_ODR, val);
    leds := leds * LEDx;
    val := val * leds;
    rst := BITS(LSL(ORD(val), 16));
    set := val / leds;
    val := set + rst;
    SYSTEM.PUT(GPIOH_BSRR, val)
  END Toggle;


  PROCEDURE cfgPin(pin, MODE: INTEGER);
    VAR addr: INTEGER; val, mask: SET;
  BEGIN
    pin := pin * 2;
    mask := BITS(LSL(03H, pin));
    addr := GPIOH_MODER;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(MODE, pin));
    SYSTEM.PUT(addr, val)
  END cfgPin;


  PROCEDURE Init*;
    VAR val: SET;
  BEGIN
    (* bus clock *)
    SYSTEM.GET(GPIOH_BC_reg, val);
    SYSTEM.PUT(GPIOH_BC_reg, val + {GPIOH_BC_pos});
    (* pin cfg, all as reset + ModeOut *)
    cfgPin(LEDredPinNo, ModeOut);
    cfgPin(LEDgreenPinNo, ModeOut);
    Clear(LEDx)
  END Init;

END LED.
