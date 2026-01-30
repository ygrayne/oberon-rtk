MODULE MCU2;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  MCU register and memory addresses, bits, values, assembly instructions
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  CONST
    NumCores*         = 1;
    NumUART*          = 5;
    NumSPI*           = 3;
    NumI2C*           = 4;
    NumTimers*        = 11;
    NumPorts*         = 9; (* 16 bits *)
    NumGPIO*          = NumPorts * 16; (* not all functional/connected *)
    NumInterrupts*    = 141; (* not all used/connected *)


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

    (* peripheral devices *)
    PERI_S_Offset*  = 010000000H;

    (* APB1 *)
    TIM2_BASE*          = 040000000H;
    TIM3_BASE*          = 040000400H;
    TIM4_BASE*          = 040000800H;
    TIM5_BASE*          = 040000C00H;
    TIM6_BASE*          = 040001000H;
    TIM7_BASE*          = 040001400H;
    WWDG_BASE*          = 040002C00H;
    IWDG_BASE*          = 040003000H;
    SPI2_BASE*          = 040003800H;
    USART2_BASE*        = 040004400H;
    USART3_BASE*        = 040004800H;
    UART4_BASE*         = 040004C00H;
    UART5_BASE*         = 040005000H;
    I2C1_BASE*          = 040005400H;
    I2C2_BASE*          = 040005800H;
    CRS_BASE*           = 040006000H;
    I2C4_BASE*          = 040008400H;
    LPTIM2_BASE*        = 040009400H;
    FDCAN1_BASE*        = 04000A400H;
    FDCAN1_RAM*         = 04000AC00H;
    UCPD1_BASE*         = 04000DC00H;

    (* APB2 *)
    TIM1_BASE*          = 040012C00H;
    SPI1_BASE*          = 040013000H;
    TIM8_BASE*          = 040013400H;
    USART1_BASE*        = 040013800H;
    TIM15_BASE*         = 040014000H;
    TIM16_BASE*         = 040014400H;
    TIM17_BASE*         = 040014800H;
    SAI1_BASE*          = 040015400H;
    SAI2_BASE*          = 040015800H;

    (* AHB1 *)
    GPDMA1_BASE*        = 040020000H;
    CORDIC_BASE*        = 040021000H;
    FMAC_BASE*          = 040021400H;
    FLASH_BASE*         = 040022000H;
    CRC_BASE*           = 040023000H;
    TSC_BASE*           = 040024000H;
    MDF_BASE*           = 040025000H;
    RAMCFG_BASE*        = 040026000H;
    DMA2D_BASE*         = 04002B000H;
    ICACHE_BASE*        = 040030400H;
    DCACHE1_BASE*       = 040031400H;
    GTZC1_BASE*         = 040032400H;
    BKPSRAM_BASE*       = 040036400H;

    (* AHB2 *)
    GPIOA_BASE*         = 042020000H;
    GPIOB_BASE*         = 042020400H;
    GPIOC_BASE*         = 042020800H;
    GPIOD_BASE*         = 042020C00H;
    GPIOE_BASE*         = 042021000H;
    GPIOF_BASE*         = 042021400H;
    GPIOG_BASE*         = 042021800H;
    GPIOH_BASE*         = 042021C00H;
    GPIOI_BASE*         = 042022000H;
    ADC12_BASE*         = 042028000H;
    DCMI_BASE*          = 04202C000H;
    PSSI_BASE*          = 04202C400H;
    OTG_FS_BASE*        = 042040000H;
    AES_BASE*           = 0420C0000H;
    HASH_BASE*          = 0420C0400H;
    RNG_BASE*           = 0420C0800H;
    SAES_BASE*          = 0420C0C00H;
    PKA_BASE*           = 0420C2000H;
    OCTOSPIM_BASE*      = 0420C4000H;
    OTFDEC1_BASE*       = 0420C5000H;
    OTFDEC2_BASE*       = 0420C5400H;
    SDMMC1_BASE*        = 0420C8000H;
    DLYBSD1_BASE*       = 0420C8400H;
    DLYBSD2_BASE*       = 0420C8800H;
    SDMMC2_BASE*        = 0420C8C00H;
    DLYBOS1_BASE*       = 0420CF000H;
    DLYBOS2_BASE*       = 0420CF400H;
    FMC_BASE*           = 0420D0400H;
    OCTOSPI1_BASE*      = 0420D1400H;
    OCTOSPI2_BASE*      = 0420D2400H;

    (* APB3 *)
    SYSCFG_BASE*        = 046000400H;
    SPI3_BASE*          = 046002000H;
    LPUART1_BASE*       = 046002400H;
    I2C3_BASE*          = 046003000H;
    LPTIM1_BASE*        = 046004400H;
    LPTIM3_BASE*        = 046004800H;
    LPTIM4_BASE*        = 046004C00H;
    OPAMP_BASE*         = 046005000H;
    COMP_BASE*          = 046005400H;
    VREFBUF_BASE*       = 046007400H;
    RTC_BASE*           = 046007800H;
    TAMP_BASE*          = 046007C00H;

    (* AHB3 *)
    LPGPIO1_BASE*       = 046020000H;
    PWR_BASE*           = 046020800H;
    RCC_BASE*           = 046020C00H;
    ADC4_BASE*          = 046021000H;
    DAC1_BASE*          = 046021800H;
    EXTI_BASE*          = 046022000H;
    GTZC2_BASE*         = 046023000H;
    ADF1_BASE*          = 046024000H;
    LPDMA1_BASE*        = 046025000H;

    (* PPB *)
    PPB_BASE*           = 0E0000000H;
    PPB_NS_Offset*      = 020000H;

    (* -- TIM -- *)
    TIM_Offset* = 0400H;
    TIM_CR1_Offset*    = 0000H; (* all *)
    TIM_CR2_Offset*    = 0004H; (* all *)
    TIM_SMCR_Offset*   = 0008H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15 *)
    TIM_DIER_Offset*   = 000CH; (* all *)
    TIM_SR_Offset*     = 0010H; (* all *)
    TIM_EGR_Offset*    = 0014H; (* all *)
    TIM_CCMR1_Offset*  = 0018H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)
    TIM_CCMR2_Offset*  = 001CH; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8 *)
    TIM_CCER_Offset*   = 0020H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)
    TIM_CNT_Offset*    = 0024H; (* all *)
    TIM_PSC_Offset*    = 0028H; (* all *)
    TIM_ARR_Offset*    = 002CH; (* all *)
    TIM_RCR_Offset*    = 0030H; (* TIM1, TIM8, TIM15, TIM16, TIM17 *)
    TIM_CCR1_Offset*   = 0034H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)
    TIM_CCR2_Offset*   = 0038H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15 *)
    TIM_CCR3_Offset*   = 003CH; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8 *)
    TIM_CCR4_Offset*   = 0040H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8 *)
    TIM_BDTR_Offset*   = 0044H; (* TIM1, TIM8, TIM15, TIM16, TIM17 *)
    TIM_CCR5_Offset*   = 0048H; (* TIM1, TIM8 *)
    TIM_CCR6_Offset*   = 004CH; (* TIM1, TIM8 *)
    TIM_CCMR3_Offset*  = 0050H; (* TIM1, TIM8 *)
    TIM_DTR2_Offset*   = 0054H; (* TIM1, TIM8, TIM15, TIM16, TIM17 *)
    TIM_ECR_Offset*    = 0058H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15 *)
    TIM_TISEL_Offset*  = 005CH; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)
    TIM_AF1_Offset*    = 0060H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)
    TIM_AF2_Offset*    = 0064H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)
    TIM_DCR_Offset*    = 03DCH; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)
    TIM_DMAR_Offset*   = 03E0H; (* TIM1, TIM2, TIM3, TIM4, TIM5, TIM8, TIM15, TIM16, TIM17 *)


    (* -- UART -- *)
    UART_Offset* = USART3_BASE - USART2_BASE; (* USART2 to UART5 *)
    UART_CR1_Offset*    = 000H;
    UART_CR2_Offset*    = 004H;
    UART_CR3_Offset*    = 008H;
    UART_BRR_Offset*    = 00CH;
    UART_GTPR_Offset*   = 010H;
    UART_RTOR_Offset*   = 014H;
    UART_RQR_Offset*    = 018H;
    UART_ISR_Offset*    = 01CH;
    UART_ICR_Offset*    = 020H;
    UART_RDR_Offset*    = 024H;
    UART_TDR_Offset*    = 028H;
    UART_PRESC_Offset*  = 02CH;
    UART_AUTOCR_Offset* = 030H;

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


    (* -- GPIO -- *)
    (* ref manual ch13, p641 *)
    GPIO_Offset* = GPIOB_BASE - GPIOA_BASE;
    GPIO_MODER_Offset*    = 000H;
    GPIO_OTYPER_Offset*   = 004H;
    GPIO_OSPEEDR_Offset*  = 008H;
    GPIO_PUPDR_Offset*    = 00CH;
    GPIO_IDR_Offset*      = 010H;
    GPIO_ODR_Offset*      = 014H;
    GPIO_BSRR_Offset*     = 018H;
    GPIO_LCKR_Offset*     = 01CH;
    GPIO_AFRL_Offset*     = 020H;
    GPIO_AFRH_Offset*     = 024H;
    GPIO_BRR_Offset*      = 028H;
    GPIO_HSLVR_Offset*    = 02CH;
    GPIO_SECCFGR_Offset*  = 030H;

    GPIOA* = GPIOA_BASE;
    GPIOB* = GPIOB_BASE;
    GPIOC* = GPIOC_BASE;
    GPIOD* = GPIOD_BASE;
    GPIOE* = GPIOE_BASE;
    GPIOF* = GPIOF_BASE;
    GPIOG* = GPIOG_BASE;
    GPIOH* = GPIOH_BASE;
    GPIOI* = GPIOI_BASE;

    GPIO0* = GPIOA;
    GPIO1* = GPIOB;
    GPIO2* = GPIOC;
    GPIO3* = GPIOD;
    GPIO4* = GPIOE;
    GPIO5* = GPIOF;
    GPIO6* = GPIOG;
    GPIO7* = GPIOH;
    GPIO8* = GPIOI;

    PORTA* = GPIOA;
    PORTB* = GPIOB;
    PORTC* = GPIOC;
    PORTD* = GPIOD;
    PORTE* = GPIOE;
    PORTF* = GPIOF;
    PORTG* = GPIOG;
    PORTH* = GPIOH;
    PORTI* = GPIOI;


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

    (* RCC_AHB1ENR, RCC_AHB1RSTR, RCC_AHB1SMENR *)
    DEV_GPDMA*    = 0;
    DEV_CORDIC*   = 1;
    DEV_FMAC*     = 2;
    DEV_FLASH*    = 8;  (* no reset *)
    DEV_RAMCFG*   = 17;
    DEV_GTZC1*    = 24; (* no reset *)
    DEV_BKPSRAM*  = 28; (* no reset *)
    DEV_DCACHE1*  = 30; (* no reset *)
    DEV_SRAM1*    = 31; (* no reset *)

    (* RCC_AHB2ENR1, RCC_AHB2RSTR1, RCC_AHB2SMENR1 *)
    DEV_GPIOA*    = 32 + 0;
    DEV_GPIOB*    = 32 + 1;
    DEV_GPIOC*    = 32 + 2;
    DEV_GPIOD*    = 32 + 3;
    DEV_GPIOE*    = 32 + 4;
    DEV_GPIOF*    = 32 + 5;
    DEV_GPIOG*    = 32 + 6;
    DEV_GPIOH*    = 32 + 7;
    DEV_GPIOI*    = 32 + 8;
    DEV_SRAM2*    = 32 + 30; (* no reset *)
    DEV_SRAM3*    = 32 + 31; (* no reset *)

    (* RCC_AHB2ENR2, RCC_AHB2RSTR2, RCC_AHB2SMENR2 *)
    DEV_OCTOSPI1* = 64 + 4;

    (* RCC_AHB3ENR, RCC_AHB3RSTR, RCC_AHB3SMENR *)
    DEV_LPGPIO1*  = 96 + 0;
    DEV_PWR*      = 96 + 2;  (* no reset *)
    DEV_GTZC2*    = 96 + 12; (* no reset *)
    DEV_SRAM4*    = 96 + 31; (* no reset *)

    (* note the address gap here *)

    (* RCC_APB1ENR1, RCC_APB1RSTR1, RCC_APB1SMENR1 *)
    DEV_TIM2*     = 160 + 0;
    DEV_TIM3*     = 160 + 1;
    DEV_TIM4*     = 160 + 2;
    DEV_TIM5*     = 160 + 3;
    DEV_TIM6*     = 160 + 4;
    DEV_TIM7*     = 160 + 5;
    DEV_SPI2*     = 160 + 14;
    DEV_USART2*   = 160 + 17;
    DEV_USART3*   = 160 + 18;
    DEV_UART4*    = 160 + 19;
    DEV_UART5*    = 160 + 20;
    DEV_I2C1*     = 160 + 21;
    DEV_I2C2*     = 160 + 22;

    (* RCC_APB1ENR2, RCC_APB1RSTR2, RCC_APB1SMENR2 *)
    DEV_I2C4*     = 192 + 1;
    DEV_LPTIM2*   = 192 + 5;

    (* RCC_APB2ENR, RCC_APB2RSTR, RCC_APB2SMENR *)
    DEV_TIM1*     = 224 + 11;
    DEV_SPI1*     = 224 + 12;
    DEV_TIM8*     = 224 + 13;
    DEV_USART1*   = 224 + 14;
    DEV_TIM15*    = 224 + 16;
    DEV_TIM16*    = 224 + 17;
    DEV_TIM17*    = 224 + 18;

    (* RCC_APB3ENR, RCC_APB3RSTR, RCC_APB3SMENR *)
    DEV_SYSCFG*   = 256 + 1;
    DEV_SPI3*     = 256 + 5;
    DEV_LPUART1*  = 256 + 6;
    DEV_I2C3*     = 256 + 7;
    DEV_LPTIM1*   = 256 + 11;
    DEV_LPTIM3*   = 256 + 12;
    DEV_LPTIM4*   = 256 + 13;
    DEV_OPAMP*    = 256 + 14;
    DEV_COMP*     = 256 + 15;

    (* begin of SCS: System Control Space *)

    (* -- implementation control block -- *)
    PPB_ICTR*         = PPB_BASE + 0E004H;
    PPB_ACTLR*        = PPB_BASE + 0E008H;

    (* -- SysTick -- *)
    PPB_SYST_CSR*     = PPB_BASE + 0E010H;
    PPB_SYST_RVR*     = PPB_BASE + 0E014H;
    PPB_SYST_CVR*     = PPB_BASE + 0E018H;
    PPB_SYST_CALIB*   = PPB_BASE + 0E01CH;

    (* -- NVIC -- *)
    PPB_NVIC_ISER0*   = PPB_BASE + 0E100H;
    PPB_NVIC_ICER0*   = PPB_BASE + 0E180H;
    PPB_NVIC_ISPR0*   = PPB_BASE + 0E200H;
    PPB_NVIC_ICPR0*   = PPB_BASE + 0E280H;
    PPB_NVIC_IABR0*   = PPB_BASE + 0E300H;
    PPB_NVIC_ITNS0*   = PPB_BASE + 0E380H;
    PPB_NVIC_IPR0*    = PPB_BASE + 0E400H;


    (* -- IRQ numbers -- *)
    IRQ_BASE*           = 16; (* exc no = IRQ_BASE + IRQ number *)
    IRQ_WWDG*           = 0;
    IRQ_PVD_PVM*        = 1;
    IRQ_RTC*            = 2;
    IRQ_RTC_S*          = 3;
    IRQ_TAMP*           = 4;
    IRQ_RAMCFG*         = 5;
    IRQ_FLASH*          = 6;
    IRQ_FLASH_S*        = 7;
    IRQ_GTZC*           = 8;
    IRQ_RCC*            = 9;
    IRQ_RCC_S*          = 10;
    IRQ_EXTI0*          = 11;
    IRQ_EXTI1*          = 12;
    IRQ_EXTI2*          = 13;
    IRQ_EXTI3*          = 14;
    IRQ_EXTI4*          = 15;
    IRQ_EXTI5*          = 16;
    IRQ_EXTI6*          = 17;
    IRQ_EXTI7*          = 18;
    IRQ_EXTI8*          = 19;
    IRQ_EXTI9*          = 20;
    IRQ_EXTI10*         = 21;
    IRQ_EXTI11*         = 22;
    IRQ_EXTI12*         = 23;
    IRQ_EXTI13*         = 24;
    IRQ_EXTI14*         = 25;
    IRQ_EXTI15*         = 26;
    IRQ_IWDG*           = 27;
    IRQ_SAES*           = 28;
    IRQ_GPDMA1_CH0*     = 29;
    IRQ_GPDMA1_CH1*     = 30;
    IRQ_GPDMA1_CH2*     = 31;
    IRQ_GPDMA1_CH3*     = 32;
    IRQ_GPDMA1_CH4*     = 33;
    IRQ_GPDMA1_CH5*     = 34;
    IRQ_GPDMA1_CH6*     = 35;
    IRQ_GPDMA1_CH7*     = 36;
    IRQ_ADC12*          = 37;
    IRQ_DAC1*           = 38;
    IRQ_FDCAN1_0*       = 39;
    IRQ_FDCAN1_1*       = 40;
    IRQ_TIM1_0*         = 41; (* TIM1_BRK, TIM1_TERR, TIM1_IERR *)
    IRQ_TIM1_UP*        = 42;
    IRQ_TIM1_1*         = 43; (* TIM1_TRG_COM, TIM1_DIR, TIM1_IDX *)
    IRQ_TIM1_CC*        = 44;
    IRQ_TIM2*           = 45;
    IRQ_TIM3*           = 46;
    IRQ_TIM4*           = 47;
    IRQ_TIM5*           = 48;
    IRQ_TIM6*           = 49;
    IRQ_TIM7*           = 50;
    IRQ_TIM8_0*         = 51; (* TIM8_BRK, TIM8_TERR, TIM8_IERR *)
    IRQ_TIM8_UP*        = 52;
    IRQ_TIM8_1*         = 53; (* TIM8_TRG_COM, TIM8_DIR, TIM8_IDX *)
    IRQ_TIM8_CC*        = 54;
    IRQ_I2C1_EV*        = 55;
    IRQ_I2C1_ER*        = 56;
    IRQ_I2C2_EV*        = 57;
    IRQ_I2C2_ER*        = 58;
    IRQ_SPI1*           = 59;
    IRQ_SPI2*           = 60;
    IRQ_USART1*         = 61;
    IRQ_USART2*         = 62;
    IRQ_USART3*         = 63;
    IRQ_UART4*          = 64;
    IRQ_UART5*          = 65;
    IRQ_LPUART1*        = 66;
    IRQ_LPTIM1*         = 67;
    IRQ_LPTIM2*         = 68;
    IRQ_TIM15*          = 69;
    IRQ_TIM16*          = 70;
    IRQ_TIM17*          = 71;
    IRQ_COMP*           = 72;
    IRQ_USB*            = 73;
    IRQ_CRS*            = 74;
    IRQ_FMC*            = 75;
    IRQ_OCTOSPI1*       = 76;
    IRQ_PWR_S3WU*       = 77;
    IRQ_SDMMC1*         = 78;
    IRQ_SDMMC2*         = 79;
    IRQ_GPDMA1_CH8*     = 80;
    IRQ_GPDMA1_CH9*     = 81;
    IRQ_GPDMA1_CH10*    = 82;
    IRQ_GPDMA1_CH11*    = 83;
    IRQ_GPDMA1_CH12*    = 84;
    IRQ_GPDMA1_CH13*    = 85;
    IRQ_GPDMA1_CH14*    = 86;
    IRQ_GPDMA1_CH15*    = 87;
    IRQ_I2C3_EV*        = 88;
    IRQ_I2C3_ER*        = 89;
    IRQ_SAI1*           = 90;
    IRQ_SAI2*           = 91;
    IRQ_TSC*            = 92;
    IRQ_AES*            = 93;
    IRQ_RNG*            = 94;
    IRQ_FPU*            = 95;
    IRQ_HASH*           = 96;
    IRQ_PKA*            = 97;
    IRQ_LPTIM3*         = 98;
    IRQ_SPI3*           = 99;
    IRQ_I2C4_EV*        = 100;
    IRQ_I2C4_ER*        = 101;
    IRQ_MDF1_FLT0*      = 102;
    IRQ_MDF1_FLT1*      = 103;
    IRQ_MDF1_FLT2*      = 104;
    IRQ_MDF1_FLT3*      = 105;
    IRQ_UCPD1*          = 106;
    IRQ_ICACHE*         = 107;
    IRQ_OTFDEC1*        = 108;
    IRQ_OTFDEC2*        = 109;
    IRQ_LPTIM4*         = 110;
    IRQ_DCACHE1*        = 111;
    IRQ_ADF1_FLT0*      = 112;
    IRQ_ADC4*           = 113;
    IRQ_LPDMA1_CH0*     = 114;
    IRQ_LPDMA1_CH1*     = 115;
    IRQ_LPDMA1_CH2*     = 116;
    IRQ_LPDMA1_CH3*     = 117;
    IRQ_DMA2D*          = 118;
    IRQ_DCMI_PSSI*      = 119;
    IRQ_OCTOSPI2*       = 120;
    IRQ_MDF1_FLT4*      = 121;
    IRQ_MDF1_FLT5*      = 122;
    IRQ_CORDIC*         = 123;
    IRQ_FMAC*           = 124;
    IRQ_LSECSS*         = 125;
    (* the reserved IRQs are not wired and available via NVIC regs *)
    (* that is, they cannot be used for SW *)
    IRQ_Reserved_126*   = 126;  (* USART6 *)
    IRQ_Reserved_127*   = 127;  (* I2C5_ER *)
    IRQ_Reserved_128*   = 128;  (* I2C5_EV *)
    IRQ_Reserved_129*   = 129;  (* I2C6_ER *)
    IRQ_Reserved_130*   = 130;  (* I2C6_EV *)
    IRQ_Reserved_131*   = 131;  (* HSPI1 *)
    IRQ_Reserved_132*   = 132;  (* GPU2D *)
    IRQ_Reserved_133*   = 133;  (* GPU2D_SYS *)
    IRQ_Reserved_134*   = 134;  (* GFXMMU *)
    IRQ_Reserved_135*   = 135;  (* LCDC *)
    IRQ_Reserved_136*   = 136;  (* LCDC_ERR *)
    IRQ_Reserved_137*   = 137;  (* DSIHOST *)
    IRQ_Reserved_138*   = 138;  (* DCACHE2 *)
    IRQ_Reserved_139*   = 139;  (* GFXTIM *)
    IRQ_Reserved_140*   = 140;  (* JPEG *)

    (* IRQ for SW use *)
    (* no general definitions *)
    (* must be determined for a specific program *)
    (* by using another otherwise unused IRQ *)


    (* -- system exception numbers -- *)
    EXC_NMI*          = 2;
    EXC_HardFault*    = 3;
    EXC_MemMgmtFault* = 4;
    EXC_BusFault*     = 5;
    EXC_UsageFault*   = 6;
    EXC_SecureFault*  = 7;
    EXC_SVC*          = 11;
    EXC_DebugMon*     = 12;
    EXC_PendSV*       = 14;
    EXC_SysTick*      = 15;

    SysExc*  = {3, 4, 5, 6, 11, 14, 15};

    (* -- exception priorities, 4 bits *)
    ExcPrio0*   = 000H; (* 0000 0000 *)
    ExcPrio1*   = 020H; (* 0010 0000 *)
    ExcPrio2*   = 040H; (* 0100 0000 *)
    ExcPrio3*   = 060H; (* 0110 0000 *)
    ExcPrio4*   = 080H; (* 1000 0000 *)
    ExcPrio5*   = 0A0H; (* 1010 0000 *)
    ExcPrio6*   = 0C0H; (* 1100 0000 *)
    ExcPrio7*   = 0E0H; (* 1110 0000 *)

    ExcPrio00*  = 000H; (* 0000 0000 *)
    ExcPrio10*  = 010H; (* 0001 0000 *)
    ExcPrio20*  = 020H; (* 0010 0000 *)
    ExcPrio30*  = 030H; (* 0011 0000 *)
    ExcPrio40*  = 040H; (* 0100 0000 *)
    ExcPrio50*  = 050H; (* 0101 0000 *)
    ExcPrio60*  = 060H; (* 0110 0000 *)
    ExcPrio70*  = 070H; (* 0111 0000 *)
    ExcPrio80*  = 080H; (* 1000 0000 *)
    ExcPrio90*  = 090H; (* 1001 0000 *)
    ExcPrioA0*  = 0A0H; (* 1010 0000 *)
    ExcPrioB0*  = 0B0H; (* 1011 0000 *)
    ExcPrioC0*  = 0C0H; (* 1100 0000 *)
    ExcPrioD0*  = 0D0H; (* 1101 0000 *)
    ExcPrioE0*  = 0E0H; (* 1110 0000 *)
    ExcPrioF0*  = 0F0H; (* 1111 0000 *)

    NumExcPrio* = 16;

    ExcPrioTop*    = ExcPrio00;
    ExcPrioHigh*   = ExcPrio10;
    ExcPrioMedium* = ExcPrio80;
    ExcPrioLow*    = ExcPrioF0;

    (* -- vector table -- *)
    VectorTableSize*          = 628; (* bytes: 16 sys exceptions + 141 interrupts, one word each *)
    EXC_Reset_Offset*         = 004H;
    EXC_NMI_Offset*           = 008H;
    EXC_HardFault_Offset*     = 00CH;
    EXC_MemMgmtFault_Offset*  = 010H;
    EXC_BusFault_Offset*      = 014H;
    EXC_UsageFault_Offset*    = 018H;
    EXC_SecureFault_Offset*   = 01CH;
    EXC_SVC_Offset*           = 02CH;
    EXC_DebugMon_Offset*      = 030H;
    EXC_PendSV_Offset*        = 038H;
    EXC_SysTick_Offset*       = 03CH;
    EXC_IRQ0_Offset*          = 040H;

    (* -- SCB system control block -- *)
    PPB_ICSR*         = PPB_BASE + 0ED04H;
    PPB_VTOR*         = PPB_BASE + 0ED08H;
    PPB_AIRCR*        = PPB_BASE + 0ED0CH;
    PPB_SCR*          = PPB_BASE + 0ED10H;
    PPB_CCR*          = PPB_BASE + 0ED14H;

    PPB_SHPR1*        = PPB_BASE + 0ED18H;
    PPB_SHPR2*        = PPB_BASE + 0ED1CH;
    PPB_SHPR3*        = PPB_BASE + 0ED20H;

    PPB_SHCSR*        = PPB_BASE + 0ED24H;

    PPB_CFSR*         = PPB_BASE + 0ED28H; (* UFSR [31:16], BFSR [15:8], MMFSR [7:0] *)
    PPB_HFSR*         = PPB_BASE + 0ED2CH;
    PPB_DFSR*         = PPB_BASE + 0ED30H;
    PPB_MMFAR*        = PPB_BASE + 0ED34H;
    PPB_BFAR*         = PPB_BASE + 0ED38H;
    PPB_AFSR*         = PPB_BASE + 0ED3CH;
    PPB_CPACR*        = PPB_BASE + 0ED88H;

    (* -- MPU -- *)
    PPB_MPU_TYPE*     = PPB_BASE + 0ED90H;
    PPB_MPU_CTRL*     = PPB_BASE + 0ED94H;
    PPB_MPU_RNR*      = PPB_BASE + 0ED98H;
    PPB_MPU_RBAR*     = PPB_BASE + 0ED9CH;
    PPB_MPU_RLAR*     = PPB_BASE + 0EDA0H;
    PPB_MPU_RBAR_A1*  = PPB_BASE + 0EDA4H;
    PPB_MPU_RLAR_A1*  = PPB_BASE + 0EDA8H;
    PPB_MPU_RBAR_A2*  = PPB_BASE + 0EDACH;
    PPB_MPU_RLAR_A2*  = PPB_BASE + 0EDB0H;
    PPB_MPU_RBAR_A3*  = PPB_BASE + 0EDB4H;
    PPB_MPU_RLAR_A4*  = PPB_BASE + 0EDB8H;
    PPB_MPU_MAIR0*    = PPB_BASE + 0EDC0H;
    PPB_MPU_MAIR1*    = PPB_BASE + 0EDC4H;

    (* -- SAU -- *)
    PPB_SAU_CTRL*     = PPB_BASE + 0EDD0H;
    PPB_SAU_TYPE*     = PPB_BASE + 0EDD4H;
    PPB_SAU_RNR*      = PPB_BASE + 0EDD8H;
    PPB_SAU_RBAR*     = PPB_BASE + 0EDDCH;
    PPB_SAU_RLAR*     = PPB_BASE + 0EDE0H;
    PPB_SAU_SFSR*     = PPB_BASE + 0EDE4H;
    PPB_SAU_SFAR*     = PPB_BASE + 0EDE8H;


    (* -- sw interrupt generation -- *)
    PPB_STIR*         = PPB_BASE + 0EF00H;



    (* end of system control space *)

    (* -- CPU registers -- *)
    (* CONTROL special register *)
    CONTROL_SPSEL* = 1; (* enable PSP *)


    (* -- assembly instructions -- *)
    NOP* = 046C0H;

    BLXNS_R11* = 047DCH;
    BLXNS_R12* = 047E4H;
    POP_LR* = 0E8BD4000H;
    BX_LR* = 04770H;
    BXNS_LR* = 04774H;
    ADD_SP* = 0B000H;

    (* read specical regs MRS *)
    (* 0F3EF8 B 09H r11(B) PSP(09) *)
    (* [11:8] = register Rn *)
    (* [7:0] = special reg SYSm *)
    MRS_R11_IPSR* = 0F3EF8B05H;  (* move IPSR to r11 *)
    MRS_R03_IPSR* = 0F3EF8305H;  (* move IPSR to r3 *)
    MRS_R00_IPSR* = 0F3EF8005H;  (* move IPSR to r0 *)

    MRS_R11_XPSR* = 0F3EF8B03H;  (* move XPSR to r11 *)
    MRS_R03_XPSR* = 0F3EF8303H;  (* move XPSR to r3 *)

    MRS_R11_MSP*  = 0F3EF8B08H;  (* move MSP to r11 *)
    MRS_R03_MSP*  = 0F3EF8308H;  (* move MSP to r3 *)
    MRS_R00_MSP*  = 0F3EF8008H;  (* move MSP to r0 *)

    MRS_R11_PSP*  = 0F3EF8B09H;  (* move PSP to r11 *)
    MRS_R03_PSP*  = 0F3EF8309H;  (* move PSP to r3 *)
    MRS_R00_PSP*  = 0F3EF8009H;  (* move PSP to r0 *)

    MRS_R11_CTL*  = 0F3EF8B14H;  (* move CONTROL = 14H to r11 *)
    MRS_R03_CTL*  = 0F3EF8314H;  (* move CONTROL = 14H to r3 *)

    MRS_R03_BASEPRI* = 0F3EF8311H; (* move BASEPRI = 11H to r3 *)
    MRS_R07_BASEPRI* = 0F3EF8711H; (* move BASEPRI = 11H to r7 *)
    MRS_R11_BASEPRI* = 0F3EF8B11H; (* move BASEPRI = 11H to r11 *)

    (* write special regs MSR *)
    (* 0F38 B 88 09H r11(B) PSP(09) *)
    (* [19:16] = register Rn *)
    (* [7:0] = special register SYSm *)
    MSR_PSP_R11* = 0F38B8809H;  (* move r11 to PSP *)
    MSR_MSP_R11* = 0F38B8808H;  (* move r11 to MSP *)
    MSR_CTL_R11* = 0F38B8814H;  (* move r11 to CONTROL *)

    MSR_MSPns_R11* = 0F38B8888H;  (* move r11 to MSPns *)

    MSR_BASEPRI_R02* = 0F3828811H; (* move r02 to BASEPRI *)
    MSR_BASEPRI_R03* = 0F3838811H; (* move r03 to BASEPRI *)
    MSR_BASEPRI_R06* = 0F3868811H; (* move r06 to BASEPRI *)
    MSR_BASEPRI_R07* = 0F3878811H; (* move r07 to BASEPRI *)
    MSR_BASEPRI_R11* = 0F38B8811H; (* move r11 to BASEPRI *)

    (* instruction & data sync *)
    ISB* = 0F3BF8F6FH;
    DSB* = 0F3BF8F4FH;
    DMB* = 0F3BF8F5FH;

    (* raise execution prio to 0 via PRIMASK *)
    CPSIE_I* = 0B662H; (* enable:  1011 0110 0110 0010 *)
    CPSID_I* = 0B672H; (* disable: 1011 0110 0111 0010 *)
    (* raise execution prio to -1 = HardFault via FAULTMASK *)
    (* clears on handler exit *)
    CPSIE_F* = 0B662H; (* enable:  1011 0110 0110 0001 *)
    CPSID_F* = 0B672H; (* disable: 1011 0110 0111 0001 *)

    (* wait for event/interrupt *)
    WFE* = 0BF20H;
    WFI* = 0BF30H;

    (* SVC *)
    (* SVCinstr = 'SVC' + SVCvalue *)
    SVC* = 0DF00H;

END MCU2.
