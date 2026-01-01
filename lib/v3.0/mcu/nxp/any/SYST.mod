MODULE SYST;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  System tick driver
  --
  Type: Cortex-M33
  --
  MCU: MCXA346
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions, Errors;

  CONST
    (* clock source *)
    (* parameter 'clkSel' in 'Configure' *)
    CLK_SYSCLK* = 0;  (* MCXA346, CPU_CLK, divider after selector mux *)
    CLK_DIVCLK* = 0;  (* MCXN947, MAINCLK divided, divider before selector mux *)
    CLK_CLK1M* = 1;   (* MCXA346: divided; MCXN947: no divider *)
    CLK_CLK16K* = 2;  (* MCXA346: divided; MCXN947: no divider *)
    CLK_NONE* = 3;

    (* CSR bits *)
    SYST_CSR_COUNTFLAG = 16;
    SYST_CSR_TICKINT = 1;
    SYST_CSR_ENABLE = 0;


  PROCEDURE* Tick*(): BOOLEAN;
    RETURN SYSTEM.BIT(MCU.PPB_SYST_CSR, SYST_CSR_COUNTFLAG)
  END Tick;


  PROCEDURE* Enable*;
  BEGIN
    SYSTEM.PUT(MCU.PPB_SYST_CSR, {SYST_CSR_ENABLE})
  END Enable;


  PROCEDURE* EnableExc*;
  BEGIN
    SYSTEM.PUT(MCU.PPB_SYST_CSR, {SYST_CSR_TICKINT, SYST_CSR_ENABLE})
  END EnableExc;


  PROCEDURE InstallExcHandler*(handler: PROCEDURE; prio: INTEGER);
  BEGIN
    Exceptions.InstallSysExcHandler(MCU.EXC_SysTick, handler);
    Exceptions.SetSysExcPrio(MCU.EXC_SysTick, prio)
  END InstallExcHandler;


  PROCEDURE* Configure*(clkFreq, msPerTick: INTEGER);
    VAR cntPerMillisec, cntRld: INTEGER;
  BEGIN
    cntPerMillisec := clkFreq DIV 1000;
    cntRld := (msPerTick * cntPerMillisec) - 1;
    ASSERT(cntRld <= 0FFFFFFH, Errors.ProgError); (* 24 bits *)
    SYSTEM.PUT(MCU.PPB_SYST_RVR, cntRld);
    SYSTEM.PUT(MCU.PPB_SYST_CVR, 0) (* clear counter *)
  END Configure;

END SYST.
