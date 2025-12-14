MODULE MCU2;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  MCU register and memory addresses, bits, values, assembly instructions
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  CONST
    NumCores*         = 1;
    NumUART*          = 12;
    NumSPI*           = 3;
    NumI2C*           = 4;
    NumTimers*        = 14;
    NumPorts*         = 9; (* 16 bits *)
    NumGPIO*          = NumPorts * 16; (* not all functional/connected *)
    NumInterrupts*    = 131;


(* === base addresses === *)
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


    (* sizes *)
    FLASH_Size* = 0200000H; (* 2M *)
    SRAM1_Size* = 0040000H; (* 256k *)
    SRAM2_Size* = 0010000H; (* 64k *)
    SRAM3_Size* = 0050000H; (* 320k *)

    (* peripheral devices *)
    PERI_S_Offset*  = 010000000H;

    (* APB1 *)
    TIM2_BASE*          = 040000000H;
    TIM3_BASE*          = 040000400H;
    TIM4_BASE*          = 040000800H;
    TIM5_BASE*          = 040000C00H;
    TIM6_BASE*          = 040001000H;
    TIM7_BASE*          = 040001400H;
    TIM12_BASE*         = 040001800H;
    TIM13_BASE*         = 040001C00H;
    TIM14_BASE*         = 040002000H;
    WWDG_BASE*          = 040002C00H;
    IWDG_BASE*          = 040003000H;
    SPI2_BASE*          = 040003800H;
    SPI3_BASE*          = 040003C00H;
    USART2_BASE*        = 040004400H;
    USART3_BASE*        = 040004800H;
    UART4_BASE*         = 040004C00H;
    UART5_BASE*         = 040005000H;
    I2C1_BASE*          = 040005400H;
    I2C2_BASE*          = 040005800H;
    I3C1_BASE*          = 040005C00H;
    CRS_BASE*           = 040006000H;
    USART6_BASE*        = 040006400H;
    USART10_BASE*       = 040006800H;
    USART11_BASE*       = 040006C00H;
    HDMI_CEC_BASE*      = 040007000H;
    UART7_BASE*         = 040007800H;
    UART8_BASE*         = 040007C00H;
    UART9_BASE*         = 040008000H;
    UART12_BASE*        = 040008400H;
    DTS_BASE*           = 040008C00H;
    LPTIM2_BASE*        = 040009400H;
    FDCAN1_BASE*        = 04000A400H;
    FDCAN2_BASE*        = 04000A800H;
    FDCAN_RAM*          = 04000AC00H;
    UCPD1_BASE*         = 04000DC00H;

    (* APB2 *)
    TIM1_BASE*          = 040012C00H;
    SPI1_BASE*          = 040013000H;
    TIM8_BASE*          = 040013400H;
    USART1_BASE*        = 040013800H;
    TIM15_BASE*         = 040014000H;
    TIM16_BASE*         = 040014400H;
    TIM17_BASE*         = 040014800H;
    SPI4_BASE*          = 040014C00H;
    SPI6_BASE*          = 040015000H;
    SAI1_BASE*          = 040015400H;
    SAI2_BASE*          = 040015800H;
    USB_FS_BASE*        = 040016000H;
    USB_FS_RAM*         = 040016400H;

    (* AHB1 *)
    GPDMA1_BASE*        = 040020000H;
    GPDMA2_BASE*        = 040021000H;
    FLASH_BASE*         = 040022000H;
    CRC_BASE*           = 040023000H;
    CORDIC_BASE*        = 040023800H;
    FMAC_BASE*          = 040023C00H;
    RAMCFG_BASE*        = 040026000H;
    ETH_MAC_BASE*       = 040028000H;
    ICACHE_BASE*        = 040030400H;
    DCACHE_BASE*        = 040031400H;
    GTZ1_BASE*          = 040032400H;
    GTZ1_TZSC_BASE*     = 040036400H;

    (* AHB 2 *)
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
    DAC1_BASE*          = 042028400H;
    DCMI_BASE*          = 04202C000H;
    PSSI_BASE*          = 04202C400H;
    AES_BASE*           = 0420C0000H;
    HASH_BASE*          = 0420C0400H;
    RNG_BASE*           = 0420C0800H;
    SAES_BASE*          = 0420C0C00H;
    PKA_BASE*           = 0420C2000H;

    (* APB3 *)
    SBS_BASE*           = 044000400H;
    SPI5_BASE*          = 044002000H;
    LPUART1_BASE*       = 044002400H;
    I2C3_BASE*          = 044002800H;
    I2C4_BASE*          = 044002C00H;
    LPTIM1_BASE*        = 044004400H;
    LPTIM3_BASE*        = 044004800H;
    LPTIM4_BASE*        = 044004C00H;
    LPTIM5_BASE*        = 044005000H;
    LPTIM6_BASE*        = 044005400H;
    VREFBUF_BASE*       = 044007400H;
    RTC_BASE*           = 044007800H;
    TAMP_BASE*          = 044007C00H;

    (* AHB3 *)
    PWR_BASE*           = 044020800H;
    RCC_BASE*           = 044020C00H;
    EXTI_BASE*          = 044022000H;
    DEBUG_BASE*         = 044024000H;

    (* AHB4 *)
    OTFDEC1_BASE*       = 046005000H;
    SDMMC1_BASE*        = 046008000H;
    DLYBSD1_BASE*       = 046008400H;
    DLYBSD2_BASE*       = 046008800H;
    SDMMC2_BASE*        = 046008C00H;
    DLYBOS1_BASE*       = 04600F000H;
    FMC_BASE*           = 047000400H;
    OCTOSPI1_BASE*      = 047001400H;


    (* PPB *)
    PPB_BASE*           = 0E0000000H;

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
    FLASH_ACR*    = FLASH_BASE + 000H;

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
    RAMCFG_M2WPR3*      = RAMCFG_BASE + 0060H;
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
    PWR_PMCR*     = PWR_BASE + 0000H;
    PWR_PMSR*     = PWR_BASE + 0004H;
    PWR_VOSCR*    = PWR_BASE + 0010H;
    PWR_VOSSR*    = PWR_BASE + 0014H;
    PWR_BDCR*     = PWR_BASE + 0020H;
    PWR_DBPCR*    = PWR_BASE + 0024H;
    PWR_BDSR*     = PWR_BASE + 0028H;
    PWR_UCPDR*    = PWR_BASE + 002CH;
    PWR_SCCR*     = PWR_BASE + 0030H;
    PWR_VMCR*     = PWR_BASE + 0034H;
    PWR_USBSCR*   = PWR_BASE + 0038H;
    PWR_VMSR*     = PWR_BASE + 003CH;
    PWR_WUSCR*    = PWR_BASE + 0040H;
    PWR_WUSR*     = PWR_BASE + 0044H;
    PWR_WUCR*     = PWR_BASE + 0048H;
    PWR_IORETR*   = PWR_BASE + 0050H;
    PWR_SECCFGR*  = PWR_BASE + 0100H;
    PWR_PRIVCFGR* = PWR_BASE + 0104H;


    (* -- RCC: reset and clock control -- *)
    (* ref manual ch11, p604 *)
    RCC_CR*             = RCC_BASE + 0000H;
    RCC_HSICFGR*        = RCC_BASE + 0010H;
    RCC_CRRCR*          = RCC_BASE + 0014H;
    RCC_CSICFGR*        = RCC_BASE + 0018H;
    RCC_CFGR1*          = RCC_BASE + 001CH;
    RCC_CFGR2*          = RCC_BASE + 0020H;
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
    RCC_AHB2RSTR*       = RCC_BASE + 0064H;
    RCC_AHB4RSTR*       = RCC_BASE + 006CH;
    RCC_APB1LRSTR*      = RCC_BASE + 0074H;
    RCC_APB1HRSTR*      = RCC_BASE + 0078H;
    RCC_APB2RSTR*       = RCC_BASE + 007CH;
    RCC_APB3RSTR*       = RCC_BASE + 0080H;

    RCC_AHB1ENR*        = RCC_BASE + 0088H;
    RCC_AHB2ENR*        = RCC_BASE + 008CH;
    RCC_AHB4ENR*        = RCC_BASE + 0094H;
    RCC_APB1LENR*       = RCC_BASE + 009CH;
    RCC_APB1HENR*       = RCC_BASE + 00A0H;
    RCC_APB2ENR*        = RCC_BASE + 00A4H;
    RCC_APB3ENR*        = RCC_BASE + 00A8H;

    RCC_AHB1LPENR*      = RCC_BASE + 00B0H;
    RCC_AHB2LPENR*      = RCC_BASE + 00B4H;
    RCC_AHB4LPENR*      = RCC_BASE + 00BCH;
    RCC_APB1LLPENR*     = RCC_BASE + 00C4H;
    RCC_APB1HLPENR*     = RCC_BASE + 00C8H;
    RCC_APB2LPENR*      = RCC_BASE + 00CCH;
    RCC_APB3LPENR*      = RCC_BASE + 00D0H;
    RCC_CCIPR1*         = RCC_BASE + 00D8H;
    RCC_CCIPR2*         = RCC_BASE + 00DCH;
    RCC_CCIPR3*         = RCC_BASE + 00E0H;
    RCC_CCIPR4*         = RCC_BASE + 00E4H;
    RCC_CCIPR5*         = RCC_BASE + 00E8H;
    RCC_BBCR*           = RCC_BASE + 00F0H;
    RCC_RSR*            = RCC_BASE + 00F4H;
    RCC_SECCFGR*        = RCC_BASE + 0110H;
    RCC_PRIVCFGR*       = RCC_BASE + 0114H;


    (* RCC_AHB1ENR, RCC_AHB1LPENR, RCC_AHB1RSTR *)
    DEV_GPDMA1*   = 0;
    DEV_GPDMA2*   = 1;
    DEV_FLASH*    = 8;  (* no reset *)
    DEV_FMAC*     = 15;
    DEV_RAMCFG*   = 17;
    DEV_BKPSRAM*  = 28; (* no reset *)
    DEV_ICACHE*   = 29; (* no non-lp en, no reset *)
    DEV_DCACHE*   = 30; (* no reset *)
    DEV_SRAM1*    = 31; (* no reset *)

    (* RCC_AHB2ENR, RCC_AHB2LPENR, RCC_AHB2RSTR *)
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

    (* note the address gap here *)

    (* RCC_AHB4ENR, RCC_AHB4LPENR, RCC_AHB4RSTR *)
    DEV_FMC*      = 96 + 16;

    (* note the address gap here *)

    (* RCC_APB1LENR, RCC_APB1LLPENR, RCC_APB1LRSTR *)
    DEV_TIM2*     = 160 + 0;
    DEV_TIM3*     = 160 + 1;
    DEV_TIM4*     = 160 + 2;
    DEV_TIM5*     = 160 + 3;
    DEV_TIM6*     = 160 + 4;
    DEV_TIM7*     = 160 + 5;
    DEV_TIM12*    = 160 + 6;
    DEV_TIM13*    = 160 + 7;
    DEV_TIM14*    = 160 + 8;
    DEV_SPI2*     = 160 + 14;
    DEV_SPI3*     = 160 + 15;
    DEV_USART2*   = 160 + 17;
    DEV_USART3*   = 160 + 18;
    DEV_UART4*    = 160 + 19;
    DEV_UART5*    = 160 + 20;
    DEV_I2C1*     = 160 + 21;
    DEV_I2C2*     = 160 + 22;
    DEV_I3C1*     = 160 + 23;
    DEV_USART6*   = 160 + 25;
    DEV_USART10*  = 160 + 26;
    DEV_USART11*  = 160 + 27;
    DEV_UART7*    = 160 + 30;
    DEV_UART8*    = 160 + 31;

    (* RCC_APB1HENR, RCC_APB1HLPENR, RCC_APB1HRSTR *)
    DEV_UART9*    = 192 + 0;
    DEV_UART12*   = 192 + 1;

    (* RCC_APB2ENR, RCC_APB2LPENR, RCC_APB2RSTR *)
    DEV_TIM1*     = 224 + 11;
    DEV_SPI1*     = 224 + 12;
    DEV_TIM8*     = 224 + 13;
    DEV_USART1*   = 224 + 14;
    DEV_TIM15*    = 224 + 16;
    DEV_TIM16*    = 224 + 17;
    DEV_TIM17*    = 224 + 18;
    DEV_SPI4*     = 224 + 19;
    DEV_SPI6*     = 224 + 20;

    (* RCC_APB3ENR, RCC_APB3LPENR, RCC_APB3RSTR *)
    DEV_SBS*      = 256 + 1;
    DEV_SPI5*     = 256 + 5;
    DEV_LPUART1*  = 256 + 6;
    DEV_I2C3*     = 256 + 7;
    DEV_I2C4*     = 256 + 8;
    DEV_I3C2*     = 256 + 9;
    DEV_LPTIM1*   = 256 + 11;
    DEV_LPTIM3*   = 256 + 12;
    DEV_LPTIM4*   = 256 + 13;
    DEV_LPTIM5*   = 256 + 14;
    DEV_LPTIM6*   = 256 + 15;


