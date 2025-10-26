MODULE ClockCtrl;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Clock control
  --
  MCU: MCX-A346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    ClkRegOffset = 4;

    (* bits in CLKDIV *)
    CLKDIV_UNSTABLE = 31;

    (* clocks for 'clk' parameter (functional clock) *)
    CLK_FRO_LF_DIV*   = 0;  (* CTIMER, I2C, SPI, UART, LPTMR *)
    CLK_FRO_HF_GATED* = 1;  (* CTIMER *)
    CLK_FRO_HF_DIV*   = 2;  (* I2C, SPI, UART, LPTMR *)
    CLK_CLK_IN*       = 3;  (* CTIMER, I2C, SPI, UART, LPTMR *)
    CLK_CLK_16K*      = 4;  (* CTIMER, UART *)
    CLK_CLK_1M*       = 5;  (* CTIMER, I2C, SPI, UART, LPTMR *)
    CLK_PLL_CLK_DIV*  = 6;  (* CTIMER, I2C, SPI, UART, LPTMR *)

    CLK_ST_CPU_CLK*      = 0;  (* SYSTICK *)
    CLK_ST_CLK_1M*       = 1;
    CLK_ST_OUT_CLK_16K*  = 2;

    CLK_OUT_FRO_12M*    = 0; (* CLK_CLKOUT *)
    CLK_OUT_FRO_HF_DIV* = 1;
    CLK_OUT_CLK_IN*     = 2;
    CLK_OUT_CLK_16K*    = 3;
    CLK_OUT_PLL_CLK*    = 5;
    CLK_OUT_CLK_SLOW*   = 6;


  PROCEDURE* ConfigDevClock*(device: INTEGER; clk, div: INTEGER);
  (* set functional clock *)
  (* use with clock disabled *)
  (* MCU.CLK_* devices *)
    VAR selReg, divReg: INTEGER;
  BEGIN
    selReg := MCU.MRCC_CLKSEL + (device * MCU.MRCC_CLK_Offset);
    divReg := selReg + ClkRegOffset;
    clk := clk MOD 8H;
    div := div MOD 10H;
    SYSTEM.PUT(selReg, clk);
    SYSTEM.PUT(divReg, div);
    REPEAT UNTIL ~SYSTEM.BIT(divReg, CLKDIV_UNSTABLE)
  END ConfigDevClock;

END ClockCtrl.
