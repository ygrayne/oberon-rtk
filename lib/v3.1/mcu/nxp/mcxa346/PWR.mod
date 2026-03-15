MODULE PWR;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  SPC system power controller driver
  --
  Type: MCU
  --
  MCU: MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  CONST
    (* 'voltSel' *)
    Volt_MD* = 1; (* 1.0 V core & SRAM *)
    Volt_ND* = 2; (* 1.1 V core & SRAM *)
    Volt_OD* = 3; (* 1.2 V, core only *)


  PROCEDURE* SetActiveLDOvoltage*(voltSel: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SPC_ACTIVE_CFG, val);
    BFI(val, 3, 2, voltSel);
    SYSTEM.PUT(MCU.SPC_ACTIVE_CFG, val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SPC_SC, 0)
  END SetActiveLDOvoltage;


  PROCEDURE* SetSRAMvoltage*(voltSel: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SPC_SRAMCTL, val);
    BFI(val, 1, 0, voltSel);
    SYSTEM.PUT(MCU.SPC_SRAMCTL, val);

    SYSTEM.GET(MCU.SPC_SRAMCTL, val);
    BFI(val, 30, 1);
    SYSTEM.PUT(MCU.SPC_SRAMCTL, val);
    REPEAT
      SYSTEM.GET(MCU.SPC_SRAMCTL, val)
    UNTIL 31 IN BITS(val);

    BFI(val, 30, 0);
    SYSTEM.PUT(MCU.SPC_SRAMCTL, val)
  END SetSRAMvoltage;

END PWR.
