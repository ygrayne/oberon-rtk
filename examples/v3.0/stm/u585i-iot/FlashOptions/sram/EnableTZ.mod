MODULE EnableTZ;
(**
  Oberon RTK Framework v3.0
  --
  Enable TrustZone.
  This MUST be run from SRAM, since flash mem must not be busy.
  Power-cycle required to load the new option TZEN = 1.
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, FLASH;

  CONST
    GPIOH_BSSR    = MCU.GPIOH_BASE + MCU.GPIO_BSRR_Offset;

    LEDgreen = 7; (* GPIOH *)
    LEDred   = 6;

    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE* setBits2(pin, addr, twoBitValue: INTEGER);
    VAR val, mask: SET;
  BEGIN
    twoBitValue := twoBitValue MOD 04H;
    twoBitValue := LSL(twoBitValue, pin * 2);
    SYSTEM.GET(addr, val);
    mask := BITS(LSL(03H, pin * 2));
    val := val * (-mask);
    val := val + BITS(twoBitValue);
    SYSTEM.PUT(addr, val)
  END setBits2;


  PROCEDURE init;
    VAR val: SET; reg, devNo: INTEGER;
  BEGIN
    (* enable GPIOH clock *)
    reg := MCU.DEV_GPIOH DIV 32;
    reg := MCU.RCC_AHB1ENR + (reg * 4);
    devNo := MCU.DEV_GPIOH MOD 32;
    SYSTEM.GET(reg, val);
    val := val + {devNo};
    SYSTEM.PUT(reg, val);

    (* set-up GPIOH for the leds *)
    reg := MCU.GPIOH_BASE + MCU.GPIO_MODER_Offset;
    setBits2(LEDred, reg, MODER_Out);
    setBits2(LEDgreen, reg, MODER_Out);
    reg := MCU.GPIOH_BASE + MCU.GPIO_OSPEEDR_Offset;
    setBits2(LEDred, reg, OSPEED_High);
    setBits2(LEDgreen, reg, OSPEED_High)
  END init;


  PROCEDURE run;
    CONST Mask = {LEDred, LEDgreen, LEDred + 16, LEDgreen + 16};
    VAR i: INTEGER; leds: SET;
  BEGIN
    FLASH.EnableTrustZone;
    leds := {LEDred, LEDgreen + 16};
    REPEAT
      SYSTEM.PUT(GPIOH_BSSR, leds);
      leds := leds / Mask;
      i := 0;
      WHILE i < 100000 DO INC(i) END
    UNTIL FALSE
  END run;

BEGIN
  init;
  run
END EnableTZ.
