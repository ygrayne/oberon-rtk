MODULE EXC;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Exceptions and IRQs.
  --
  PPB register addresses, exception numbers and vector table offsets,
  All constants are defined by the ARM architecture and identical across
  all Cortex-M33 implementations.
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumInterrupts*    = 141;
    VectorTableSize*  = 628; (* bytes: 16 sys exceptions + 141 interrupts, one word each *)

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

END EXC.
