MODULE GTZC_SYS;
(**
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RCC_SYS;

  CONST
    GTZC_SRAM1* = 0; (* 256k, 512 blocks, 16 super-blocks *)
    GTZC_SRAM2* = 1; (*  64k, 128 blocks,  4 super-blocks *)
    GTZC_SRAM3* = 2; (* 320k, 640 blocks, 20 super-blocks *)

    GTZC_SRAM_all* = {0 .. 2};


    GTZC1_BASE*   = BASE.GTZC1_BASE;
    GTZC1_TZSC*   = GTZC1_BASE;
    GTZC1_TZIC*   = GTZC1_BASE + 00400H;
    GTZC1_MPCBB1* = GTZC1_BASE + 00800H; (* SRAM1 *)
    GTZC1_MPCBB2* = GTZC1_BASE + 00C00H; (* SRAM2 *)
    GTZC1_MPCBB3* = GTZC1_BASE + 01000H; (* SRAM3 *)

    (* TZSC *)
    TZSC_CR_Offset*         = 000H;
    TZSC_SECCFGR1_Offset*   = 010H;
    TZSC_SECCFGR2_Offset*   = 014H;
    TZSC_SECCFGR3_Offset*   = 018H;
    TZSC_PRIVCFGR1_Offset*  = 020H;
    TZSC_PRIVCFGR2_Offset*  = 024H;
    TZSC_PRIVCFGR3_Offset*  = 028H;

    (* TZIC *)
    TZIC_IER1_Offset*       = 000H;
    TZIC_IER2_Offset*       = 004H;
    TZIC_IER3_Offset*       = 008H;
    TZIC_IER4_Offset*       = 00CH;
    TZIC_SR1_Offset*        = 010H;
    TZIC_SR2_Offset*        = 014H;
    TZIC_SR3_Offset*        = 018H;
    TZIC_SR4_Offset*        = 01CH;
    TZIC_FCR1_Offset*       = 020H;
    TZIC_FCR2_Offset*       = 024H;
    TZIC_FCR3_Offset*       = 028H;
    TZIC_FCR4_Offset*       = 02CH;

    (* MPCBB *)
    MPCBB_CR_Offset*        = 0000H;
    MPCBB_CFGLOCKR1_Offset* = 0010H;
    MPCBB_SECCFGR0_Offset*  = 0100H;
      MPCBB_SECCFGR_Offset* = 04H;
    MPCBB_PRIVCFGR0_Offset* = 0200H;
      MPCBB_PRIVCFGR_Offset* = 04H;

    (* RCC: bus clock *)
    GTZC1_BC_reg* = RCC_SYS.RCC_AHB1ENR;
    GTZC1_BC_pos* = 24;

    (* RCC: functional clock FC *)
    (* no functional clock *)

    (* SECCFGR1 ALL mask *)
    GTZC1_TZSC_SECCFGR1_ALL* = {0 .. 31};
    GTZC1_TZSC_SECCFGR2_ALL* = {0 .. 2, 8 .. 19, 24 .. 31};
    GTZC1_TZSC_SECCFGR3_ALL* = {0 .. 2, 8 .. 24, 26};

END GTZC_SYS.
