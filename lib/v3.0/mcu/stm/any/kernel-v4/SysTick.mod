MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  System tick for kernel-v4
  Enable interrupt and install an interrupt handler
  so we can use WFE/WFI in kernel loop.
  --
  MCU: STM32U585AI, STM32H573II
  --
  Note the 24 bit limitation on the reload and counter registers. If SysTick is running off
  HCLK/8 with HCLK at 160 MHz, this limits the maximum achievable SysTick interval to
  about 800 ms.
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, CLK, Clocks, Exceptions, Errors;

  CONST
    (* clock source *)
    Src_HCLK = 0;

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
    CONST TwoBits = 2;
    VAR cntPerMicrosec, cntRld: INTEGER;
  BEGIN
    IF handler = NIL THEN handler := tickHandler END;
    Exceptions.InstallSysExcHandler(MCU.EXC_SysTick, handler);
    Exceptions.SetSysExcPrio(MCU.EXC_SysTick, prio);
    CLK.ConfigDevClock(CLK.CLK_SYST_REG, Src_HCLK, CLK.CLK_SYST_POS, TwoBits);
    cntPerMicrosec := (Clocks.HCLK_FRQ DIV 8) DIV 1000000;
    cntRld := (usPerTick * cntPerMicrosec) - 1;
    ASSERT(cntRld <= 0FFFFFFH, Errors.ProgError);
    SYSTEM.PUT(MCU.PPB_SYST_RVR, cntRld);
    SYSTEM.PUT(MCU.PPB_SYST_CVR, 0) (* clear counter *)
  END Config;

END SysTick.
