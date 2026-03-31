MODULE DEV3;

  IMPORT MCU, DEV0;

  CONST

  (* == TIM == *)
    (* APB1 *)
    TIM2_BASE*      = MCU.TIM2_BASE;
    TIM3_BASE*      = MCU.TIM3_BASE;
    TIM4_BASE*      = MCU.TIM4_BASE;
    TIM5_BASE*      = MCU.TIM5_BASE;
    TIM6_BASE*      = MCU.TIM6_BASE;
    TIM7_BASE*      = MCU.TIM7_BASE;
    (* APB2 *)
    TIM1_BASE*      = MCU.TIM1_BASE;
    TIM8_BASE*      = MCU.TIM8_BASE;
    TIM15_BASE*     = MCU.TIM15_BASE;
    TIM16_BASE*     = MCU.TIM16_BASE;
    TIM17_BASE*     = MCU.TIM17_BASE;

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


    (* -- RCC -- *)
    (* bus clock enable *)
    TIM1_BC_reg*  = DEV0.RCC_APB2ENR;
    TIM2_BC_reg*  = DEV0.RCC_APB1ENR1;
    TIM3_BC_reg*  = DEV0.RCC_APB1ENR1;
    TIM4_BC_reg*  = DEV0.RCC_APB1ENR1;
    TIM5_BC_reg*  = DEV0.RCC_APB1ENR1;
    TIM6_BC_reg*  = DEV0.RCC_APB1ENR1;
    TIM7_BC_reg*  = DEV0.RCC_APB1ENR1;
    TIM8_BC_reg*  = DEV0.RCC_APB2ENR;
    TIM15_BC_reg* = DEV0.RCC_APB2ENR;
    TIM16_BC_reg* = DEV0.RCC_APB2ENR;
    TIM17_BC_reg* = DEV0.RCC_APB2ENR;

    TIM1_BC_pos*  = 0;
    TIM2_BC_pos*  = 0;
    TIM3_BC_pos*  = 1;
    TIM4_BC_pos*  = 2;
    TIM5_BC_pos*  = 3;
    TIM6_BC_pos*  = 4;
    TIM7_BC_pos*  = 5;
    TIM8_BC_pos*  = 2;
    TIM15_BC_pos* = 4;
    TIM16_BC_pos* = 5;
    TIM17_BC_pos* = 6;

    (* functional clock *)
    (* no functional clock, runs off bus clock *)

    (* Secure *)
    TIM1_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR2_Offset;
    TIM2_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    TIM3_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    TIM4_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    TIM5_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    TIM6_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    TIM7_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    TIM8_SEC_reg*   = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR2_Offset;
    TIM15_SEC_reg*  = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR2_Offset;
    TIM16_SEC_reg*  = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR2_Offset;
    TIM17_SEC_reg*  = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR2_Offset;

    TIM1_SEC_pos*   = 0;
    TIM2_SEC_pos*   = 0;
    TIM3_SEC_pos*   = 1;
    TIM4_SEC_pos*   = 2;
    TIM5_SEC_pos*   = 3;
    TIM6_SEC_pos*   = 4;
    TIM7_SEC_pos*   = 5;
    TIM8_SEC_pos*   = 2;
    TIM15_SEC_pos*  = 4;
    TIM16_SEC_pos*  = 5;
    TIM17_SEC_pos*  = 6;

END DEV3.
