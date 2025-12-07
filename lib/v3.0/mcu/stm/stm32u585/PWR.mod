MODULE PWR;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Power management
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    Range1* = 3;  (* 1.2 V, 160 MHz *)
    Range2* = 2;  (* 1.1 V, 110 MHz *)
    Range3* = 1;  (* 1.0 V, 55 MHz *)
    Range4* = 0;  (* 0.9 V, 25 MHz, reset *)

    (* PWR_VOSR bits and values *)
    PWR_VOSR_BOOSTEN = 18;
    PWR_VOSR_VOSRDY = 15;
    PWR_VOSR_BOOSTRDY = 14;


  PROCEDURE* SetVoltageRange*(range: INTEGER);
  (* set CLK.SetEPODboost *)
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.PWR_VOSR, val);
    BFI(val, 17, 16, range);
    SYSTEM.PUT(MCU.PWR_VOSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.PWR_VOSR, PWR_VOSR_VOSRDY);
    SYSTEM.GET(MCU.PWR_VOSR, val);
    IF range > 1 THEN
      BFI(val, PWR_VOSR_BOOSTEN, 1);
      SYSTEM.PUT(MCU.PWR_VOSR, val);
      REPEAT UNTIL SYSTEM.BIT(MCU.PWR_VOSR, PWR_VOSR_BOOSTRDY)
    ELSE
      BFI(val, PWR_VOSR_BOOSTEN, 0);
      SYSTEM.PUT(MCU.PWR_VOSR, val)
    END;

  END SetVoltageRange;


  PROCEDURE* init;
    CONST PWREN = 2;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.RCC_AHB3ENR, val);
    INCL(val, PWREN);
    SYSTEM.PUT(MCU.RCC_AHB3ENR, val)
  END init;

BEGIN
  init
END PWR.
