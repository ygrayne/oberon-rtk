MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Program-specific clocks configuration and initialisation at start-up.
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT MCU := MCU2, CLK, RST;

  CONST
    XOSC_FREQ*      =  12 * 1000000;
    SYSCLK_FREQ*    = 125 * 1000000;
    REFCLK_FREQ*    =  48 * 1000000;
    PERICLK_FREQ*   =  48 * 1000000;
    SYSTICK_FREQ*   =   1 * 1000000;
    WATCHDOG_FREQ*  =   1 * 1000000;
    TIMER0_FREQ*    =   1 * 1000000;


  PROCEDURE Configure*;
    VAR pllCfg: CLK.PLLcfg; clkCfg: CLK.ClocksCfg; ticksCfg: CLK.TicksCfg;
  BEGIN
    (* crystal oscillator *)
    (* 12 MHz *)
    CLK.StartXOSC;

    (* Sys PLL *)
    (* 125 MHz *)
    pllCfg.refDiv := 1;
    pllCfg.fbDiv := 125;
    pllCfg.postDiv1 := 6;
    pllCfg.postDiv2 := 2;
    RST.ReleaseReset(MCU.RESETS_PLL_SYS);
    CLK.ConfigPLL(CLK.PLLsys, pllCfg);

    (* USB PLL *)
    (* 48 MHz, base for ref clk and tickers *)
    pllCfg.refDiv := 1;
    pllCfg.fbDiv := 64;
    pllCfg.postDiv1 := 4;
    pllCfg.postDiv2 := 4;
    RST.ReleaseReset(MCU.RESETS_PLL_USB);
    CLK.ConfigPLL(CLK.PLLusb, pllCfg);

    (* clocks *)
    clkCfg.sysAuxSrc := CLK.SysAuxSrc_PLLsys;
    clkCfg.sysSrc := CLK.SysSrc_AUX;
    clkCfg.sysDivInt := 1;
    clkCfg.refAuxSrc := CLK.RefAuxSrc_PLLusb;
    clkCfg.refSrc := CLK.SysSrc_AUX;
    clkCfg.refDivInt := 1;
    clkCfg.periAuxSrc := CLK.PeriAuxSrc_PLLusb;
    CLK.ConfigClocks(clkCfg);

    (* ticks *)
    (* derived from ref clock *)
    ticksCfg.watchdogDiv := 48;
    CLK.ConfigTicks(ticksCfg)
  END Configure;

END Clocks.