(* == PPB: private peripheral bus == *)

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
    IRQ_PVD_AVD*        = 1;
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
    IRQ_GPDMA1_CH0*     = 27;
    IRQ_GPDMA1_CH1*     = 28;
    IRQ_GPDMA1_CH2*     = 29;
    IRQ_GPDMA1_CH3*     = 30;
    IRQ_GPDMA1_CH4*     = 31;
    IRQ_GPDMA1_CH5*     = 32;
    IRQ_GPDMA1_CH6*     = 33;
    IRQ_GPDMA1_CH7*     = 34;
    IRQ_IWDG*           = 35;
    IRQ_SAES*           = 36;
    IRQ_ADC1*           = 37;
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
    IRQ_I2C1_EV*        = 51;
    IRQ_I2C1_ER*        = 52;
    IRQ_I2C2_EV*        = 53;
    IRQ_I2C2_ER*        = 54;
    IRQ_SPI1*           = 55;
    IRQ_SPI2*           = 56;
    IRQ_SPI3*           = 57;
    IRQ_USART1*         = 58;
    IRQ_USART2*         = 59;
    IRQ_USART3*         = 60;
    IRQ_UART4*          = 61;
    IRQ_UART5*          = 62;
    IRQ_LPUART1*        = 63;
    IRQ_LPTIM1*         = 64;
    IRQ_TIM8_0*         = 65; (* TIM8_BRK, TIM8_TERR, TIM8_IERR *)
    IRQ_TIM8_UP*        = 66;
    IRQ_TIM8_1*         = 67; (* TIM8_TRG_COM, TIM8_DIR, TIM8_IDX *)
    IRQ_TIM8_CC*        = 68;
    IRQ_ADC2*           = 69;
    IRQ_LPTIM2*         = 70;
    IRQ_TIM15*          = 71;
    IRQ_TIM16*          = 72;
    IRQ_TIM17*          = 73;
    IRQ_USB*            = 74;
    IRQ_CRS*            = 75;
    IRQ_UCPD1*          = 76;
    IRQ_FMC*            = 77;
    IRQ_OCTOSPI1*       = 78;
    IRQ_SDMMC1*         = 79;
    IRQ_I2C3_EV*        = 80;
    IRQ_I2C3_ER*        = 81;
    IRQ_SPI4*           = 82;
    IRQ_SPI5*           = 83;
    IRQ_SPI6*           = 84;
    IRQ_USART6*         = 85;
    IRQ_USART10*        = 86;
    IRQ_USART11*        = 87;
    IRQ_SAI1*           = 88;
    IRQ_SAI2*           = 89;
    IRQ_GPDMA2_CH0*     = 90;
    IRQ_GPDMA2_CH1*     = 91;
    IRQ_GPDMA2_CH2*     = 92;
    IRQ_GPDMA2_CH3*     = 93;
    IRQ_GPDMA2_CH4*     = 94;
    IRQ_GPDMA2_CH5*     = 95;
    IRQ_GPDMA2_CH6*     = 96;
    IRQ_GPDMA2_CH7*     = 97;
    IRQ_UART7*          = 98;
    IRQ_UART8*          = 99;
    IRQ_UART9*          = 100;
    IRQ_UART12*         = 101;
    IRQ_SDMMC2*         = 102;
    IRQ_FPU*            = 103;
    IRQ_ICACHE*         = 104;
    IRQ_DCACHE*         = 105;
    IRQ_ETH*            = 106;
    IRQ_ETH_WKUP*       = 107;
    IRQ_DCMI_PSSI*      = 108;
    IRQ_FDCAN2_0*       = 109;
    IRQ_FDCAN2_1*       = 110;
    IRQ_CORDIC*         = 111;
    IRQ_FMAC*           = 112;
    IRQ_DTS*            = 113;
    IRQ_RNG*            = 114;
    IRQ_OTFDEC1*        = 115;
    IRQ_AES*            = 116;
    IRQ_HASH*           = 117;
    IRQ_PKA*            = 118;
    IRQ_CEC*            = 119;
    IRQ_TIM12*          = 120;
    IRQ_TIM13*          = 121;
    IRQ_TIM14*          = 122;
    IRQ_I3C1_EV*        = 123;
    IRQ_I3C1_ER*        = 124;
    IRQ_I3C2_EV*        = 125;
    IRQ_I3C2_ER*        = 126;
    IRQ_LPTIM3*         = 127;
    IRQ_LPTIM4*         = 128;
    IRQ_LPTIM5*         = 129;
    IRQ_LPTIM6*         = 130;

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
    VectorTableSize*        = 548; (* bytes: 16 sys exceptions + 121 interrupts, one word each *)
    EXC_Reset_Offset*       = 004H;
    EXC_NMI_Offset*         = 008H;
    EXC_HardFault_Offset*   = 00CH;
    EXC_BusFault_Offset*    = 014H;
    EXC_UsageFault_Offset*  = 018H;
    EXC_SVC_Offset*         = 02CH;
    EXC_DebugMon_Offset*    = 030H;
    EXC_PendSV_Offset*      = 038H;
    EXC_SysTick_Offset*     = 03CH;
    EXC_IRQ0_Offset*        = 040H;

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


    (* -- sw interrupt generation -- *)
    PPB_STIR*         = PPB_BASE + 0EF00H;

(* ===== CPU registers ===== *)
    (* CONTROL special register *)
    CONTROL_SPSEL* = 1; (* enable PSP *)


(* ===== assembly instructions ===== *)

    NOP* = 046C0H;

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
