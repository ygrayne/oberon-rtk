MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Program-specific clocks configuration and initialisation at start-up.
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT CLK, PWR, FLASH;

  CONST
    SYSCLK_FRQ* = 240 * 1000000;  (* PLL1P *)
    HCLK_FRQ*   = 240 * 1000000;  (* AHB prescaler *)
    PCLK1_FRQ*  = 240 * 1000000;  (* APB1 prescaler *)
    PCLK2_FRQ*  = 240 * 1000000;  (* APB2 prescaler *)
    PCLK3_FRQ*  = 120 * 1000000;  (* APB3 prescaler *)
    PLL1P_FREQ* = 240 * 1000000;
    PLL1Q_FREQ* = 160 * 1000000;
    PLL2Q_FREQ* =  48 * 1000000;
    LSI_FREQ*   = 32000;


  PROCEDURE Configure*;
    CONST Enabled = 1; Disabled = 0;
    VAR pllCfg: CLK.PLLcfg; prescCfg: CLK.BusPrescCfg; oscCfg: CLK.OscCfg; lsOscCfg: CLK.LsOscCfg;
  BEGIN
    (* base oscillators *)
    (* enable as needed, and implemented on the board. eg. crystals *)
    oscCfg.hsiEn := Enabled;
    oscCfg.csiEn := Enabled;
    oscCfg.hsi48En := Enabled;
    oscCfg.hseEn := Disabled;
    CLK.ConfigOsc(oscCfg);

    lsOscCfg.lsiEn := Enabled;
    lsOscCfg.lseEn := Disabled;
    CLK.ConfigLsOsc(lsOscCfg);


    (* PLL for SYSCLK *)
    (* 240 MHz from 32 MHz HSI clock *)
    pllCfg.src := CLK.PLLsrc_HSI;
    pllCfg.range := CLK.PLLsrc_Frq_8_16;
    pllCfg.pen := 1;
    pllCfg.qen := 1;
    pllCfg.ren := 0;
    pllCfg.mdiv := 2; (* 32 => 16 MHz *)
    pllCfg.pdiv := 1; (* 480 => 240 MHz *)
    pllCfg.qdiv := 39; (* MCO1 clk out *)
    pllCfg.rdiv := 0;
    pllCfg.ndiv := 29; (* 16 => 480 MHz *)
    CLK.ConfigPLL(CLK.PLL1, pllCfg);

    (* PLL for peripheral devices *)
    (* 48 MHz from 32 MHz HSI clock *)
    pllCfg.src := CLK.PLLsrc_HSI;
    pllCfg.range := CLK.PLLsrc_Frq_8_16;
    pllCfg.pen := 0;
    pllCfg.qen := 1;
    pllCfg.ren := 0;
    pllCfg.mdiv := 4; (* 32 => 8 MHz *)
    pllCfg.pdiv := 0;
    pllCfg.qdiv := 0;
    pllCfg.rdiv := 0;
    pllCfg.ndiv := 5; (* 8 => 48 MHz *)
    CLK.ConfigPLL(CLK.PLL2, pllCfg);

    (* adjust voltage and wait states *)
    PWR.SetVoltageRange(PWR.Range0);
    FLASH.SetWaitStates(5);

    (* bus prescalers *)
    prescCfg.ahbPresc := CLK.AHBpresc_1;
    prescCfg.apb1Presc := CLK.ABPpresc_1;
    prescCfg.apb2Presc := CLK.ABPpresc_1;
    prescCfg.apb3Presc := CLK.ABPpresc_2;
    CLK.SetBusPresc(prescCfg);

    CLK.StartPLL(CLK.PLL1);
    CLK.StartPLL(CLK.PLL2);
    CLK.SetSysClk(CLK.SysClk_PLL);

  END Configure;

END Clocks.

