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

  IMPORT SYSTEM;

  CONST
    (* bits in CLKDIV *)
    CLKDIV_UNSTABLE = 31;

    (* device functional clock selectors *)
    CTIMER_SIRC_DIV*    = 0;
    CTIMER_FIRC_GATED*  = 1;
    CTIMER_FIRC_DIV*    = 2;
    CTIMER_SOSC*        = 3;
    CTIMER_ROSC*        = 4;
    CTIMER_CLK_1M*      = 5;
    CTIMER_SPLL_DIV*    = 6;
    CTIMER_NONE*        = 7; (* reset *)

    I2C_SIRC_DIV*       = 0;
    I2C_FIRC_DIV*       = 2;
    I2C_SOSC*           = 3;
    I2C_CLK_1M*         = 5;
    I2C_SPLL_DIV*       = 6;
    I2C_NONE*           = 7; (* reset *)

    SPI_SIRC_DIV*       = 0;
    SPI_FIRC_DIV*       = 2;
    SPI_SOSC*           = 3;
    SPI_CLK_1M*         = 5;
    SPI_SPLL_DIV*       = 6;
    SPI_NONE*           = 7; (* reset *)

    UART_SIRC_DIV*      = 0;
    UART_FIRC_DIV*      = 2;
    UART_SOSC*          = 3;
    UART_ROSC*          = 4;
    UART_CLK_1M*        = 5;
    UART_SPLL_DIV*      = 6;
    UART_NONE*          = 7; (* reset *)


    CLKOUT_SIRC*        = 0;
    CLKOUT_FIRC_DIV*    = 1;
    CLKOUT_SOSC*        = 2;
    CLKOUT_ROSC*        = 3;
    CLKOUT_SPLL*        = 5;
    CLKOUT_SLOW_CLK*    = 6;
    CLKOUT_NONE*        = 7; (* reset *)

    SYSTICK_SYS_CLK*    = 0;
    SYSTICK_CLK_1M*     = 1;
    SYSTICK_ROSC*       = 2;
    SYSTICK_NONE*       = 3; (* reset *)


  PROCEDURE* ConfigDevClock*(clkSel, clkDiv: INTEGER; clk, div: INTEGER);
  (* set functional clock *)
  (* use with clock disabled *)
  BEGIN
    clk := clk MOD 8H;
    div := div MOD 10H;
    SYSTEM.PUT(clkSel, clk);
    SYSTEM.PUT(clkDiv, div);
    REPEAT UNTIL ~SYSTEM.BIT(clkDiv, CLKDIV_UNSTABLE)
  END ConfigDevClock;

END ClockCtrl.
