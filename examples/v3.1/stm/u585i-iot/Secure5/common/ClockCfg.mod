MODULE ClockCfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program Secure5
  Program-specific clocks configuration values for S and NS.
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    SYSCLK_FRQ* = 160 * 1000000;  (* PLL1R *)
    HCLK_FRQ*   = 160 * 1000000;  (* AHB prescaler *)
    PCLK1_FRQ*  = 160 * 1000000;  (* APB1 prescaler *)
    PCLK2_FRQ*  =  80 * 1000000;  (* APB2 prescaler *)
    PCLK3_FRQ*  =  80 * 1000000;  (* APB3 prescaler *)
    PLL1R_FREQ* = 160 * 1000000;
    PLL2Q_FREQ* =  48 * 1000000;
    LSI_FREQ*   = 32000;

END ClockCfg.
