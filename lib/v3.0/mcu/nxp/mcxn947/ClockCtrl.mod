MODULE ClockCtrl;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Clock control
  --
  MCU: MCXN947
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM;

  CONST
    (* bits in CLK_DIV *)
    CLKDIV_UNSTABLE = 31;

    (* device functional clock selectors *)
    SYSTICK_DIV*    = 0; (* note: divider in front of systick clksel mux *)
    SYSTICK_CLK_1M* = 1;
    SYSTICK_CLK_LP* = 2;
    SYSTICK_NONE*   = 7; (* reset *)

    TRACE_DIV*       = 0;
    TRACE_CLK_1M*    = 1;
    TRACE_CLK_LP*    = 2;
    TRACE_NONE*      = 7; (* reset *)

    CTIMER_CLK_1M*     = 0;
    CTIMER_APLL*       = 1;
    CTIMER_SPLL*       = 2;
    CTIMER_FIRC*       = 3;
    CTIMER_SIRC*       = 4;
    CTIMER_SAI0_MCLK*  = 5;
    CTIMER_CLK_LP*     = 6;
    CTIMER_SAI1_MCLK*  = 8;
    CTIMER_SAI0_TX*    = 9;
    CTIMER_SAI0_RX*    = 10;
    CTIMER_SAI1_TX*    = 11;
    CTIMER_SAI1_RX*    = 12;
    CTIMER_NONE*       = 15; (* reset *)

    CLKOUT_MAIN*       = 0;
    CLKOUT_APLL*       = 1;
    CLKOUT_SOSC*       = 2;
    CLKOUT_FIRC*       = 3;
    CLKOUT_SIRC*       = 4;
    CLKOUT_SPLL*       = 5;
    CLKOUT_CLK_LP*     = 6;
    CLKOUT_PLL_USB*    = 7;
    CLKOUT_NONE*       = 15; (* reset *)

    FLEXCOM_PLL_DIV*   = 1;
    FLEXCOM_SIRC*      = 2;
    FLEXCOM_FIRC_DIV*  = 3;
    FLEXCOM_CLK_1M*    = 4;
    FLEXCOM_PLL_USB*   = 5;
    FLEXCOM_CLK_LP*    = 6;
    FLEXCOM_NONE*      = 7; (* reset *)


  PROCEDURE* ConfigDevClock*(clkSel, clkDiv: INTEGER; clk, div: INTEGER);
  (* set functional clock *)
  (* use with clock disabled *)
  BEGIN
    clk := clk MOD 10H;
    div := div MOD 100H;
    SYSTEM.PUT(clkSel, clk);
    SYSTEM.PUT(clkDiv, div);
    REPEAT UNTIL ~SYSTEM.BIT(clkDiv, CLKDIV_UNSTABLE)
  END ConfigDevClock;

END ClockCtrl.
