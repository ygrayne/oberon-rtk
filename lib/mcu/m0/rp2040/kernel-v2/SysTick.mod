MODULE SysTick;
(**
  Oberon RTK Framework
  System tick
  for Kernel v2: use sys tick interrupt
  --
  Each core has its own sys tick, ie. registers
  are not shared.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions;

  CONST
    (* bits *)
    SYST_CSR_COUNTFLAG = 16;
    SYST_CSR_ENABLE = 0;
    SYST_CSR_TICKINT = 1;

    CountPerMillisecond = MCU.SysTickFreq DIV 1000;


  PROCEDURE InstallHandler*(handler: PROCEDURE);
  BEGIN
    Exceptions.InstallExcHandler(MCU.SysTickHandlerOffset, handler)
  END InstallHandler;


  PROCEDURE SetPrio*(prio: INTEGER);
  BEGIN
    Exceptions.SetSysExcPrio(Exceptions.SysExcSysTickNo, prio)
  END SetPrio;


  PROCEDURE Enable*;
  BEGIN
    SYSTEM.PUT(MCU.SYST_CSR, {SYST_CSR_TICKINT, SYST_CSR_ENABLE})
  END Enable;


  PROCEDURE Init*(millisecondsPerTick: INTEGER);
    VAR cntReload: INTEGER;
  BEGIN
    cntReload := millisecondsPerTick * CountPerMillisecond - 1;
    SYSTEM.PUT(MCU.SYST_RVR, cntReload);
    SYSTEM.PUT(MCU.SYST_CVR, 0) (* clear counter *)
  END Init;

END SysTick.
