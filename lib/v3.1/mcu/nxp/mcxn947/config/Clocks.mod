MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Program-specific clocks configuration and initialisation at start-up.
  --
  MCU: MCXN947
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT CLK, PWR, FLASH;

  CONST
    MAINCLK_FRQ*      = 144 * 1000000;    (* CLK.FIRC_frq_144 used *)
    SYSCLK_FRQ*       = MAINCLK_FRQ;      (* divCfg.sysClkDiv *)
    BUSCLK_FRQ*       = SYSCLK_FRQ;
    SLOWCLK_FRQ*      = SYSCLK_FRQ DIV 4; (* fixed divider *)
    CLK12M_FRQ*       =  12 * 1000000;    (* SIRC FRO_12M *)
    CLK1M_FRQ*        =   1 * 1000000;    (* needs to be enabled *)
    CLK16K_FRQ*       =         16384;    (* ROSC *)
    CLKIN_FRQ*        =  24 * 1000000;    (* SOSC *)
    CLK48M_FRQ*       =  48 * 1000000;    (* fircCfg.periSlowEn *)
    CLKHF_FRQ*        = MAINCLK_FRQ;
    CLKHF_GATED_FRQ*  = CLKHF_FRQ;        (* FIRC fro_hf fircCfg.periFastEn *)
    CLKHF_DIV_FRQ*    = CLKHF_FRQ;        (* FIRC fro_hf_div divCfg.froHFdiv *)
    CLKLF_FRQ*        = CLK12M_FRQ;       (* SIRC FRO_LF gate: SIRC_CLK_PERIPH_EN = 1 (reset) *)


  PROCEDURE Configure*;
    CONST Enabled = 1; Disabled = 0;
    VAR fircCfg: CLK.FIRCcfg; divCfg: CLK.DivCfg;
  BEGIN
    PWR.SetActiveLDOvoltage(PWR.Volt_OD);
    PWR.SetSRAMvoltage(PWR.Volt_SD);
    FLASH.SetWaitStates(FLASH.WS_OD_150);
    fircCfg.freq := CLK.FIRC_frq_144;
    fircCfg.periFastEn := Enabled;
    fircCfg.periSlowEn := Enabled;
    CLK.ConfigFIRC(fircCfg);
    CLK.EnableFIRC;
    CLK.SetSysClk(CLK.SysClk_FIRC);
    divCfg.sysClkDiv := 0;
    divCfg.froHFhalt := Disabled;
    divCfg.froHFdiv := 0;
    divCfg.spllHalt0 := Enabled;
    divCfg.spllHalt1 := Enabled;
    divCfg.pllHalt := Enabled;
    divCfg.pllSel := CLK.PLLdiv_NONE;
    CLK.ConfigDividers(divCfg);
    CLK.EnableCLK1M
  END Configure;

END Clocks.

