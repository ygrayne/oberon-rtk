MODULE SYST;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  System tick driver
  --
  Type: Cortex-M33
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, Exceptions, Errors;

  CONST
    (* clock source *)
    (* parameter 'clkSel' in 'Configure' *)
    CLK_HCLK* = 0;
    CLK_LSI* = 1;
    CLK_LSE* = 2;
    CLK_None* = 3; (* off *)

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


  PROCEDURE Configure*(clkFreq, msPerTick: INTEGER);
    VAR cntPerMillisec, cntRld: INTEGER;
  BEGIN
    cntPerMillisec := clkFreq DIV 1000;
    cntRld := (msPerTick * cntPerMillisec) - 1;
    ASSERT(cntRld <= 0FFFFFFH, Errors.ProgError); (* 24 bits *)
    SYSTEM.PUT(PPB.SYST_RVR, cntRld);
    SYSTEM.PUT(PPB.SYST_CVR, 0) (* clear counter *)
  END Configure;

END SYST.
