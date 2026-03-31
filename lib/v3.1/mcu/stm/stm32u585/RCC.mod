MODULE RCC;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Reset and clock controller
  Security functionality
  See CLK and RST for clock and reset control
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV0;

  CONST
    KeepSecure* = 0;
    ReleaseSecure* = 1;

  TYPE
    ReleaseSecCfg* = RECORD
      hsi48*: INTEGER;
      pll1*, pll2*, pll3*: INTEGER;
      lse*, lsi*: INTEGER;
      msi*: INTEGER;
      hse*, hsi*: INTEGER;
      iclk*: INTEGER;
      rmRstFlag*: INTEGER
    END;


  PROCEDURE* SecureAll*;
  BEGIN
    SYSTEM.PUT(CFG.RCC_SEC, CFG.RCC_SEC_ALL)
  END SecureAll;


  PROCEDURE* GetBaseReleaseSecCfg*(VAR cfg: ReleaseSecCfg);
  BEGIN
    CLEAR(cfg)
  END GetBaseReleaseSecCfg;


  PROCEDURE* ReleaseSec*(cfg: ReleaseSecCfg);
    VAR val: INTEGER; currentVal: SET;
  BEGIN
    val := 0;
    BFI(val, CFG.RCC_SEC_RMVF, cfg.rmRstFlag);
    BFI(val, CFG.RCC_SEC_HSI48, cfg.hsi48);
    BFI(val, CFG.RCC_SEC_ICLK, cfg.iclk);
    BFI(val, CFG.RCC_SEC_PLL3, cfg.pll3);
    BFI(val, CFG.RCC_SEC_PLL2, cfg.pll2);
    BFI(val, CFG.RCC_SEC_PLL1, cfg.pll1);
    BFI(val, CFG.RCC_SEC_LSE, cfg.lse);
    BFI(val, CFG.RCC_SEC_LSI, cfg.lsi);
    BFI(val, CFG.RCC_SEC_MSI, cfg.msi);
    BFI(val, CFG.RCC_SEC_HSE, cfg.hse);
    BFI(val, CFG.RCC_SEC_HSI, cfg.hsi);
    SYSTEM.GET(CFG.RCC_SEC, currentVal);
    SYSTEM.PUT(CFG.RCC_SEC, currentVal * (-BITS(val)))
  END ReleaseSec;

END RCC.
