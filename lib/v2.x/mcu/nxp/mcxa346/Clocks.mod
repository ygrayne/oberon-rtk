MODULE Clocks;
(**
  Oberon RTK Framework
  --
  Clocks configuration and initialisation at start-up.
  --
  MCU: MCX-A346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors; (*, TextIO, Texts, Main;*)

  CONST
    (* PLL clock *)
    SYSCLK* = 160 * 1000000;
    CPUCLK* = SYSCLK;
    BUSCLK* = SYSCLK DIV 2;
    FRO_LF_DIV* = 12 * 1000000;
    FRO_HF_DIV* = 45 * 1000000;


    (* SCG_FIRCCFG bits and values *)
    FREQ_SEL_1 = 3;
    FREQ_SEL_0 = 1;
      FREQ_SEL_val_45 = 1;
      FREQ_SEL_val_60 = 3;
      FREQ_SEL_val_90 = 5;
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
    FIRCVLD = 24;
    FIRCERR = 26;
    FIRCEN = 0;

    (* SCG_SOSCCSR bits and values *)
      SOSCVLD = 24;
      SOSCEN = 0;

    (* SCG_SOSCCFG bits and values *)
      EREFS = 2;

    (* SCG_SPLLCSR bits and values *)
      SPLL_LOCK = 24;
      SPLLPWREN = 0;
      SPLLCLKEN = 1;

    (* SCG_SPLLCTRL bits and values *)
      SOURCE_1 = 26;
      SOURCE_0 = 25;
        SOURCE_val_SOSC = 0;
        SOURCE_val_FIRC45 = 1; (* set FIRC_SCLK_PERIPH_EN in SCG_FIRCCSR *)
        SOURCE_val_ROSC = 2;
        SOURCE_val_SIRC = 3; (* 12 MHz *)
      FRM = 22;
      BYPASSPOSTDIV = 20;   (* PDIV *)
      BYPASSPREDIV = 19;    (* NDIV *)
      BYPASSPOSTDIV2 = 16;
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
      LDOEN = 0;

    (* SPC_ACTIVE_CFG bits and values *)
    CORELDO_VDD_LV_1 = 3;
    CORELDO_VDD_LV_0 = 2;
      CORELDO_VDD_LV_val_OD = 3;

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


  PROCEDURE setDividers;
  BEGIN
    SYSTEM.PUT(MCU.SYSCON_FROLFDIV, 0);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_FROLFDIV, UNSTABLE);
    SYSTEM.PUT(MCU.SYSCON_FROHFDIV, 0);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_FROHFDIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_AHBCLKDIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_BUSCLKDIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_SLOWCLKDIV, UNSTABLE)
  END setDividers;


  PROCEDURE isFircFreq(freq: INTEGER): BOOLEAN;
    RETURN  (freq = FIRC_45) OR
            (freq = FIRC_60) OR
            (freq = FIRC_90) OR
            (freq = FIRC_180)
  END isFircFreq;


  PROCEDURE InitFIRC*(freq: INTEGER);
    VAR set, val: INTEGER;
  BEGIN
    ASSERT(isFircFreq(freq), Errors.PreCond);

    (* set OD voltage *)
    SYSTEM.GET(MCU.SPC_ACTIVE_CFG, val);
    BFI(val, CORELDO_VDD_LV_1, CORELDO_VDD_LV_0, CORELDO_VDD_LV_val_OD);
    SYSTEM.PUT(MCU.SPC_ACTIVE_CFG, val);

    (* temporarily set system clock to SIRC *)
    set := LSL(SCS_val_SIRC, SCS_0);
    SYSTEM.PUT(MCU.SCG_RCCR, set);
    REPEAT
      SYSTEM.GET(MCU.SCG_CSR, val)
    UNTIL val = set;

    (* init SCG_FIRCCSR *)
    SYSTEM.PUT(MCU.SCG_FIRCCSR, 0);

    (* set FIRC frequency *)
    SYSTEM.GET(MCU.SCG_FIRCCFG, val);
    SYSTEM.PUT(MCU.SCG_FIRCCFG, LSL(freq, FREQ_SEL_0));

    (* config FIRC *)
    SYSTEM.GET(MCU.SCG_FIRCCSR, val);
    BFI(val, FIRC_SCLK_PERIPH_EN, 1);
    BFI(val, FIRC_FCLK_PERIPH_EN, 0);
    BFI(val, FIRCEN, 1);
    SYSTEM.PUT(MCU.SCG_FIRCCSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_FIRCCSR, FIRCVLD);

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
    setDividers

  END InitFIRC;



  PROCEDURE selp(mdiv: INTEGER): INTEGER;
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

  PROCEDURE seli(mdiv: INTEGER): INTEGER;
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
    CONST
      NDIV = 1; PDIV = 1; MDIV = 20;
      BypassNDIV = 1; BypassPDIV = 1; BypassPDIV2 = 1;
      RWSC = RWSC_val_160;
    VAR set, val: INTEGER;
  BEGIN
    (* LDO: enable *)
    SYSTEM.GET(MCU.SCG_LDOCSR, val);
    BFI(val, LDOEN, 1);
    SYSTEM.PUT(MCU.SCG_LDOCSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_LDOCSR, VOUT_OK);

    (* SOSC: select internal crystal oscillator *)
    SYSTEM.GET(MCU.SCG_SOSCCFG, val);
    BFI(val, EREFS, 1);
    SYSTEM.PUT(MCU.SCG_SOSCCFG, val);

    (* SOSC: enable  *)
    SYSTEM.GET(MCU.SCG_SOSCCSR, val);
    BFI(val, SOSCEN, 1);
    SYSTEM.PUT(MCU.SCG_SOSCCSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_SOSCCSR, SOSCVLD);

    (* SPLL: select source, divider bypasses *)
    SYSTEM.GET(MCU.SCG_SPLLCTRL, val);
    BFI(val, SOURCE_1, SOURCE_0, SOURCE_val_SOSC);
    BFI(val, BYPASSPOSTDIV, BypassPDIV);
    BFI(val, BYPASSPREDIV, BypassNDIV);
    BFI(val, BYPASSPOSTDIV2, BypassPDIV2);
    SYSTEM.PUT(MCU.SCG_SPLLCTRL, val);

    (* SPLL: set SELx *)
    SYSTEM.GET(MCU.SCG_SPLLCTRL, val);
    BFI(val, SELP_1, SELP_0, selp(MDIV));
    BFI(val, SELI_1, SELI_0, seli(MDIV));
    BFI(val, SELR_1, SELR_0, 0);
    SYSTEM.PUT(MCU.SCG_SPLLCTRL, val);

    (* SPLL: dividers *)
    val := 0;
    BFI(val, NDIV_1, NDIV_0, NDIV);
    SYSTEM.PUT(MCU.SCG_SPLLNDIV, val);
    val := 0;
    BFI(val, MDIV_1, MDIV_0, MDIV);
    SYSTEM.PUT(MCU.SCG_SPLLMDIV, val);
    val := 0;
    BFI(val, PDIV_1, PDIV_0, PDIV);
    SYSTEM.PUT(MCU.SCG_SPLLPDIV, val);

    (* SPLL: power up and enable *)
    SYSTEM.GET(MCU.SCG_SPLLCSR, val);
    BFI(val, SPLLPWREN, 1);
    BFI(val, SPLLCLKEN, 1);
    SYSTEM.PUT(MCU.SCG_SPLLCSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_SPLLCSR, SPLL_LOCK);

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
    (*
    (* disable FIRC *)
    SYSTEM.GET(MCU.SCG_FIRCCSR, val);
    BFI(val, FIRCEN, 0);
    SYSTEM.PUT(MCU.SCG_FIRCCSR, val);
    *)
    (* set clock dividers, await stable *)
    setDividers

  END InitSPLL;

END Clocks.

