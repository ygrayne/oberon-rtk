MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  System tick
  --
  MCU: MCXA346, MCXN947
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Clocks;

  CONST
    (* CSR bits *)
    SYST_CSR_COUNTFLAG = 16;
    SYST_CSR_ENABLE = 0;


  PROCEDURE* Tick*(): BOOLEAN;
    RETURN SYSTEM.BIT(MCU.PPB_SYST_CSR, SYST_CSR_COUNTFLAG)
  END Tick;


  PROCEDURE* Enable*;
  BEGIN
    SYSTEM.PUT(MCU.PPB_SYST_CSR, {SYST_CSR_ENABLE})
  END Enable;


  PROCEDURE Config*(usPerTick: INTEGER);
    VAR cntRld: INTEGER;
  BEGIN
    Clocks.SetSysTickClock;
    cntRld := usPerTick - 1;
    SYSTEM.PUT(MCU.PPB_SYST_RVR, cntRld);
    SYSTEM.PUT(MCU.PPB_SYST_CVR, 0) (* clear counter *)
  END Config;

END SysTick.
