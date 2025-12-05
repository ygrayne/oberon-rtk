MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Clocks configuration and initialisation at start-up.
  --
  Note: this is a module with custom-made clock init procedures, with little or
  no parametrisation. Clock configuration changes require to edit the procedures.
  Reason: there are many different possible clock configurations, which could
  be implemented with complex, parameterisable init procedures, but given we only
  call these procedures once at start-up, it's just not worth the time and effort
  for implementaiton and testing.
  --
  MCU: MCXN947
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

  CONST
    (* oscillators *)
    (* frequency configurable *)
    FIRC_FRQ* = 144 * 1000000;  (* 48, 144 MHz, see InitFIRC *)
    SPLL_FRQ* = 120 * 1000000;  (* see InitSPLL *)
    APLL_FRQ* = 120 * 1000000;  (* see InitAPLL *)

    (* frequency fixed *)
    SIRC_FRQ*     =  12 * 1000000;    (* gate: SIRC_CLK_PERIPH_EN = 1 (reset) *)
    CLK_1M_FRQ*   =  SIRC_FRQ DIV 12; (* always on *)
    ROSC_FRQ*     =         16384;
    SOSC_FRQ*     =  24 * 1000000;    (* if enabled *)
    CLK_48M_FRQ*  =  48 * 1000000;    (* gate: FIRC_SCLK_PERIPH_EN = 1 *)

    (* derived clocks *)
    (* dividers SYSCON, actual div = (val + 1) *)
    SYSCON_AHBCLK_DIV_val*  = 0;  (* MAIN_CLK divider *)
    SYSCON_FROHF_DIV_val*   = 0;  (* FIRC divider *)
    SYSCON_PLL1CLK_DIV_val* = 0;  (* SPLL divider *)
    SYSCON_PLL0CLK_DIV_val* = 0;  (* APLL divider *)

    FIRC_GATED_FRQ* = FIRC_FRQ; (* gate: FIRC_FCLK_PERIPH_EN = 1 *)
    FIRC_DIV_FRQ*   = FIRC_FRQ DIV (SYSCON_FROHF_DIV_val + 1);
    SPLL_DIV_FRQ*   = SPLL_FRQ DIV (SYSCON_PLL1CLK_DIV_val + 1);
    APLL_DIV_FRQ*   = APLL_FRQ DIV (SYSCON_PLL0CLK_DIV_val + 1);


    (* SCG_FIRCCFG bits and values *)
    RANGE = 0;
      RANGE_val_48 = 0;
      RANGE_val_144 = 1;

    (* value aliases *)
    FIRC_48*  = RANGE_val_48;
    FIRC_144* = RANGE_val_144;

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
    SCS_1 = 27;
    SCS_0 = 24;
      SCS_val_SOSC = 1;
      SCS_val_SIRC = 2;
      SCS_val_FIRC = 3;
      SCS_val_ROSC = 4;
      SCS_val_APLL = 5;
      SCS_val_SPLL = 6;
      SCS_val_UPLL = 7;

    (* SCG_LDOCSR bits and values *)
    VOUT_OK = 31;
    LDO_EN = 0;

    (* SPC_ACTIVE_CFG bits and values *)
    CORELDO_VDD_LVL_1 = 3;
    CORELDO_VDD_LVL_0 = 2;
      CORELDO_VDD_LVL_val_MD = 1; (* 1.0 V, reset *)
      CORELDO_VDD_LVL_val_SD = 2; (* 1.1 V *)
      CORELDO_VDD_LVL_val_OD = 3; (* 1.2 V *)
    DCDC_VDD_LVL_1    = 11;
    DCDC_VDD_LVL_0    = 10;
      DCDC_VDD_LVL_val_MD = CORELDO_VDD_LVL_val_MD;
      DCDC_VDD_LVL_val_SD = CORELDO_VDD_LVL_val_SD;
      DCDC_VDD_LVL_val_OD = CORELDO_VDD_LVL_val_OD;

    (* SPC_SC bits and values *)
    SPC_SC_BUSY = 0;


    (* SPC_SRAM_CTRL bits and values *)
    SPC_SRAM_CTRL_REQ   = 30;
    SPC_SRAM_CTRL_ACK   = 31;
    SPC_SRAM_CTRL_VSM_1 = 1;
    SPC_SRAM_CTRL_VSM_0 = 0;
      SPC_SRAM_CTRL_VSM_10V = 1;
      SPC_SRAM_CTRL_VSM_11V = 2;

    (* FMU_FCTRL bits and values *)
    RWSC_1 = 3;
    RWSC_0 = 0;
      RWSC_val_OD_150  = 3; (* reset value *)
      RWSC_val_OD_100  = 2;
      RWSC_val_OD_64   = 1;
      RWSC_val_OD_36   = 0;

      RWSC_val_SD_100  = RWSC_val_OD_100;
      RWSC_val_SD_64   = RWSC_val_OD_64;
      RWSC_val_SD_36   = RWSC_val_OD_36;

      RWSC_val_MD_50   = RWSC_val_OD_64;
      RWSC_val_MD_24   = RWSC_val_OD_36;

    (* SYSCON_CLK_CTRL bits and values *)
    CLK_CTRL_CLK_1M_EN = 6;

    (* all divider registers bits and values *)
    UNSTABLE = 31;

  VAR
    MAIN_CLK_FRQ*, SYS_CLK_FRQ*, BUS_CLK_FRQ*, SLOW_CLK_FRQ*: INTEGER;


  PROCEDURE* SetSysTickClock*;
  (* 1 MHz *)
    CONST
      (*CLKDIV_OUT = 0;*)
      CLK_1M = 1;
      (*CLKDIV_UNSTABLE = 31;*)
    VAR (*div: INTEGER;*) val: SET;
  BEGIN
    (*
    SYSTEM.GET(MCU.SYSCON_CLK_CTRL, val);
    val := val + {CLK_CTRL_CLK_1M_EN};
    SYSTEM.PUT(MCU.SYSCON_CLK_CTRL, val);
    *)
    SYSTEM.PUT(MCU.CLKSEL_SYSTICK0, CLK_1M);
    SYSTEM.GET(MCU.CLKDIV_SYSTICK0, val);
    val := val + {30}; (* halt unused divider *)
    SYSTEM.PUT(MCU.CLKDIV_SYSTICK0, val);
    (*
    div := (MAIN_CLK_FRQ DIV freq) - 1;
    SYSTEM.PUT(MCU.CLKSEL_SYSTICK0, CLKDIV_OUT);
    SYSTEM.PUT(MCU.CLKDIV_SYSTICK0, div);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.CLKDIV_SYSTICK0, CLKDIV_UNSTABLE)
    *)
  END SetSysTickClock;


  PROCEDURE* enableClk1M;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.SYSCON_CLK_CTRL, val);
    val := val + {CLK_CTRL_CLK_1M_EN};
    SYSTEM.PUT(MCU.SYSCON_CLK_CTRL, val)
  END enableClk1M;


  PROCEDURE* setClockValues(mainClockFreq: INTEGER);
  BEGIN
    MAIN_CLK_FRQ := mainClockFreq;
    SYS_CLK_FRQ := MAIN_CLK_FRQ DIV (SYSCON_AHBCLK_DIV_val + 1);
    BUS_CLK_FRQ := SYS_CLK_FRQ DIV 2;  (* fixed divider *)
    SLOW_CLK_FRQ := SYS_CLK_FRQ DIV 4;  (* fixed divider *)
  END setClockValues;


  PROCEDURE* setDivider(divReg, divVal: INTEGER);
  BEGIN
    SYSTEM.PUT(divReg, divVal);
    REPEAT UNTIL ~SYSTEM.BIT(divReg, UNSTABLE)
  END setDivider;


  PROCEDURE* setODvoltage;
    VAR val: INTEGER;
  BEGIN
    (* glitch detectors are off, see Config.mod *)

    (* core *)
    SYSTEM.GET(MCU.SPC_ACTIVE_CFG, val);
    BFI(val, DCDC_VDD_LVL_1, DCDC_VDD_LVL_0, DCDC_VDD_LVL_val_OD);
    BFI(val, CORELDO_VDD_LVL_1, CORELDO_VDD_LVL_0, CORELDO_VDD_LVL_val_OD);
    SYSTEM.PUT(MCU.SPC_ACTIVE_CFG, val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SPC_SC, SPC_SC_BUSY);

    (* SRAM *)
    SYSTEM.GET(MCU.SPC_SRAM_CTRL, val);
    BFI(val, SPC_SRAM_CTRL_VSM_1, SPC_SRAM_CTRL_VSM_0, SPC_SRAM_CTRL_VSM_11V);
    SYSTEM.PUT(MCU.SPC_SRAM_CTRL, val);
    SYSTEM.GET(MCU.SPC_SRAM_CTRL, val);
    BFI(val, SPC_SRAM_CTRL_REQ, 1);
    SYSTEM.PUT(MCU.SPC_SRAM_CTRL, val);
    REPEAT
      SYSTEM.GET(MCU.SPC_SRAM_CTRL, val)
    UNTIL SPC_SRAM_CTRL_ACK IN BITS(val);
    BFI(val, SPC_SRAM_CTRL_REQ, 0);
    SYSTEM.PUT(MCU.SPC_SRAM_CTRL, val)
  END setODvoltage;


  PROCEDURE* isFircFreq(freq: INTEGER): BOOLEAN;
    RETURN  (freq = FIRC_48) OR
            (freq = FIRC_144)
  END isFircFreq;


  PROCEDURE InitFIRC*(freq: INTEGER);
    VAR set, val: INTEGER;
  BEGIN
    ASSERT(isFircFreq(freq), Errors.PreCond);

    (* overdrive voltage (OD) to core and SRAM *)
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
    SYSTEM.PUT(MCU.SCG_FIRC_CFG, freq);

    (* config FIRC *)
    SYSTEM.GET(MCU.SCG_FIRC_CSR, val);
    BFI(val, FIRC_SCLK_PERIPH_EN, 1);
    BFI(val, FIRC_FCLK_PERIPH_EN, 1);
    BFI(val, FIRC_EN, 1);
    SYSTEM.PUT(MCU.SCG_FIRC_CSR, val);
    REPEAT UNTIL SYSTEM.BIT(MCU.SCG_FIRC_CSR, FIRC_VLD);

    (* set flash memory wait cycles *)
    SYSTEM.GET(MCU.FMU_FCTRL, val);
    CASE freq OF
      RANGE_val_48: set := RWSC_val_OD_64
    | RANGE_val_144: set := RWSC_val_OD_150
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
    setDivider(MCU.SYSCON_FROHF_DIV, SYSCON_FROHF_DIV_val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_SLOWCLK_DIV, UNSTABLE);

    enableClk1M;

    CASE freq OF
      RANGE_val_48: setClockValues(48000000)
    | RANGE_val_144: setClockValues(144000000)
    END

  END InitFIRC;


(* TODO
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
  (* source: use 24 MHz SOSC *)
  (* set to 120 MHz *)
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
    setDivider(MCU.SYSCON_PLL1_CLK0_DIV, SYSCON_PLL1CLK_DIV_val);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_BUSCLK_DIV, UNSTABLE);
    REPEAT UNTIL ~SYSTEM.BIT(MCU.SYSCON_SLOWCLK_DIV, UNSTABLE);

    (*setSysTickClock;*)
    setClockValues(160000000)
  END InitSPLL;
*)

END Clocks.

