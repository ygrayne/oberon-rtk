MODULE PWR;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Power management
  --
  Type: MCU
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* VOS *)
    Range0* = 3;  (* 1.30 - 1.40 V, 250 MHz *)
    Range1* = 2;  (* 1.15 - 1.26 V, 200 MHz *)
    Range2* = 1;  (* 1.05 - 1.15 V, 150 MHz *)
    Range3* = 0;  (* 0.95 - 1.05 V, 100 MHz, reset *)

    (* PWR_VOSSR bits and values *)
    PWR_VOSSR_ACTVOSRDY = 13;


  PROCEDURE* SetVoltageRange*(range: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.PWR_VOSCR, val);
    BFI(val, 5, 4, range);
    SYSTEM.PUT(MCU.PWR_VOSCR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.PWR_VOSSR, PWR_VOSSR_ACTVOSRDY)
  END SetVoltageRange;

END PWR.
