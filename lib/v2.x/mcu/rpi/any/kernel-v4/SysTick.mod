MODULE SysTick;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  System tick
  Enable interrupt and install an interrupt handler
  so we can use WFE/WFI in kernel loop.
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM,MCU := MCU2, Clocks, Exceptions;

  CONST
    (* bits *)
    SYST_CSR_COUNTFLAG = 16;
    SYST_CSR_ENABLE = 0;
    SYST_CSR_TICKINT = 1;

    CountPerMillisecond = Clocks.SysTickFreq DIV 1000;


  PROCEDURE* Tick*(): BOOLEAN;
    RETURN SYSTEM.BIT(MCU.PPB_SYST_CSR, SYST_CSR_COUNTFLAG)
  END Tick;


  PROCEDURE* Enable*;
  BEGIN
    SYSTEM.PUT(MCU.PPB_SYST_CSR, {SYST_CSR_TICKINT, SYST_CSR_ENABLE})
  END Enable;


  PROCEDURE tickHandler[0];
  END tickHandler;


  PROCEDURE Init*(millisecondsPerTick, prio: INTEGER; handler: PROCEDURE);
    VAR cntReload: INTEGER;
  BEGIN
    IF handler = NIL THEN handler := tickHandler END;
    Exceptions.InstallSysExcHandler(MCU.PPB_SysTick_Exc, handler);
    Exceptions.SetSysExcPrio(MCU.PPB_SysTick_Exc, prio);
    cntReload := millisecondsPerTick * CountPerMillisecond - 1;
    SYSTEM.PUT(MCU.PPB_SYST_RVR, cntReload);
    SYSTEM.PUT(MCU.PPB_SYST_CVR, 0) (* clear counter *)
  END Init;

END SysTick.
