MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Kernel-v4
  System tick
  Enable interrupt and install an interrupt handler
  so we can use WFE/WFI in kernel loop.
  --
  MCU: MCXA346, MCXN947
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Clocks, Exceptions;

  CONST
    (* bits *)
    SYST_CSR_COUNTFLAG = 16;
    SYST_CSR_ENABLE = 0;
    SYST_CSR_TICKINT = 1;


  PROCEDURE* Tick*(): BOOLEAN;
    RETURN SYSTEM.BIT(MCU.PPB_SYST_CSR, SYST_CSR_COUNTFLAG)
  END Tick;


  PROCEDURE* Enable*;
  BEGIN
    SYSTEM.PUT(MCU.PPB_SYST_CSR, {SYST_CSR_TICKINT, SYST_CSR_ENABLE})
  END Enable;


  PROCEDURE tickHandler[0];
  END tickHandler;


  PROCEDURE Config*(usPerTick, prio: INTEGER; handler: PROCEDURE);
  (* SysTick clock freq = 1 MHz *)
    VAR cntRld: INTEGER;
  BEGIN
    IF handler = NIL THEN handler := tickHandler END;
    Exceptions.InstallSysExcHandler(MCU.EXC_SysTick, handler);
    Exceptions.SetSysExcPrio(MCU.EXC_SysTick, prio);
    Clocks.SetSysTickClock; (* 1 MHz *)
    cntRld := usPerTick - 1;
    SYSTEM.PUT(MCU.PPB_SYST_RVR, cntRld);
    SYSTEM.PUT(MCU.PPB_SYST_CVR, 0) (* clear counter *)
  END Config;

END SysTick.
