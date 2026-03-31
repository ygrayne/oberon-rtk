MODULE MCU;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Non-secure MCU definitions
  --
  Non-secure alias addresses.
  The ./def variant uses the base addresses with the offset.
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  CONST

    (* == MCU constants == *)
    NumCores*         = 1;

    (* == memory layout == *)
    (* non-secure *)
    (* non-secure: C bus/code *)
    FLASH_Cb_NS_BASE*  = 008000000H;
    SRAM1_Cb_NS_BASE*  = 00A000000H;
    SRAM2_Cb_NS_BASE*  = 00A030000H;
    SRAM3_Cb_NS_BASE*  = 00A040000H;

    (* non-secure: S bus/data *)
    SRAM1_Sb_NS_BASE*  = 020000000H;
    SRAM2_Sb_NS_BASE*  = 020030000H;
    SRAM3_Sb_NS_BASE*  = 020040000H;
    (* non contiguous *)
    SRAM4_Sb_NS_BASE*  = 028000000H;

    (* secure/non-secure callable *)
    FLASH_Cb_S_Offset* = 004000000H;
    SRAM_Cb_S_Offset*  = 004000000H;
    SRAM_Sb_S_Offset*  = 010000000H;

    (* secure: C bus/code *)
    FLASH_Cb_S_BASE*  = FLASH_Cb_NS_BASE + FLASH_Cb_S_Offset;
    SRAM1_Cb_S_BASE*  = SRAM1_Cb_NS_BASE + SRAM_Cb_S_Offset;
    SRAM2_Cb_S_BASE*  = SRAM2_Cb_NS_BASE + SRAM_Cb_S_Offset;
    SRAM3_Cb_S_BASE*  = SRAM3_Cb_NS_BASE + SRAM_Cb_S_Offset;

    (* secure: S bus/data *)
    SRAM1_Sb_S_BASE*   = SRAM1_Sb_NS_BASE + SRAM_Sb_S_Offset;
    SRAM2_Sb_S_BASE*   = SRAM2_Sb_NS_BASE + SRAM_Sb_S_Offset;
    SRAM3_Sb_S_BASE*   = SRAM3_Sb_NS_BASE + SRAM_Sb_S_Offset;
    (* non contiguous *)
    SRAM4_Sb_S_BASE*   = SRAM4_Sb_NS_BASE + SRAM_Sb_S_Offset;

    (* sizes *)
    FLASH_Size* = 0200000H; (* 2M *)
    SRAM1_Size* = 0030000H; (* 196k *)
    SRAM2_Size* = 0010000H; (* 64k *)
    SRAM3_Size* = 0080000H; (* 512k *)
    SRAM4_Size* = 0004000H; (* 16k *)


    (* == peripheral devices S/NS address offset == *)
    PERI_S_Offset*  = 010000000H;

    (* == peripheral devices base addresses == *)
    (* APB1 *)
    TIM2_BASE*      = 040000000H;
    TIM3_BASE*      = 040000400H;
    TIM4_BASE*      = 040000800H;
    TIM5_BASE*      = 040000C00H;
    TIM6_BASE*      = 040001000H;
    TIM7_BASE*      = 040001400H;
    WWDG_BASE*      = 040002C00H;
    IWDG_BASE*      = 040003000H;
    SPI2_BASE*      = 040003800H;
    USART2_BASE*    = 040004400H;
    USART3_BASE*    = 040004800H;
    UART4_BASE*     = 040004C00H;
    UART5_BASE*     = 040005000H;
    I2C1_BASE*      = 040005400H;
    I2C2_BASE*      = 040005800H;
    CRS_BASE*       = 040006000H;
    I2C4_BASE*      = 040008400H;
    LPTIM2_BASE*    = 040009400H;
    FDCAN1_BASE*    = 04000A400H;
    FDCAN1_RAM*     = 04000AC00H;
    UCPD1_BASE*     = 04000DC00H;

    (* APB2 *)
    TIM1_BASE*      = 040012C00H;
    SPI1_BASE*      = 040013000H;
    TIM8_BASE*      = 040013400H;
    USART1_BASE*    = 040013800H;
    TIM15_BASE*     = 040014000H;
    TIM16_BASE*     = 040014400H;
    TIM17_BASE*     = 040014800H;
    SAI1_BASE*      = 040015400H;
    SAI2_BASE*      = 040015800H;

    (* AHB1 *)
    GPDMA1_BASE*    = 040020000H;
    CORDIC_BASE*    = 040021000H;
    FMAC_BASE*      = 040021400H;
    FLASH_BASE*     = 040022000H;
    CRC_BASE*       = 040023000H;
    TSC_BASE*       = 040024000H;
    MDF_BASE*       = 040025000H;
    RAMCFG_BASE*    = 040026000H;
    DMA2D_BASE*     = 04002B000H;
    ICACHE_BASE*    = 040030400H;
    DCACHE1_BASE*   = 040031400H;
    GTZC1_BASE*     = 040032400H;
    BKPSRAM_BASE*   = 040036400H;

    (* AHB2 *)
    GPIOA_BASE*     = 042020000H;
    GPIOB_BASE*     = 042020400H;
    GPIOC_BASE*     = 042020800H;
    GPIOD_BASE*     = 042020C00H;
    GPIOE_BASE*     = 042021000H;
    GPIOF_BASE*     = 042021400H;
    GPIOG_BASE*     = 042021800H;
    GPIOH_BASE*     = 042021C00H;
    GPIOI_BASE*     = 042022000H;
    ADC12_BASE*     = 042028000H;
    DCMI_BASE*      = 04202C000H;
    PSSI_BASE*      = 04202C400H;
    OTG_FS_BASE*    = 042040000H;
    AES_BASE*       = 0420C0000H;
    HASH_BASE*      = 0420C0400H;
    RNG_BASE*       = 0420C0800H;
    SAES_BASE*      = 0420C0C00H;
    PKA_BASE*       = 0420C2000H;
    OCTOSPIM_BASE*  = 0420C4000H;
    OTFDEC1_BASE*   = 0420C5000H;
    OTFDEC2_BASE*   = 0420C5400H;
    SDMMC1_BASE*    = 0420C8000H;
    DLYBSD1_BASE*   = 0420C8400H;
    DLYBSD2_BASE*   = 0420C8800H;
    SDMMC2_BASE*    = 0420C8C00H;
    DLYBOS1_BASE*   = 0420CF000H;
    DLYBOS2_BASE*   = 0420CF400H;
    FMC_BASE*       = 0420D0400H;
    OCTOSPI1_BASE*  = 0420D1400H;
    OCTOSPI2_BASE*  = 0420D2400H;

    (* APB3 *)
    SYSCFG_BASE*    = 046000400H;
    SPI3_BASE*      = 046002000H;
    LPUART1_BASE*   = 046002400H;
    I2C3_BASE*      = 046003000H;
    LPTIM1_BASE*    = 046004400H;
    LPTIM3_BASE*    = 046004800H;
    LPTIM4_BASE*    = 046004C00H;
    OPAMP_BASE*     = 046005000H;
    COMP_BASE*      = 046005400H;
    VREFBUF_BASE*   = 046007400H;
    RTC_BASE*       = 046007800H;
    TAMP_BASE*      = 046007C00H;

    (* AHB3 *)
    LPGPIO1_BASE*   = 046020000H;
    PWR_BASE*       = 046020800H;
    RCC_BASE*       = 046020C00H;
    ADC4_BASE*      = 046021000H;
    DAC1_BASE*      = 046021800H;
    EXTI_BASE*      = 046022000H;
    GTZC2_BASE*     = 046023000H;
    ADF1_BASE*      = 046024000H;
    LPDMA1_BASE*    = 046025000H;

    (* PPB *)
    PPB_BASE*       = 0E0000000H;
    PPB_NS_BASE*    = 0E0020000H;


    (* == peripheral devices == *)

    (* -- FLASH -- *)
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

    (* -- RAMCFG -- *)
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

    RAMCFG_Offset* = 040H;

    (* -- GTZC -- *)
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

    (* -- PWR: power control -- *)
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


    (* -- RCC: reset and clock control -- *)
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

END MCU.
