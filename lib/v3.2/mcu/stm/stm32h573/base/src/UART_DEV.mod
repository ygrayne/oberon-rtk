MODULE UART_DEV;
(**
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RCC_SYS, GTZC_SYS;

  CONST
    (* device handles *)
    USART1*  = 1;
    USART2*  = 2;
    USART3*  = 3;
    UART4*   = 4;
    UART5*   = 5;
    USART6*  = 6;
    UART7*   = 7;
    UART8*   = 8;
    UART9*   = 9;
    USART10* = 10;
    USART11* = 11;
    UART12*  = 12;

    UART_all* = {1 .. 12};
    UART_full* = {1, 2, 3, 6, 10, 11};
    UART_basic* = {4, 5, 7, 8, 9, 12};


    (* register offsets *)
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

    (* base addresses *)
    USART1_BASE*  = BASE.USART1_BASE;
    USART2_BASE*  = BASE.USART2_BASE;
    USART3_BASE*  = BASE.USART3_BASE;
    UART4_BASE*   = BASE.UART4_BASE;
    UART5_BASE*   = BASE.UART5_BASE;
    USART6_BASE*  = BASE.USART6_BASE;
    UART7_BASE*   = BASE.UART7_BASE;
    UART8_BASE*   = BASE.UART8_BASE;
    UART9_BASE*   = BASE.UART9_BASE;
    USART10_BASE* = BASE.USART10_BASE;
    USART11_BASE* = BASE.USART11_BASE;
    UART12_BASE*  = BASE.UART12_BASE;

    (* RCC: bus clock *)
    USART1_BC_reg*  = RCC_SYS.RCC_APB2ENR;
    USART2_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    USART3_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    UART4_BC_reg*   = RCC_SYS.RCC_APB1LENR;
    UART5_BC_reg*   = RCC_SYS.RCC_APB1LENR;
    USART6_BC_reg*  = RCC_SYS.RCC_APB1LENR;
    UART7_BC_reg*   = RCC_SYS.RCC_APB1LENR;
    UART8_BC_reg*   = RCC_SYS.RCC_APB1LENR;
    UART9_BC_reg*   = RCC_SYS.RCC_APB1HENR;
    USART10_BC_reg* = RCC_SYS.RCC_APB1LENR;
    USART11_BC_reg* = RCC_SYS.RCC_APB1LENR;
    UART12_BC_reg*  = RCC_SYS.RCC_APB1HENR;

    USART1_BC_pos*  = 14;
    USART2_BC_pos*  = 17;
    USART3_BC_pos*  = 18;
    UART4_BC_pos*   = 19;
    UART5_BC_pos*   = 20;
    USART6_BC_pos*  = 25;
    UART7_BC_pos*   = 30;
    UART8_BC_pos*   = 31;
    UART9_BC_pos*   = 0;
    USART10_BC_pos* = 26;
    USART11_BC_pos* = 27;
    UART12_BC_pos*  = 1;

    (* RCC: reset *)
    USART1_RST_reg*  = RCC_SYS.RCC_APB2RSTR;
    USART2_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    USART3_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    UART4_RST_reg*   = RCC_SYS.RCC_APB1LRSTR;
    UART5_RST_reg*   = RCC_SYS.RCC_APB1LRSTR;
    USART6_RST_reg*  = RCC_SYS.RCC_APB1LRSTR;
    UART7_RST_reg*   = RCC_SYS.RCC_APB1LRSTR;
    UART8_RST_reg*   = RCC_SYS.RCC_APB1LRSTR;
    UART9_RST_reg*   = RCC_SYS.RCC_APB1HRSTR;
    USART10_RST_reg* = RCC_SYS.RCC_APB1LRSTR;
    USART11_RST_reg* = RCC_SYS.RCC_APB1LRSTR;
    UART12_RST_reg*  = RCC_SYS.RCC_APB1HRSTR;

    USART1_RST_pos*  = 14;
    USART2_RST_pos*  = 17;
    USART3_RST_pos*  = 18;
    UART4_RST_pos*   = 19;
    UART5_RST_pos*   = 20;
    USART6_RST_pos*  = 25;
    UART7_RST_pos*   = 30;
    UART8_RST_pos*   = 31;
    UART9_RST_pos*   = 0;
    USART10_RST_pos* = 26;
    USART11_RST_pos* = 27;
    UART12_RST_pos*  = 1;

    (* RCC: sleep mode clock *)
    USART1_SM_reg*  = RCC_SYS.RCC_APB2LPENR;
    USART2_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    USART3_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    UART4_SM_reg*   = RCC_SYS.RCC_APB1LLPENR;
    UART5_SM_reg*   = RCC_SYS.RCC_APB1LLPENR;
    USART6_SM_reg*  = RCC_SYS.RCC_APB1LLPENR;
    UART7_SM_reg*   = RCC_SYS.RCC_APB1LLPENR;
    UART8_SM_reg*   = RCC_SYS.RCC_APB1LLPENR;
    UART9_SM_reg*   = RCC_SYS.RCC_APB1HLPENR;
    USART10_SM_reg* = RCC_SYS.RCC_APB1LLPENR;
    USART11_SM_reg* = RCC_SYS.RCC_APB1LLPENR;
    UART12_SM_reg*  = RCC_SYS.RCC_APB1HLPENR;

    USART1_SM_pos*  = 14;
    USART2_SM_pos*  = 17;
    USART3_SM_pos*  = 18;
    UART4_SM_pos*   = 19;
    UART5_SM_pos*   = 20;
    USART6_SM_pos*  = 25;
    UART7_SM_pos*   = 30;
    UART8_SM_pos*   = 31;
    UART9_SM_pos*   = 0;
    USART10_SM_pos* = 26;
    USART11_SM_pos* = 27;
    UART12_SM_pos*  = 1;

    (* RCC: functional clock — CCIPR1 bits [14:0], 3 bits each *)
    USART1_FC_reg*  = RCC_SYS.RCC_CCIPR1;
    USART2_FC_reg*  = RCC_SYS.RCC_CCIPR1;
    USART3_FC_reg*  = RCC_SYS.RCC_CCIPR1;
    UART4_FC_reg*   = RCC_SYS.RCC_CCIPR1;
    UART5_FC_reg*   = RCC_SYS.RCC_CCIPR1;
    USART6_FC_reg*  = RCC_SYS.RCC_CCIPR1;
    UART7_FC_reg*   = RCC_SYS.RCC_CCIPR1;
    UART8_FC_reg*   = RCC_SYS.RCC_CCIPR1;
    UART9_FC_reg*   = RCC_SYS.RCC_CCIPR1;
    USART10_FC_reg* = RCC_SYS.RCC_CCIPR1;
    USART11_FC_reg* = RCC_SYS.RCC_CCIPR2;
    UART12_FC_reg*  = RCC_SYS.RCC_CCIPR2;

    USART1_FC_pos*  = 0;
    USART2_FC_pos*  = 3;
    USART3_FC_pos*  = 6;
    UART4_FC_pos*   = 9;
    UART5_FC_pos*   = 12;
    USART6_FC_pos*  = 15;
    UART7_FC_pos*   = 18;
    UART8_FC_pos*   = 21;
    UART9_FC_pos*   = 24;
    USART10_FC_pos* = 27;
    USART11_FC_pos* = 0;
    UART12_FC_pos*  = 4;

    UART_FC_width* = 3;

    (* GTZC: Secure *)
    USART1_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR2_Offset;
    USART2_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    USART3_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART4_SEC_reg*   = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART5_SEC_reg*   = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    USART6_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART7_SEC_reg*   = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART8_SEC_reg*   = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART9_SEC_reg*   = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    USART10_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    USART11_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART12_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;

    USART1_SEC_pos*  = 11;
    USART2_SEC_pos*  = 13;
    USART3_SEC_pos*  = 14;
    UART4_SEC_pos*   = 15;
    UART5_SEC_pos*   = 16;
    USART6_SEC_pos*  = 21;
    UART7_SEC_pos*   = 26;
    UART8_SEC_pos*   = 27;
    UART9_SEC_pos*   = 28;
    USART10_SEC_pos* = 22;
    USART11_SEC_pos* = 23;
    UART12_SEC_pos*  = 29;

END UART_DEV.
