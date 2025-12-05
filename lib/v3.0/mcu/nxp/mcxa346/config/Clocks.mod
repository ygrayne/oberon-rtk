MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Clocks configuration and initialisation at start-up.
  --
  MCU: MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors; (*, TextIO, Texts, Main;*)

  CONST
    (* oscillators *)
    (* frequency configurable *)
    FIRC_FRQ* = 180 * 1000000;  (* 45, 60, 90, 180 MHz, see InitFIRC *)
    SPLL_FRQ* = 160 * 1000000;  (* see InitSPLL *)

    (* frequency fixed *)
    SIRC_FRQ*     =  12 * 1000000;    (* gate: SIRC_CLK_PERIPH_EN = 1 (reset) *)
    CLK_1M_FRQ*   =  SIRC_FRQ DIV 12; (* always on *)
    ROSC_FRQ*     =         16384;
    SOSC_FRQ*     =   8 * 1000000;
    CLK_45M_FRQ*  =  45 * 1000000;     (* gate: FIRC_SCLK_PERIPH_EN = 1 *)

    (* derived clocks *)
    (* dividers SYSCON, actual div = (val + 1) *)
    SYSCON_AHBCLK_DIV_val*  = 0;  (* MAIN_CLK divider *)
    SYSCON_FROHF_DIV_val*   = 0;  (* FIRC divider *)
    SYSCON_FROLF_DIV_val*   = 0;  (* SIRC divider *)
    SYSCON_PLL1CLK_DIV_val* = 0;  (* SPLL divider *)

    FIRC_GATED_FRQ* = FIRC_FRQ; (* gate: FIRC_FCLK_PERIPH_EN = 1 *)
    FIRC_DIV_FRQ*   = FIRC_FRQ DIV (SYSCON_FROHF_DIV_val + 1);
    SIRC_DIV_FRQ*   = SIRC_FRQ DIV (SYSCON_FROLF_DIV_val + 1);
    SPLL_DIV_FRQ*   = SPLL_FRQ DIV (SYSCON_PLL1CLK_DIV_val + 1);


    (* SCG_FIRCCFG bits and values *)
    FREQ_SEL_1 = 3;
    FREQ_SEL_0 = 1;
      FREQ_SEL_val_45  = 1;
      FREQ_SEL_val_60  = 3;
      FREQ_SEL_val_90  = 5;
      FREQ_SEL_val_180 = 7;

    (* value aliases *)
    FIRC_45*  = FREQ_SEL_val_45;
    FIRC_60*  = FREQ_SEL_val_60;
    FIRC_90*  = FREQ_SEL_val_90;
    FIRC_180* = FREQ_SEL_val_180;

    (* SCG_FIRCCSR bits and values *)
    LK = 23;
    FIRC_FCLK_PERIPH_EN = 5;
    FIRC_SCLK_PERIPH_EN = 4;
    FIRC_VLD = 24;
    FIRC_ERR = 26;
    FIRC_EN = 0;

    (* SCG_SOSCCSR bits and values *)
    SOSC_VLD = 24;
    SOSC_EN = 0;

    (* SCG_SOSCCFG bits and values *)
    EREFS = 2;

    (* SCG_SPLLCSR bits and values *)
    SPLL_LOCK = 24;
    SPLL_PWREN = 0;
    SPLL_CLKEN = 1;

    (* SCG_SPLLCTRL bits and values *)
    SOURCE_1 = 26;
    SOURCE_0 = 25;
      SOURCE_val_SOSC = 0;
      SOURCE_val_FIRC45 = 1; (* set FIRC_SCLK_PERIPH_EN in SCG_FIRCCSR *)
      SOURCE_val_ROSC = 2;
      SOURCE_val_SIRC = 3; (* 12 MHz *)
    FRM = 22;
    BYPASS_POSTDIV = 20;   (* PDIV *)
    BYPASS_PREDIV = 19;    (* NDIV *)
    BYPASS_POSTDIV2 = 16;
    SELP_1 = 14;
    SELP_0 = 10;
    SELI_1 = 9;
    SELI_0 = 4;
    SELR_1 = 3;
    SELR_0 = 0;

    (* SCG_SPLLNDIV bits and values (pre-divider) *)
    NDIV_1 = 7;
    NDIV_0 = 0;

    (* SCG_SPLLMDIV bits and values (feedback-divider = multiplier *)
    MDIV_1 = 15;
    MDIV_0 = 0;

    (* SCG_SPLLPDIV bits and values (post-divider *)
    PDIV_1 = 4;
    PDIV_0 = 0;

    (*  SCG_RCCR and SCG_CSR bits and values *)
    SCS_1 = 26;
    SCS_0 = 24;
      SCS_val_SOSC = 1;
      SCS_val_SIRC = 2;
      SCS_val_FIRC = 3;
      SCS_val_ROSC = 4;
      SCS_val_SPLL = 6;

    (* SCG_LDOCSR bits and values *)
    VOUT_OK = 31;
    LDO_EN = 0;

    (* SPC_ACTIVE_CFG bits and values *)
    CORELDO_VDD_LVL_1 = 3;
    CORELDO_VDD_LVL_0 = 2;
      CORELDO_VDD_LVL_val_SD = 1; (* reset *)
      CORELDO_VDD_LVL_val_OD = 3;

    (* FMU_FCTRL bits and values *)
    RWSC_1 = 3;
    RWSC_0 = 0;
      RWSC_val_200  = 4;
      RWSC_val_160  = 3;
      RWSC_val_120  = 2;
      RWSC_val_80   = 1;
      RWSC_val_40   = 0;

    (* all divider registers bits and values *)
    UNSTABLE = 31;

  VAR
    MAIN_CLK_FRQ*, SYS_CLK_FRQ*, BUS_CLK_FRQ*, SLOW_CLK_FRQ*: INTEGER;


  PROCEDURE* setClockValues(mainClockFreq: INTEGER);
  BEGIN
    MAIN_CLK_FRQ := mainClockFreq;
    SYS_CLK_FRQ := MAIN_CLK_FRQ DIV (SYSCON_AHBCLK_DIV_val + 1);
    BUS_CLK_FRQ := SYS_CLK_FRQ DIV 2;  (* fixed divider *)
    SLOW_CLK_FRQ := SYS_CLK_FRQ DIV 6;  (* fixed divider *)
  END setClockValues;


  PROCEDURE* setDivider(divReg, divVal: INTEGER);
  BEGIN
    SYSTEM.PUT(divReg, divVal);
    REPEAT UNTIL ~SYSTEM.BIT(divReg, UNSTABLE)
  END setDivider;


  PROCEDURE* SetSysTickClock*;
  (* 1 MHz *)
    CONST
      CLK_1M = 1;
      CLKDIV_UNSTABLE = 31;
  BEGIN
    SYSTEM.PUT(MCU.CLKSEL_SYSTICK0, CLK_1M);
    SYSTEM.PUT(MCU.CLKDIV_SYSTICK0, 0);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.CLKDIV_SYSTICK0, CLKDIV_UNSTABLE)
  END SetSysTickClock;


  PROCEDURE* setODvoltage;
    VAR val: INTEGER;
  BEGIN
    (* core *)
    SYSTEM.GET(MCU.SPC_ACTIVE_CFG, val);
    BFI(val, CORELDO_VDD_LVL_1, CORELDO_VDD_LVL_0, CORELDO_VDD_LVL_val_OD);
    SYSTEM.PUT(MCU.SPC_ACTIVE_CFG, val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SPC_SC, 0);

    (* SRAM *)
    SYSTEM.GET(MCU.SPC_SRAMCTL, val);
    BFI(val, 1, 0, 2);
    SYSTEM.PUT(MCU.SPC_SRAMCTL, val);

    SYSTEM.GET(MCU.SPC_SRAMCTL, val);
    BFI(val, 30, 1);
    SYSTEM.PUT(MCU.SPC_SRAMCTL, val);
    REPEAT
      SYSTEM.GET(MCU.SPC_SRAMCTL, val)
    UNTIL 31 IN BITS(val);
    BFI(val, 30, 0);
    SYSTEM.PUT(MCU.SPC_SRAMCTL, val)
  END setODvoltage;


  PROCEDURE* isFircFreq(freq: INTEGER): BOOLEAN;
    RETURN  (freq = FIRC_45) OR
            (freq = FIRC_60) OR
            (freq = FIRC_90) OR
            (freq = FIRC_180)
  END isFircFreq;


  PROCEDURE InitFIRC*(freq: INTEGER);
    VAR set, val: INTEGER;
  BEGIN
    ASSERT(isFircFreq(freq), Errors.PreCond);

    (* overdrive voltage to core and SRAM *)
    setODvoltage;

    (* temporarily set system clock to SIRC *)
    set := LSL(SCS_val_SIRC, SCS_0);
    SYSTEM.PUT(MCU.SCG_RCCR, set);
    REPEAT
      SYSTEM.GET(MCU.SCG_CSR, val)
    UNTIL val = set;

    (* init SCG_FIRC_CSR *)
    SYSTEM.PUT(MCU.SCG_FIRC_CSR, 0);

    (* set FIRC frequency *)
    SYSTEM.PUT(MCU.SCG_FIRC_CFG, LSL(freq, FREQ_SEL_0));

    (* config FIRC *)
    SYSTEM.GET(MCU.SCG_FIRC_CSR, val);
    BFI(val, FIRC_SCLK_PERIPH_EN, 0);
    BFI(val, FIRC_FCLK_PERIPH_EN, 0);
    BFI(val, FIRC_EN, 1);
    SYSTEM.PUT(MCU.SCG_FIRC_CSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_FIRC_CSR, FIRC_VLD);

    (* set flash memory wait cycles *)
    SYSTEM.GET(MCU.FMU_FCTRL, val);
    CASE freq OF
      FREQ_SEL_val_45: set := RWSC_val_80
    | FREQ_SEL_val_60: set := RWSC_val_80
    | FREQ_SEL_val_90: set := RWSC_val_120
    | FREQ_SEL_val_180: set := RWSC_val_200
    END;
    BFI(val, RWSC_1, RWSC_0, set);
    SYSTEM.PUT(MCU.FMU_FCTRL, val);

    (* set system clock to FIRC *)
    set := LSL(SCS_val_FIRC, SCS_0);
    SYSTEM.PUT(MCU.SCG_RCCR, set);
    REPEAT
      SYSTEM.GET(MCU.SCG_CSR, val)
    UNTIL val = set;

    (* set clock dividers, await stable *)
    setDivider(MCU.SYSCON_AHBCLK_DIV, SYSCON_AHBCLK_DIV_val);
    setDivider(MCU.SYSCON_FROLF_DIV, SYSCON_FROLF_DIV_val);
    setDivider(MCU.SYSCON_FROHF_DIV, SYSCON_FROHF_DIV_val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_BUSCLK_DIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_SLOWCLK_DIV, UNSTABLE);

    CASE freq OF
      FREQ_SEL_val_45: setClockValues(45000000)
    | FREQ_SEL_val_60: setClockValues(60000000)
    | FREQ_SEL_val_90: setClockValues(90000000)
    | FREQ_SEL_val_180: setClockValues(180000000)
    END
  END InitFIRC;



  PROCEDURE* selp(mdiv: INTEGER): INTEGER;
    VAR a0, a: INTEGER;
  BEGIN
    a0 := (mdiv DIV 4) + 1;
    IF a0 < 31 THEN
      a := a0
    ELSE
      a := 31
    END
    RETURN a
  END selp;

  PROCEDURE* seli(mdiv: INTEGER): INTEGER;
    VAR a0, a: INTEGER;
  BEGIN
    ASSERT(mdiv < 122);
    a0 := 2 * (mdiv DIV 4) + 3;
    IF a0 < 63 THEN
      a := a0
    ELSE
      a := 63
    END
    RETURN a
  END seli;


  PROCEDURE InitSPLL*;
  (* source: use 8 MHz SOSC *)
  (* set to 160 MHz *)
    CONST
      NDIV = 1; PDIV = 1; MDIV = 20;
      BypassNDIV = 1; BypassPDIV = 1; BypassPDIV2 = 1;
      RWSC = RWSC_val_160;
    VAR set, val: INTEGER;
  BEGIN
    (* overdrive voltage to core and SRAM *)
    setODvoltage;

    (* LDO: enable *)
    SYSTEM.GET(MCU.SCG_LDO_CSR, val);
    BFI(val, LDO_EN, 1);
    SYSTEM.PUT(MCU.SCG_LDO_CSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_LDO_CSR, VOUT_OK);

    (* SOSC: select internal crystal oscillator *)
    SYSTEM.GET(MCU.SCG_SOSC_CFG, val);
    BFI(val, EREFS, 1);
    SYSTEM.PUT(MCU.SCG_SOSC_CFG, val);

    (* SOSC: enable  *)
    SYSTEM.GET(MCU.SCG_SOSC_CSR, val);
    BFI(val, SOSC_EN, 1);
    SYSTEM.PUT(MCU.SCG_SOSC_CSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_SOSC_CSR, SOSC_VLD);

    (* SPLL: select source, divider bypasses *)
    SYSTEM.GET(MCU.SCG_SPLL_CTRL, val);
    BFI(val, SOURCE_1, SOURCE_0, SOURCE_val_SOSC);
    BFI(val, BYPASS_POSTDIV, BypassPDIV);
    BFI(val, BYPASS_PREDIV, BypassNDIV);
    BFI(val, BYPASS_POSTDIV2, BypassPDIV2);
    SYSTEM.PUT(MCU.SCG_SPLL_CTRL, val);

    (* SPLL: set SELx *)
    SYSTEM.GET(MCU.SCG_SPLL_CTRL, val);
    BFI(val, SELP_1, SELP_0, selp(MDIV));
    BFI(val, SELI_1, SELI_0, seli(MDIV));
    BFI(val, SELR_1, SELR_0, 0);
    SYSTEM.PUT(MCU.SCG_SPLL_CTRL, val);

    (* SPLL: dividers *)
    val := 0;
    BFI(val, NDIV_1, NDIV_0, NDIV);
    SYSTEM.PUT(MCU.SCG_SPLL_NDIV, val);
    val := 0;
    BFI(val, MDIV_1, MDIV_0, MDIV);
    SYSTEM.PUT(MCU.SCG_SPLL_MDIV, val);
    val := 0;
    BFI(val, PDIV_1, PDIV_0, PDIV);
    SYSTEM.PUT(MCU.SCG_SPLL_PDIV, val);

    (* SPLL: power up and enable *)
    SYSTEM.GET(MCU.SCG_SPLL_CSR, val);
    BFI(val, SPLL_PWREN, 1);
    BFI(val, SPLL_CLKEN, 1);
    SYSTEM.PUT(MCU.SCG_SPLL_CSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_SPLL_CSR, SPLL_LOCK);

    (* set flash memory wait cycles *)
    SYSTEM.GET(MCU.FMU_FCTRL, val);
    BFI(val, RWSC_1, RWSC_0, RWSC);
    SYSTEM.PUT(MCU.FMU_FCTRL, val);

    (* switch system clock *)
    set := LSL(SCS_val_SPLL, SCS_0);
    SYSTEM.PUT(MCU.SCG_RCCR, set);
    REPEAT
      SYSTEM.GET(MCU.SCG_CSR, val)
    UNTIL val = set;

    (* disable FIRC *)
    SYSTEM.GET(MCU.SCG_FIRC_CSR, val);
    BFI(val, FIRC_EN, 0);
    SYSTEM.PUT(MCU.SCG_FIRC_CSR, val);

    (* set clock dividers, await stable *)
    setDivider(MCU.SYSCON_AHBCLK_DIV, SYSCON_AHBCLK_DIV_val);
    setDivider(MCU.SYSCON_FROLF_DIV, SYSCON_FROLF_DIV_val);
    setDivider(MCU.SYSCON_PLL1CLK_DIV, SYSCON_PLL1CLK_DIV_val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_BUSCLK_DIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_SLOWCLK_DIV, UNSTABLE);

    setClockValues(SPLL_FRQ)
  END InitSPLL;

END Clocks.

