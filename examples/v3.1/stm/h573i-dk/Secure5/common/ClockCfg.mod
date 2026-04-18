MODULE ClockCfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program Secure5
  Program-specific clocks configuration values for S and NS.
  --
  MCU: STM32H573II
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

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

END ClockCfg.
