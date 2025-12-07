MODULE Clocks;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Program-specific clock configuration.
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT CLK, PWR, FLASH, RAM;

  VAR
    SYSCLK_FRQ*: INTEGER;
    HCLK_FRQ*: INTEGER;     (* AHB bus, CPU core, memory, DMA *)
    PCLK1_FRQ*, PCLK2_FRQ*, PCLK3_FRQ*: INTEGER; (* APB1, APB2, APB3 bus, peripherals *)
    AHBpresc: ARRAY 9 OF INTEGER;
    APBpresc: ARRAY 5 OF INTEGER;


  PROCEDURE updateFreq(pllSrcFreq: INTEGER);
    VAR
      pllCfg: CLK.PLLcfg; prescCfg: CLK.BusPrescCfg;
      ahbDiv, apb1Div, apb2Div, apb3Div: INTEGER;
  BEGIN
    CLK.GetPLLcfg(CLK.PLL1, pllCfg);
    CLK.GetBusPresc(prescCfg);
    SYSCLK_FRQ := pllSrcFreq DIV (pllCfg.mdiv + 1) * (pllCfg.ndiv + 1) DIV (pllCfg.rdiv + 1);
    ahbDiv := AHBpresc[prescCfg.ahbPresc - 7];
    apb1Div := APBpresc[prescCfg.apb1Presc - 3];
    apb2Div := APBpresc[prescCfg.apb2Presc - 3];
    apb3Div := APBpresc[prescCfg.apb3Presc - 3];
    HCLK_FRQ := SYSCLK_FRQ DIV ahbDiv;
    PCLK1_FRQ := HCLK_FRQ DIV apb1Div;
    PCLK2_FRQ := HCLK_FRQ DIV apb2Div;
    PCLK3_FRQ := HCLK_FRQ DIV apb3Div
  END updateFreq;


  PROCEDURE Configure*;
  (* SYSCLK/HCLK: 160 MHz, PCLK1: 160 MHz, PCLK2/PCLK3: 80 MHz *)
    VAR pllCfg: CLK.PLLcfg; prescCfg: CLK.BusPrescCfg; clkEn: SET;
  BEGIN
    (* base oscillators *)
    clkEn := {CLK.MSISen, CLK.MSIKen, CLK.HSI48en, CLK.HSIen};
    CLK.EnableOsc(clkEn);

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
    CLK.SetSysClk(CLK.SysClk_PLL);

    updateFreq(CLK.HSI16_FREQ)
  END Configure;

  PROCEDURE* init;
  BEGIN
    APBpresc[0] := 1;
    APBpresc[1] := 2;
    APBpresc[2] := 4;
    APBpresc[3] := 8;
    APBpresc[4] := 16;

    AHBpresc[0] := 1;
    AHBpresc[1] := 2;
    AHBpresc[2] := 4;
    AHBpresc[3] := 8;
    AHBpresc[4] := 16;
    AHBpresc[5] := 64;
    AHBpresc[6] := 128;
    AHBpresc[7] := 256;
    AHBpresc[8] := 512
  END init;

BEGIN
  init
END Clocks.

