MODULE EXC;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Exceptions and IRQs.
  --
  MCU: STM32H573II
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumInterrupts*    = 131;
    VectorTableSize*  = 588; (* bytes: 16 sys exceptions + 131 interrupts, one word each *)

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

END EXC.
