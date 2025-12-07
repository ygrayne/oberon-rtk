MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  System tick
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, CLK, Clocks, Errors;

  CONST
    (* clock source *)
    Src_HCLK = 0;

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
    CONST PosSel = 22; TwoBits = 2;
    VAR cntPerMicrosec, cntRld: INTEGER;
  BEGIN
    CLK.ConfigDevClock(MCU.RCC_CCIPR1, Src_HCLK, PosSel, TwoBits);
    cntPerMicrosec := (Clocks.HCLK_FRQ DIV 8) DIV 1000000;
    cntRld := (usPerTick * cntPerMicrosec) - 1;
    ASSERT(cntRld <= 0FFFFFFH, Errors.ProgError);
    SYSTEM.PUT(MCU.PPB_SYST_RVR, cntRld);
    SYSTEM.PUT(MCU.PPB_SYST_CVR, 0) (* clear counter *)
  END Config;

END SysTick.
