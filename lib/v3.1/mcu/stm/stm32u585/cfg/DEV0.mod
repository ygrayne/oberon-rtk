MODULE DEV0;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Definitions MCU managing devices
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT MCU;

  CONST

  (* == RCC == *)
    RCC_BASE* = MCU.RCC_BASE;

    (* ref manual ch11, p604 *)
    RCC_CR*             = RCC_BASE + 0000H;
    RCC_ICSCR1*         = RCC_BASE + 0008H;
    RCC_ICSCR2*         = RCC_BASE + 000CH;
    RCC_ICSCR3*         = RCC_BASE + 0010H;
    RCC_CRRCR*          = RCC_BASE + 0014H;
    RCC_CFGR1*          = RCC_BASE + 001CH;
    RCC_CFGR2*          = RCC_BASE + 0020H;
    RCC_CFGR3*          = RCC_BASE + 0024H;

    RCC_PLL1CFGR*       = RCC_BASE + 0028H;
    RCC_PLL2CFGR*       = RCC_BASE + 002CH;
    RCC_PLL3CFGR*       = RCC_BASE + 0030H;
    RCC_PLL1DIVR*       = RCC_BASE + 0034H;
    RCC_PLL1FRACR*      = RCC_BASE + 0038H;
    RCC_PLL2DIVR*       = RCC_BASE + 003CH;
    RCC_PLL2FRACR*      = RCC_BASE + 0040H;
    RCC_PLL3DIVR*       = RCC_BASE + 0044H;
    RCC_PLL3FRACR*      = RCC_BASE + 0048H;

    RCC_CIER*           = RCC_BASE + 0050H;
    RCC_CIFR*           = RCC_BASE + 0054H;
    RCC_CICR*           = RCC_BASE + 0058H;

    RCC_AHB1RSTR*       = RCC_BASE + 0060H;
    RCC_AHB2RSTR1*      = RCC_BASE + 0064H;
    RCC_AHB2RSTR2*      = RCC_BASE + 0068H;
    RCC_AHB3RSTR*       = RCC_BASE + 006CH;
    RCC_APB1RSTR1*      = RCC_BASE + 0074H;
    RCC_APB1RSTR2*      = RCC_BASE + 0078H;
    RCC_APB2RSTR*       = RCC_BASE + 007CH;
    RCC_APB3RSTR*       = RCC_BASE + 0080H;

    RCC_AHB1ENR*        = RCC_BASE + 0088H;
    RCC_AHB2ENR1*       = RCC_BASE + 008CH;
    RCC_AHB2ENR2*       = RCC_BASE + 0090H;
    RCC_AHB3ENR*        = RCC_BASE + 0094H;
    RCC_APB1ENR1*       = RCC_BASE + 009CH;
    RCC_APB1ENR2*       = RCC_BASE + 00A0H;
    RCC_APB2ENR*        = RCC_BASE + 00A4H;
    RCC_APB3ENR*        = RCC_BASE + 00A8H;
    RCC_AHB1SMENR*      = RCC_BASE + 00B0H;
    RCC_AHB2SMENR1*     = RCC_BASE + 00B4H;
    RCC_AHB2SMENR2*     = RCC_BASE + 00B8H;
    RCC_AHB3SMENR*      = RCC_BASE + 00BCH;
    RCC_APB1SMENR1*     = RCC_BASE + 00C4H;
    RCC_APB1SMENR2*     = RCC_BASE + 00C8H;
    RCC_APB2SMENR*      = RCC_BASE + 00CCH;
    RCC_APB3SMENR*      = RCC_BASE + 00D0H;

    RCC_SRDAMR*         = RCC_BASE + 00D8H;
    RCC_CCIPR1*         = RCC_BASE + 00E0H;
    RCC_CCIPR2*         = RCC_BASE + 00E4H;
    RCC_CCIPR3*         = RCC_BASE + 00E8H;
    RCC_BDCR*           = RCC_BASE + 00F0H;
    RCC_CSR*            = RCC_BASE + 00F4H;

    RCC_SECCFGR*        = RCC_BASE + 0110H;
    RCC_PRIVCFGR*       = RCC_BASE + 0114H;

    (* bus clock *)
    (* enabled after reset -- duh! *)

    (* Secure *)
    (* S/NS state of devices auto-follows their GTZC Secure state (non-TZ-aware) *)
    (* or the Secure state as determined by the device's own Secure config register (TZ-aware) *)

    RCC_SEC* = RCC_SECCFGR;

    RCC_SEC_RMVF*   = 12;
    RCC_SEC_HSI48*  = 11;
    RCC_SEC_ICLK*   = 10;
    RCC_SEC_PLL3*   = 9;
    RCC_SEC_PLL2*   = 8;
    RCC_SEC_PLL1*   = 7;
    RCC_SEC_PRESC*  = 6;
    RCC_SEC_SYSCLK* = 5; (* note: controls certain sec settings in PWR *)
    RCC_SEC_LSE*    = 4;
    RCC_SEC_LSI*    = 3;
    RCC_SEC_MSI*    = 2;
    RCC_SEC_HSE*    = 1;
    RCC_SEC_HSI*    = 0;

    RCC_SEC_ALL* = {0 .. 12};


(* == GTZC == *)
    GTZC1_BASE* = MCU.GTZC1_BASE;
    GTZC2_BASE* = MCU.GTZC2_BASE;

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

    (* bus clock *)
    GTZC1_BC_reg* = RCC_AHB1ENR;
    GTZC2_BC_reg* = RCC_AHB3ENR;
    GTZC1_BC_pos* = 24;
    GTZC2_BC_pos* = 12;

    (* Secure *)
    GTZC1_TZSC_SECCFGR1_ALL* = {0.. 19, 21 .. 23};
    GTZC1_TZSC_SECCFGR2_ALL* = {0 .. 11};
    GTZC1_TZSC_SECCFGR3_ALL* = {0 .. 28};
    GTZC2_TZSC_SECCFGR1_ALL* = {0 .. 9, 11 .. 12};

(* == PWR == *)
    PWR_BASE* = MCU.PWR_BASE;

    PWR_CR1*      = PWR_BASE + 000H;
    PWR_CR2*      = PWR_BASE + 004H;
    PWR_CR3*      = PWR_BASE + 008H;
    PWR_VOSR*     = PWR_BASE + 00CH;
    PWR_SVMCR*    = PWR_BASE + 010H;
    PWR_WUCR1*    = PWR_BASE + 014H;
    PWR_WUCR2*    = PWR_BASE + 018H;
    PWR_WUCR3*    = PWR_BASE + 01CH;
    PWR_BDCR1*    = PWR_BASE + 020H;
    PWR_BDCR2*    = PWR_BASE + 024H;
    PWR_DBPR*     = PWR_BASE + 028H;
    PWR_UCPDR*    = PWR_BASE + 02CH;
    PWR_SECCFGR*  = PWR_BASE + 030H;
    PWR_PRIVCFGR* = PWR_BASE + 034H;
    PWR_SR*       = PWR_BASE + 038H;
    PWR_SVMSR*    = PWR_BASE + 03CH;
    PWR_BDSR*     = PWR_BASE + 040H;
    PWR_WUSR*     = PWR_BASE + 044H;
    PWR_WUSCR*    = PWR_BASE + 048H;
    PWR_APCR*     = PWR_BASE + 04CH;

    (* bus clock *)
    PWR_BC_reg* = RCC_AHB3ENR;
    PWR_BC_pos* = 2;

    (* Secure *)
    PWR_SEC* = PWR_SECCFGR;

    PWR_SEC_APC*  = 15;
    PWR_SEC_VB*   = 14;
    PWR_SEC_VDM*  = 13;
    PWR_SEC_LPM*  = 12;
    PWR_SEC_WUP8* = 7;
    PWR_SEC_WUP7* = 6;
    PWR_SEC_WUP6* = 5;
    PWR_SEC_WUP5* = 4;
    PWR_SEC_WUP4* = 3;
    PWR_SEC_WUP3* = 2;
    PWR_SEC_WUP2* = 1;
    PWR_SEC_WUP1* = 0;

    PWR_SEC_ALL* = {0 .. 7, 12 .. 15};

    (* own SECCFGR register *)
    (* module PWR should be equipped with more targeted procedures *)
    (* for the various control functions such as wake-up and pullup/down *)
    (* to note: the pin-oriented control registers auto-follow the GPIO_SECCFGR settings *)
    (* PWR.SetVoltageRange is S only if  RCC_SECCFGR.SYSCLKSEC = 1 *)


(* == FLASH == *)

    FLASH_BASE* = MCU.FLASH_BASE;

    FLASH_ACR*          = FLASH_BASE + 000H;
    FLASH_NSKEYR*       = FLASH_BASE + 008H;
    FLASH_SECKEYR*      = FLASH_BASE + 00CH;
    FLASH_OPTKEYR*      = FLASH_BASE + 010H;
    FLASH_PDKEY1R*      = FLASH_BASE + 018H;
    FLASH_PDKEY2R*      = FLASH_BASE + 01CH;
    FLASH_NSSR*         = FLASH_BASE + 020H;
    FLASH_SECSR*        = FLASH_BASE + 024H;
    FLASH_NSCR*         = FLASH_BASE + 028H;
    FLASH_SECCR*        = FLASH_BASE + 02CH;
    FLASH_ECCR*         = FLASH_BASE + 030H;
    FLASH_OPSR*         = FLASH_BASE + 034H;
    FLASH_OPTR*         = FLASH_BASE + 040H;
    FLASH_NSBOOTADD0R*  = FLASH_BASE + 044H;
    FLASH_NSBOOTADD1R*  = FLASH_BASE + 048H;
    FLASH_SECBOOTADD0R* = FLASH_BASE + 04CH;
    FLASH_SECWM1R1*     = FLASH_BASE + 050H;
    FLASH_SECWM1R2*     = FLASH_BASE + 054H;
    FLASH_WRP1AR*       = FLASH_BASE + 058H;
    FLASH_WRP1BR*       = FLASH_BASE + 05CH;
    FLASH_SECWM2R1*     = FLASH_BASE + 060H;
    FLASH_SECWM2R2*     = FLASH_BASE + 064H;
    FLASH_WRP2AR*       = FLASH_BASE + 068H;
    FLASH_WRP2BR*       = FLASH_BASE + 06CH;
    FLASH_OEM1KEYR1*    = FLASH_BASE + 070H;
    FLASH_OEM1KEYR2*    = FLASH_BASE + 074H;
    FLASH_OEM2KEYR1*    = FLASH_BASE + 078H;
    FLASH_OEM2KEYR2*    = FLASH_BASE + 07CH;

    FLASH_SECBB1R*      = FLASH_BASE + 080H; (* 0 .. 7, 4 bytes offset per page *)
    FLASH_SECBB2R*      = FLASH_BASE + 0A0H; (* 0 .. 7, 4 bytes offset per page *)

    FLASH_SECHDPCR*     = FLASH_BASE + 0C0H;
    FLASH_PRIVCFGR*     = FLASH_BASE + 0C4H;

    FLASH_PRIVBB1R*     = FLASH_BASE + 0D0H; (* 0 .. 7, 4 bytes offset per page *)
    FLASH_PRIVBB2R*     = FLASH_BASE + 0F0H; (* 0 .. 7, 4 bytes offset per page *)

    (* bus clock *)
    (* is enabled after reset *)

    (* Secure *)
    (* each register is defined as S or NS *)

(* == RAMCFG == *)

    RAMCFG_BASE* = MCU.RAMCFG_BASE;
    RAMCFG_Offset* = 040H;

    (* SRAM1 *)
    RAMCFG_M1CR*        = RAMCFG_BASE + 0000H;
    RAMCFG_M1ISR*       = RAMCFG_BASE + 0008H;
    RAMCFG_M1ERKEYR*    = RAMCFG_BASE + 0028H;

    (* SRAM2 *)
    RAMCFG_M2CR*        = RAMCFG_BASE + 0040H;
    RAMCFG_M2IER*       = RAMCFG_BASE + 0044H;
    RAMCFG_M2ISR*       = RAMCFG_BASE + 0048H;
    RAMCFG_M2SEAR*      = RAMCFG_BASE + 004CH;
    RAMCFG_M2DEAR*      = RAMCFG_BASE + 0050H;
    RAMCFG_M2ICR*       = RAMCFG_BASE + 0054H;
    RAMCFG_M2WPR1*      = RAMCFG_BASE + 0058H;
    RAMCFG_M2WPR2*      = RAMCFG_BASE + 005CH;
    RAMCFG_M2ECCKEYR*   = RAMCFG_BASE + 0064H;
    RAMCFG_M2ERKEYR*    = RAMCFG_BASE + 0068H;

    (* SRAM3 *)
    RAMCFG_M3CR*        = RAMCFG_BASE + 0080H;
    RAMCFG_M3IER*       = RAMCFG_BASE + 0084H;
    RAMCFG_M3ISR*       = RAMCFG_BASE + 0088H;
    RAMCFG_M3SEAR*      = RAMCFG_BASE + 008CH;
    RAMCFG_M3DEAR*      = RAMCFG_BASE + 0090H;
    RAMCFG_M3ICR*       = RAMCFG_BASE + 0094H;
    RAMCFG_M3ECCKEYR*   = RAMCFG_BASE + 00A4H;
    RAMCFG_M3ERKEYR*    = RAMCFG_BASE + 00A8H;

    (* SRAM4 *)
    RAMCFG_M4CR*        = RAMCFG_BASE + 00C0H;
    RAMCFG_M4ISR*       = RAMCFG_BASE + 00C8H;
    RAMCFG_M4ERKEYR*    = RAMCFG_BASE + 00E8H;

    (* BKPSRAM *)
    RAMCFG_M5CR*        = RAMCFG_BASE + 0100H;
    RAMCFG_M5IER*       = RAMCFG_BASE + 0104H;
    RAMCFG_M5ISR*       = RAMCFG_BASE + 0108H;
    RAMCFG_M5SEAR*      = RAMCFG_BASE + 010CH;
    RAMCFG_M5DEAR*      = RAMCFG_BASE + 0110H;
    RAMCFG_M5ICR*       = RAMCFG_BASE + 0114H;
    RAMCFG_M5ECCKEYR*   = RAMCFG_BASE + 0124H;
    RAMCFG_M5ERKEYR*    = RAMCFG_BASE + 0128H;

    (* bus clock *)
    RAMCFG_BC_reg* = RCC_AHB1ENR;
    RAMCFG_BC_pos* = 17;

    (* Secure *)
    RAMCFG_SEC_reg* = GTZC1_TZSC + TZSC_SECCFGR3_Offset;
    RAMCFG_SEC_pos* = 22;


END DEV0.
