MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  SCG system clock generator device driver.
  --
  Type: MCU
  --
  MCU: MCXN947
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2; (*, TextIO, Texts, Main;*)

  CONST
    Enabled* = 1;
    Disabled* = 0;

    (* for 'SetSysClk' *)
    SysClk_SOSC* = 1;
    SysClk_SIRC* = 2;
    SysClk_FIRC* = 3;
    SysClk_ROSC* = 4;
    SysClk_APLL* = 5;
    SysClk_SPLL* = 6;
    SysClk_UPLL* = 7;

    (* for FIRCcfg.freq *)
    FIRC_frq_48*  = 0;
    FIRC_frq_144* = 1;

    (* for ConfigClkOut *)
    CLKOUT_MAIN*    = 0;
    CLKOUT_APLL*    = 1;
    CLKOUT_CLKIN*   = 2;
    CLKOUT_FRO_HF*  = 3;
    CLKOUT_CLK12M*  = 4;
    CLKOUT_SPLL*    = 5;
    CLKOUT_CLK16K*  = 6;
    CLKOUT_UPLL*    = 7;

    (* for DivCfg.pllSel *)
    PLLdiv_APLL* = 0;
    PLLdiv_SPLL* = 1;
    PLLdiv_NONE* = 2;


  TYPE
    FIRCcfg* = RECORD
      freq*: INTEGER;       (* FIRC_Frq_* above *)
      periFastEn*: INTEGER; (* MCU.SCG_FIRC_CSR.FIRC_FCLK_PERIPH_EN *)
      periSlowEn*: INTEGER  (* MCU.SCG_FIRC_CSR.FIRC_SCLK_PERIPH_EN *)
    END;

    SIRCcfg* = RECORD
      periEn*: INTEGER  (* MCU.SCG_SIRC_CSR.SIRC_CLK_PERIPH_EN *)
    END;

    PLLcfg* = RECORD
      (* ... *)
    END;

    DivCfg* = RECORD
      sysClkDiv*: INTEGER;  (* mainclk to sysclk divider MCU.SYSCON_AHBCLK_DIV *)
      froHFhalt*, froHFdiv*: INTEGER;   (* FIRC divider MCU.SYSCON_FROHF_DIV *)
      spllHalt0*, spllDiv0*: INTEGER;   (* SPLL divider MCU.SYSCON_PLL1CLK0_DIV *)
      spllHalt1*, spllDiv1*: INTEGER;   (* SPLL divider MCU.SYSCON_PLL1CLK1_DIV *)
      pllHalt*, pllDiv*: INTEGER;       (* SPLL/APLL divider MCU.SYSCON_PLLCLK_DIV *)
      pllSel*: INTEGER                  (* select input for MCU.SYSCON_PLLCLK_DIV *)
    END;


  PROCEDURE* SetSysClk*(sysClk: INTEGER);
    VAR set, val: INTEGER;
  BEGIN
    set := 0;
    BFI(set, 27, 24, sysClk);
    SYSTEM.PUT(MCU.SCG_RCCR, set);
    REPEAT
      SYSTEM.GET(MCU.SCG_CSR, val)
    UNTIL val = set
  END SetSysClk;


  PROCEDURE* ConfigFIRC*(cfg: FIRCcfg);
    CONST SCLK_PERIPH_EN = 4; FCLK_PERIPH_EN = 5;
    VAR val: INTEGER;
  BEGIN
    SYSTEM.PUT(MCU.SCG_FIRC_CSR, 0);
    SYSTEM.PUT(MCU.SCG_FIRC_CFG, LSL(cfg.freq, 1));
    BFI(val, SCLK_PERIPH_EN, cfg.periSlowEn);
    BFI(val, FCLK_PERIPH_EN, cfg.periFastEn);
    SYSTEM.PUT(MCU.SCG_FIRC_CSR, val)
  END ConfigFIRC;


  PROCEDURE* EnableFIRC*;
    CONST FIRC_EN = 0; FIRC_VLD = 24;
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SCG_FIRC_CSR, val);
    BFI(val, FIRC_EN, 1);
    SYSTEM.PUT(MCU.SCG_FIRC_CSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_FIRC_CSR, FIRC_VLD)
  END EnableFIRC;


  PROCEDURE* ConfigSIRC*(cfg: SIRCcfg);
    CONST SIRC_PERIPH_EN = 5;
    VAR val: INTEGER;
  BEGIN
    SYSTEM.PUT(MCU.SCG_SIRC_CSR, 0);
    BFI(val, SIRC_PERIPH_EN, cfg.periEn);
    SYSTEM.PUT(MCU.SCG_SIRC_CSR, val)
  END ConfigSIRC;


  PROCEDURE* EnableCLK1M*;
    CONST CLK1M_EN = 6;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.SYSCON_CLK_CTRL, val);
    val := val + {CLK1M_EN};
    SYSTEM.PUT(MCU.SYSCON_CLK_CTRL, val)
  END EnableCLK1M;


  PROCEDURE* ConfigDividers*(cfg: DivCfg);
    CONST UNSTABLE = 31;
    VAR val: INTEGER;
  BEGIN
    val := 0;
    BFI(val, 7, 0, cfg.sysClkDiv);
    SYSTEM.PUT(MCU.SYSCON_AHBCLK_DIV, val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_AHBCLK_DIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_SLOWCLK_DIV, UNSTABLE);
    IF cfg.froHFhalt = Disabled THEN
      val := 0;
      BFI(val, 7, 0, cfg.froHFdiv);
      BFI(val, 30, cfg.froHFhalt);
      SYSTEM.PUT(MCU.SYSCON_FROHF_DIV, val);
      REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_FROHF_DIV, UNSTABLE)
    END;
    IF cfg.spllHalt0 = Disabled THEN
      val := 0;
      BFI(val, 7, 0, cfg.spllDiv0);
      BFI(val, 30, cfg.spllHalt0);
      SYSTEM.PUT(MCU.SYSCON_PLL1CLK0_DIV, val);
      REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_PLL1CLK0_DIV, UNSTABLE)
    END;
    IF cfg.spllHalt1 = Disabled THEN
      val := 0;
      BFI(val, 7, 0, cfg.spllDiv1);
      BFI(val, 30, cfg.spllHalt1);
      SYSTEM.PUT(MCU.SYSCON_PLL1CLK1_DIV, val);
      REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_PLL1CLK1_DIV, UNSTABLE)
    END;
    IF cfg.pllHalt = Disabled THEN
      val := 0;
      BFI(val, 7, 0, cfg.pllDiv);
      BFI(val, 30, cfg.pllHalt);
      SYSTEM.PUT(MCU.SYSCON_PLLCLK_DIV, val);
      REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_PLLCLK_DIV, UNSTABLE)
    END;
    val := 0;
    BFI(val, 2, 0, cfg.pllSel);
    SYSTEM.PUT(MCU.SYSCON_PLLCLKDIV_SEL, val)
  END ConfigDividers;


  PROCEDURE* EnableBusClock*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.SYSCON_AHBCLK_CTRL0_SET + (reg * MCU.SYSCON_AHBCLK_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END EnableBusClock;


  PROCEDURE* DisableBusClock*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.SYSCON_AHBCLK_CTRL0_CLR + (reg * MCU.SYSCON_AHBCLK_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END DisableBusClock;


  PROCEDURE* ConfigDevClock*(clkSel, clkDiv, clkSelReg, clkDivReg: INTEGER);
  (* set functional clock *)
  (* use with clock disabled *)
    CONST CLKDIV_UNSTABLE = 31;
  BEGIN
    clkSel := clkSel MOD 8H;
    clkDiv := clkDiv MOD 10H;
    SYSTEM.PUT(clkSelReg, clkSel);
    SYSTEM.PUT(clkDivReg, clkDiv);
    REPEAT UNTIL ~SYSTEM.BIT(clkDivReg, CLKDIV_UNSTABLE)
  END ConfigDevClock;


  PROCEDURE ConfigClkOut*(clkSel, clkDiv: INTEGER);
  BEGIN
    ConfigDevClock(clkSel, clkDiv, MCU.CLKSEL_CLKOUT, MCU.CLKDIV_CLKOUT)
  END ConfigClkOut;

END CLK.

