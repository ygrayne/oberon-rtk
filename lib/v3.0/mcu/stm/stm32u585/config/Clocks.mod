MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Program-specific clocks configuration and initialisation at start-up.
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT CLK, PWR, FLASH, RAM;

  CONST
    SYSCLK_FRQ* = 160 * 1000000;  (* PLL1R *)
    HCLK_FRQ*   = 160 * 1000000;  (* AHB prescaler *)
    PCLK1_FRQ*  = 160 * 1000000;  (* APB1 prescaler *)
    PCLK2_FRQ*  =  80 * 1000000;  (* APB2 prescaler *)
    PCLK3_FRQ*  =  80 * 1000000;  (* APB3 prescaler *)
    PLL1R_FREQ* = 160 * 1000000;
    PLL2Q_FREQ* =  48 * 1000000;
    LSI_FREQ*   = 32000;


  PROCEDURE Configure*;
    CONST Enabled = 1; Disabled = 0;
    VAR pllCfg: CLK.PLLcfg; prescCfg: CLK.BusPrescCfg; oscCfg: CLK.OscCfg; lsOscCfg: CLK.LsOscCfg;
  BEGIN
    (* base oscillators *)
    (* enable as needed, and implemented on the board. eg. crystals *)
    oscCfg.msisEn := Enabled;
    oscCfg.msikEn := Enabled;
    oscCfg.hsiEn := Enabled;
    oscCfg.hsi48En := Enabled;
    oscCfg.hseEn := Disabled;
    CLK.ConfigOsc(oscCfg);
    lsOscCfg.lsiEn := Enabled;
    lsOscCfg.lseEn := Disabled;
    CLK.ConfigLsOsc(lsOscCfg);

    (* PLL for SYSCLK *)
    pllCfg.src := CLK.PLLsrc_HSI16;
    pllCfg.range := CLK.PLLsrc_Frq_8_16;
    pllCfg.pen := 0;
    pllCfg.qen := 0;
    pllCfg.ren := 1;
    pllCfg.mdiv := 0;
    pllCfg.pdiv := 0;
    pllCfg.qdiv := 0;
    pllCfg.rdiv := 0;
    pllCfg.ndiv := 9; (* multiply by 10 *)
    CLK.ConfigPLL(CLK.PLL1, pllCfg);

    (* adjust voltage and wait states *)
    CLK.SetEPODboost(0); (* div by 1 *)
    PWR.SetVoltageRange(PWR.Range1);
    FLASH.SetWaitStates(4);
    RAM.SetWaitStates(RAM.SRAM3, 0);

    (* bus prescalers *)
    prescCfg.ahbPresc := CLK.AHBpresc_1;
    prescCfg.apb1Presc := CLK.ABPpresc_1;
    prescCfg.apb2Presc := CLK.ABPpresc_2;
    prescCfg.apb3Presc := CLK.ABPpresc_2;
    CLK.SetBusPresc(prescCfg);

    CLK.StartPLL(CLK.PLL1);
    CLK.SetSysClk(CLK.SysClk_PLL)
  END Configure;

END Clocks.

