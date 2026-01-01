MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Program-specific clocks configuration and initialisation at start-up.
  --
  MCU: MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT CLK, PWR, FLASH;

  CONST
    MAINCLK_FRQ*      = 180 * 1000000;    (* CLK.FIRC_Frq_180 used *)
    SYSCLK_FRQ*       = MAINCLK_FRQ;      (* divCfg.sysClkDiv *)
    BUSCLK_FRQ*       = SYSCLK_FRQ DIV 2; (* fixed divider *)
    SLOWCLK_FRQ*      = SYSCLK_FRQ DIV 6; (* fixed divider *)
    CLK12M_FRQ*       =  12 * 1000000;    (* SIRC FRO_12M *)
    CLK1M_FRQ*        =   1 * 1000000;    (* always on *)
    CLK16K_FRQ*       =         16384;    (* ROSC *)
    CLKIN_FRQ*        =   8 * 1000000;    (* SOSC *)
    CLK45M_FRQ*       =  45 * 1000000;    (* fircCfg.periSlowEn *)
    CLKHF_FRQ*        = MAINCLK_FRQ;      (* FIRC FRO_HF *)
    CLKHF_GATED_FRQ*  = CLKHF_FRQ;        (* FIRC FRO_HF fircCfg.periFastEn *)
    CLKHF_DIV_FRQ*    = CLKHF_FRQ;        (* FIRC FRO_HF divCfg.froHFdiv *)
    CLKLF_FRQ*        = CLK12M_FRQ;       (* SIRC FRO_LF gate: SIRC_CLK_PERIPH_EN = 1 (reset) *)
    CLKLF_DIV_FRQ*    = CLKLF_FRQ;        (* SIRC FRO_LF divCfg.froLFdiv *)



  PROCEDURE Configure*;
  (* use FIRC *)
    CONST Enabled = 1; Disabled = 0;
    VAR fircCfg: CLK.FIRCcfg; divCfg: CLK.DivCfg;
  BEGIN
    PWR.SetActiveLDOvoltage(PWR.Volt_OD);
    PWR.SetSRAMvoltage(PWR.Volt_ND);
    FLASH.SetWaitStates(FLASH.WS_200);
    CLK.SetSysClk(CLK.SysClk_SIRC);
    fircCfg.freq := CLK.FIRC_frq_180;
    fircCfg.periFastEn := Enabled;
    fircCfg.periSlowEn := Enabled;
    CLK.ConfigFIRC(fircCfg);
    CLK.EnableFIRC;
    CLK.SetSysClk(CLK.SysClk_FIRC);
    divCfg.sysClkDiv := 0;
    divCfg.froHFhalt := Disabled;
    divCfg.froHFdiv := 0;
    divCfg.froLFhalt := Disabled;
    divCfg.froLFdiv := 0;
    divCfg.spllHalt := Enabled;
    divCfg.spllDiv := 0;
    CLK.ConfigDividers(divCfg)
  END Configure;

END Clocks.

