MODULE SYST;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  System tick driver
  --
  Type: Cortex-M33, Cortex-M0+
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, Exceptions, Errors;

  CONST
    (* CSR bits *)
    SYST_CSR_COUNTFLAG = 16;
    SYST_CSR_TICKINT = 1;
    SYST_CSR_ENABLE = 0;


  PROCEDURE* Tick*(): BOOLEAN;
    RETURN SYSTEM.BIT(PPB.SYST_CSR, SYST_CSR_COUNTFLAG)
  END Tick;


  PROCEDURE* Enable*;
  BEGIN
    SYSTEM.PUT(PPB.SYST_CSR, {SYST_CSR_ENABLE})
  END Enable;


  PROCEDURE* EnableExc*;
  BEGIN
    SYSTEM.PUT(PPB.SYST_CSR, {SYST_CSR_TICKINT, SYST_CSR_ENABLE})
  END EnableExc;


  PROCEDURE InstallExcHandler*(handler: PROCEDURE; prio: INTEGER);
  BEGIN
    Exceptions.InstallSysExcHandler(PPB.EXC_SysTick, handler);
    Exceptions.SetSysExcPrio(PPB.EXC_SysTick, prio)
  END InstallExcHandler;


  PROCEDURE* Configure*(clkFreq, msPerTick: INTEGER);
    VAR cntPerMillisec, cntRld: INTEGER;
  BEGIN
    cntPerMillisec := clkFreq DIV 1000;
    cntRld := (msPerTick * cntPerMillisec) - 1;
    ASSERT(cntRld <= 0FFFFFFH, Errors.ProgError); (* 24 bits *)
    SYSTEM.PUT(PPB.SYST_RVR, cntRld);
    SYSTEM.PUT(PPB.SYST_CVR, 0) (* clear counter *)
  END Configure;


END SYST.
