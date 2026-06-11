MODULE TIM_DEV;
(**
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RCC_SYS, GTZC_SYS;

  CONST
    (* advanced *)
    TIM1*  = 1;
    TIM8*  = 8;
    (* general purpose 32 bit *)
    TIM2*  = 2;
    TIM3*  = 3;
    TIM4*  = 4;
    TIM5*  = 5;
    (* basic *)
    TIM6*  = 6;
    TIM7*  = 7;
    (* general purpose 16 bit *)
    TIM12* = 12;
    TIM13* = 13;
    TIM14* = 14;
    (* general purpose 16 bit *)
    TIM15* = 15;
    TIM16* = 16;
    TIM17* = 17;

    TIM_all*   = {1 .. 8, 12 .. 17};
    TIM_adv*   = {1, 8};
    TIM_gp0*   = {2 .. 5};
    TIM_basic* = {6, 7};
    TIM_gp2*   = {12 .. 14};
    TIM_gp1*   = {15 .. 17};

    (* base addresses *)
    TIM1_BASE*  = BASE.TIM1_BASE;
    TIM2_BASE*  = BASE.TIM2_BASE;
    TIM3_BASE*  = BASE.TIM3_BASE;
    TIM4_BASE*  = BASE.TIM4_BASE;
    TIM5_BASE*  = BASE.TIM5_BASE;
    TIM6_BASE*  = BASE.TIM6_BASE;
    TIM7_BASE*  = BASE.TIM7_BASE;
    TIM8_BASE*  = BASE.TIM8_BASE;
    TIM12_BASE* = BASE.TIM12_BASE;
    TIM13_BASE* = BASE.TIM13_BASE;
    TIM14_BASE* = BASE.TIM14_BASE;
    TIM15_BASE* = BASE.TIM15_BASE;
    TIM16_BASE* = BASE.TIM16_BASE;
    TIM17_BASE* = BASE.TIM17_BASE;

    (* register offsets *)
    TIM_Offset* = 0400H;
    TIM_CR1_Offset*    = 0000H;
    TIM_CR2_Offset*    = 0004H;
    TIM_SMCR_Offset*   = 0008H;
    TIM_DIER_Offset*   = 000CH;
    TIM_SR_Offset*     = 0010H;
    TIM_EGR_Offset*    = 0014H;
    TIM_CCMR1_Offset*  = 0018H;
    TIM_CCMR2_Offset*  = 001CH;
    TIM_CCER_Offset*   = 0020H;
    TIM_CNT_Offset*    = 0024H;
    TIM_PSC_Offset*    = 0028H;
    TIM_ARR_Offset*    = 002CH;
    TIM_RCR_Offset*    = 0030H;
    TIM_CCR1_Offset*   = 0034H;
    TIM_CCR2_Offset*   = 0038H;
    TIM_CCR3_Offset*   = 003CH;
    TIM_CCR4_Offset*   = 0040H;
    TIM_BDTR_Offset*   = 0044H;
    TIM_CCR5_Offset*   = 0048H;
    TIM_CCR6_Offset*   = 004CH;
    TIM_CCMR3_Offset*  = 0050H;
    TIM_DTR2_Offset*   = 0054H;
    TIM_ECR_Offset*    = 0058H;
    TIM_TISEL_Offset*  = 005CH;
    TIM_AF1_Offset*    = 0060H;
    TIM_AF2_Offset*    = 0064H;
    TIM_DCR_Offset*    = 03DCH;
    TIM_DMAR_Offset*   = 03E0H;

    (* RCC: bus clock *)
    TIM1_BC_reg*  = RCC_SYS.RCC_APB2ENR;
    TIM2_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    TIM3_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    TIM4_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    TIM5_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    TIM6_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    TIM7_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    TIM8_BC_reg*  = RCC_SYS.RCC_APB2ENR;
    TIM12_BC_reg* = RCC_SYS.RCC_APB1LENR;
    TIM13_BC_reg* = RCC_SYS.RCC_APB1LENR;
    TIM14_BC_reg* = RCC_SYS.RCC_APB1LENR;
    TIM15_BC_reg* = RCC_SYS.RCC_APB2ENR;
    TIM16_BC_reg* = RCC_SYS.RCC_APB2ENR;
    TIM17_BC_reg* = RCC_SYS.RCC_APB2ENR;

    TIM1_BC_pos*  = 11;
    TIM2_BC_pos*  = 0;
    TIM3_BC_pos*  = 1;
    TIM4_BC_pos*  = 2;
    TIM5_BC_pos*  = 3;
    TIM6_BC_pos*  = 4;
    TIM7_BC_pos*  = 5;
    TIM8_BC_pos*  = 13;
    TIM12_BC_pos* = 6;
    TIM13_BC_pos* = 7;
    TIM14_BC_pos* = 8;
    TIM15_BC_pos* = 16;
    TIM16_BC_pos* = 17;
    TIM17_BC_pos* = 18;

    (* RCC: reset *)
    TIM1_RST_reg*  = RCC_SYS.RCC_APB2RSTR;
    TIM2_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    TIM3_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    TIM4_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    TIM5_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    TIM6_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    TIM7_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    TIM8_RST_reg*  = RCC_SYS.RCC_APB2RSTR;
    TIM12_RST_reg* = RCC_SYS.RCC_APB1LRSTR;
    TIM13_RST_reg* = RCC_SYS.RCC_APB1LRSTR;
    TIM14_RST_reg* = RCC_SYS.RCC_APB1LRSTR;
    TIM15_RST_reg* = RCC_SYS.RCC_APB2RSTR;
    TIM16_RST_reg* = RCC_SYS.RCC_APB2RSTR;
    TIM17_RST_reg* = RCC_SYS.RCC_APB2RSTR;

    TIM1_RST_pos*  = 11;
    TIM2_RST_pos*  = 0;
    TIM3_RST_pos*  = 1;
    TIM4_RST_pos*  = 2;
    TIM5_RST_pos*  = 3;
    TIM6_RST_pos*  = 4;
    TIM7_RST_pos*  = 5;
    TIM8_RST_pos*  = 13;
    TIM12_RST_pos* = 6;
    TIM13_RST_pos* = 7;
    TIM14_RST_pos* = 8;
    TIM15_RST_pos* = 16;
    TIM16_RST_pos* = 17;
    TIM17_RST_pos* = 18;

    (* RCC: sleep mode clock *)
    TIM1_SM_reg*  = RCC_SYS.RCC_APB2LPENR;
    TIM2_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    TIM3_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    TIM4_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    TIM5_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    TIM6_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    TIM7_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    TIM8_SM_reg*  = RCC_SYS.RCC_APB2LPENR;
    TIM12_SM_reg* = RCC_SYS.RCC_APB1LLPENR;
    TIM13_SM_reg* = RCC_SYS.RCC_APB1LLPENR;
    TIM14_SM_reg* = RCC_SYS.RCC_APB1LLPENR;
    TIM15_SM_reg* = RCC_SYS.RCC_APB2LPENR;
    TIM16_SM_reg* = RCC_SYS.RCC_APB2LPENR;
    TIM17_SM_reg* = RCC_SYS.RCC_APB2LPENR;

    TIM1_SM_pos*  = 11;
    TIM2_SM_pos*  = 0;
    TIM3_SM_pos*  = 1;
    TIM4_SM_pos*  = 2;
    TIM5_SM_pos*  = 3;
    TIM6_SM_pos*  = 4;
    TIM7_SM_pos*  = 5;
    TIM8_SM_pos*  = 13;
    TIM12_SM_pos* = 6;
    TIM13_SM_pos* = 7;
    TIM14_SM_pos* = 8;
    TIM15_SM_pos* = 16;
    TIM16_SM_pos* = 17;
    TIM17_SM_pos* = 18;

    (* RCC: functional clock *)
    (* no functional clock selection, runs off bus clock *)

    (* GTZC: Secure *)
    TIM1_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR2_Offset;
    TIM2_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM3_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM4_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM5_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM6_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM7_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM8_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR2_Offset;
    TIM12_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM13_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM14_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    TIM15_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR2_Offset;
    TIM16_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR2_Offset;
    TIM17_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR2_Offset;

    TIM1_SEC_pos*  = 8;
    TIM2_SEC_pos*  = 0;
    TIM3_SEC_pos*  = 1;
    TIM4_SEC_pos*  = 2;
    TIM5_SEC_pos*  = 3;
    TIM6_SEC_pos*  = 4;
    TIM7_SEC_pos*  = 5;
    TIM8_SEC_pos*  = 10;
    TIM12_SEC_pos* = 6;
    TIM13_SEC_pos* = 7;
    TIM14_SEC_pos* = 8;
    TIM15_SEC_pos* = 12;
    TIM16_SEC_pos* = 13;
    TIM17_SEC_pos* = 14;

END TIM_DEV.
