MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  SCG system clock generator device driver.
  --
  Type: MCU
  --
  MCU: MCXA346
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
    SysClk_SPLL* = 6;

    (* for FIRCcfg.freq *)
    FIRC_frq_45*  = 1;
    FIRC_frq_60*  = 3;
    FIRC_frq_90*  = 5;
    FIRC_frq_180* = 7;

    (* for SetClkOut *)
    CLKOUT_CLKLF*     = 0; (* fro_12m *)
    CLKOUT_CLKHF_DIV* = 1; (* fro_hf_div *)
    CLKOUT_CLKIN*     = 2;
    CLKOUT_CLK16K*    = 3;
    CLKOUT_SPLL*      = 5;
    CLKOUT_SLOWCLK*   = 6;
    CLKOUT_NONE*      = 7; (* reset *)


  TYPE
    FIRCcfg* = RECORD
      freq*: INTEGER;         (* FIRC_Frq_* above *)
      periFastEn*: INTEGER;   (* MCU.SCG_FIRC_CSR.FIRC_FCLK_PERIPH_EN *)
      periSlowEn*: INTEGER    (* MCU.SCG_FIRC_CSR.FIRC_SCLK_PERIPH_EN *)
    END;

    SIRCcfg* = RECORD
      periEn*: INTEGER    (* MCU.SCG_SIRC_CSR.SIRC_CLK_PERIPH_EN *)
    END;

    PLLcfg* = RECORD
      (* ... *)
    END;

    DivCfg* = RECORD
      sysClkDiv*: INTEGER;  (* mainclk to sysclk divider MCU.SYSCON_AHBCLK_DIV *)
      froHFhalt*, froHFdiv*: INTEGER; (* FIRC divider MCU.SYSCON_FROHF_DIV *)
      froLFhalt*, froLFdiv*: INTEGER; (* SIRC divider MCU.SYSCON_FROLF_DIV *)
      spllHalt*, spllDiv*: INTEGER    (* SPLL divider MCU.SYSCON_PLL1CLK_DIV *)
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


  PROCEDURE* ConfigDividers*(cfg: DivCfg);
    CONST UNSTABLE = 31;
    VAR val: INTEGER;
  BEGIN
    val := 0;
    BFI(val, 7, 0, cfg.sysClkDiv);
    SYSTEM.PUT(MCU.SYSCON_AHBCLK_DIV, val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_AHBCLK_DIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_SLOWCLK_DIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_BUSCLK_DIV, UNSTABLE);
    IF cfg.froLFhalt = Disabled THEN
      val := 0;
      BFI(val, 7, 0, cfg.froLFdiv);
      BFI(val, 30, cfg.froLFhalt);
      SYSTEM.PUT(MCU.SYSCON_FROLF_DIV, val);
      REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_FROLF_DIV, UNSTABLE)
    END;
    IF cfg.froHFhalt = Disabled THEN
      val := 0;
      BFI(val, 7, 0, cfg.froHFdiv);
      BFI(val, 30, cfg.froHFhalt);
      SYSTEM.PUT(MCU.SYSCON_FROHF_DIV, val);
      REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_FROHF_DIV, UNSTABLE)
    END;
    IF cfg.spllHalt = Disabled THEN
      val := 0;
      BFI(val, 7, 0, cfg.spllDiv);
      BFI(val, 30, cfg.spllHalt);
      SYSTEM.PUT(MCU.SYSCON_PLL1CLK_DIV, val);
      REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_PLL1CLK_DIV, UNSTABLE)
    END
  END ConfigDividers;


  PROCEDURE* EnableBusClock*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.MRCC_GLB_CC0_SET + (reg * MCU.MRCC_GLB_CC_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END EnableBusClock;


  PROCEDURE* DisableBusClock*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.MRCC_GLB_CC0_CLR + (reg * MCU.MRCC_GLB_CC_Offset);
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

