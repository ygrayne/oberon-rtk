MODULE SysTick;
(**
  Oberon RTK Framework
  System tick
  For Kernel v1
  --
  Each core has its own sys tick, ie. registers
  are not shared.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* bits *)
    SYST_CSR_COUNTFLAG = 16;
    SYST_CSR_ENABLE = 0;

    CountPerMillisecond = MCU.SysTickFreq DIV 1000;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYSTEM.BIT(MCU.SYST_CSR, SYST_CSR_COUNTFLAG)
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYSTEM.PUT(MCU.SYST_CSR, {SYST_CSR_ENABLE})
  END Enable;


  PROCEDURE Init*(millisecondsPerTick: INTEGER);
    VAR cntReload: INTEGER;
  BEGIN
    cntReload := millisecondsPerTick * CountPerMillisecond - 1;
    SYSTEM.PUT(MCU.SYST_RVR, cntReload);
    SYSTEM.PUT(MCU.SYST_CVR, 0) (* clear counter *)
  END Init;

END SysTick.
