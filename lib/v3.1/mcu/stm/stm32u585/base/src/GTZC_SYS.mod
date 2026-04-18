MODULE GTZC_SYS;
(**
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RCC_SYS;

  CONST
    GTZC_SRAM1* = 1; (* 192k,  384 blocks, 12 super-blocks *)
    GTZC_SRAM2* = 2; (*  64k,  128 blocks,  4 super-blocks *)
    GTZC_SRAM3* = 3; (* 512k, 1024 blocks, 32 super-blocks *)
    GTZC_SRAM4* = 4; (*  16k,   32 blocks,  1 super-block  *)

    GTZC_SRAM_all* = {1 .. 4};

    GTZC1_BASE* = BASE.GTZC1_BASE;
    GTZC2_BASE* = BASE.GTZC2_BASE;
    GTZC1_TZSC*   = GTZC1_BASE;
    GTZC1_TZIC*   = GTZC1_BASE + 00400H;
    GTZC1_MPCBB1* = GTZC1_BASE + 00800H; (* SRAM1 *)
    GTZC1_MPCBB2* = GTZC1_BASE + 00C00H; (* SRAM2 *)
    GTZC1_MPCBB3* = GTZC1_BASE + 01000H; (* SRAM3 *)

    GTZC2_TZSC*   = GTZC2_BASE;
    GTZC2_TZIC*   = GTZC2_BASE + 00400H;
    GTZC2_MPCBB4* = GTZC2_BASE + 00800H; (* SRAM4 *)

    (* TZSC *)
    TZSC_CR_Offset*         = 000H;
    TZSC_SECCFGR1_Offset*   = 010H;
    TZSC_SECCFGR2_Offset*   = 014H; (* GTZC1 only *)
    TZSC_SECCFGR3_Offset*   = 018H; (* GTZC1 only *)
    TZSC_PRIVCFGR1_Offset*  = 020H;
    TZSC_PRIVCFGR2_Offset*  = 024H; (* GTZC1 only *)
    TZSC_PRIVCFGR3_Offset*  = 028H; (* GTZC1 only *)

    (* TZIC *)
    TZIC_IER1_Offset*       = 000H;
    TZIC_IER2_Offset*       = 004H;
    TZIC_IER3_Offset*       = 008H; (* GTZC1 only *)
    TZIC_IER4_Offset*       = 00CH; (* GTZC1 only *)
    TZIC_SR1_Offset*        = 010H;
    TZIC_SR2_Offset*        = 014H;
    TZIC_SR3_Offset*        = 018H; (* GTZC1 only *)
    TZIC_SR4_Offset*        = 01CH; (* GTZC1 only *)
    TZIC_FCR1_Offset*       = 020H;
    TZIC_FCR2_Offset*       = 024H;
    TZIC_FCR3_Offset*       = 028H; (* GTZC1 only *)
    TZIC_FCR4_Offset*       = 02CH; (* GTZC1 only *)

    (* MPCBB *)
    MPCBB_CR_Offset*        = 0000H;
    MPCBB_CFGLOCKR1_Offset* = 0010H;
    MPCBB_CFGLOCKR2_Offset* = 0014H; (* GTZC1 only *)
    MPCBB_SECCFGR0_Offset*  = 0100H;
      MPCBB_SECCFGR_Offset* = 04H;
    MPCBB_PRIVCFGR0_Offset* = 0200H;
      MPCBB_PRIVCFGR_Offset* = 04H;

    (* RCC: bus clock BC *)
    GTZC1_BC_reg* = RCC_SYS.RCC_AHB1ENR;
    GTZC2_BC_reg* = RCC_SYS.RCC_AHB3ENR;
    GTZC1_BC_pos* = 24;
    GTZC2_BC_pos* = 12;

    (* RCC: functional clock FC *)
    (* no functional clock *)

    (* Secure *)
    GTZC1_TZSC_SECCFGR1_ALL* = {0.. 19, 21 .. 23};
    GTZC1_TZSC_SECCFGR2_ALL* = {0 .. 11};
    GTZC1_TZSC_SECCFGR3_ALL* = {0 .. 28};
    GTZC2_TZSC_SECCFGR1_ALL* = {0 .. 9, 11 .. 12};

END GTZC_SYS.
