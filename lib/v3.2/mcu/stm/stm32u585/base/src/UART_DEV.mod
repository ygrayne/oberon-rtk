MODULE UART_DEV;
(**
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RCC_SYS, GTZC_SYS;

  CONST
    (* device handles *)
    USART1* = 1;
    USART2* = 2;
    USART3* = 3;
    UART4*  = 4;
    UART5*  = 5;

    UART_all* = {1 .. 5};
    UART_full* = {1 .. 3};
    UART_basic* = {4 .. 5};

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
    (* APB1 *)
    USART2_BASE*  = BASE.USART2_BASE;
    USART3_BASE*  = BASE.USART3_BASE;
    UART4_BASE*   = BASE.UART4_BASE;
    UART5_BASE*   = BASE.UART5_BASE;
    (* APB2 *)
    USART1_BASE*  = BASE.USART1_BASE;

    (* RCC: bus clock BC *)
    USART1_BC_reg* = RCC_SYS.RCC_APB2ENR;
    USART2_BC_reg* = RCC_SYS.RCC_APB1ENR1;
    USART3_BC_reg* = RCC_SYS.RCC_APB1ENR1;
    UART4_BC_reg* = RCC_SYS.RCC_APB1ENR1;
    UART5_BC_reg* = RCC_SYS.RCC_APB1ENR1;

    USART1_BC_pos* = 14;
    USART2_BC_pos* = 17;
    USART3_BC_pos* = 18;
    UART4_BC_pos*  = 19;
    UART5_BC_pos*  = 20;

    (* RCC: reset *)
    USART1_RST_reg* = RCC_SYS.RCC_APB2RSTR;
    USART2_RST_reg* = RCC_SYS.RCC_APB1RSTR1;
    USART3_RST_reg* = RCC_SYS.RCC_APB1RSTR1;
    UART4_RST_reg*  = RCC_SYS.RCC_APB1RSTR1;
    UART5_RST_reg*  = RCC_SYS.RCC_APB1RSTR1;

    USART1_RST_pos* = 14;
    USART2_RST_pos* = 17;
    USART3_RST_pos* = 18;
    UART4_RST_pos*  = 19;
    UART5_RST_pos*  = 20;

    (* RCC: sleep mode clock *)
    USART1_SM_reg* = RCC_SYS.RCC_APB2SMENR;
    USART2_SM_reg* = RCC_SYS.RCC_APB1SMENR1;
    USART3_SM_reg* = RCC_SYS.RCC_APB1SMENR1;
    UART4_SM_reg*  = RCC_SYS.RCC_APB1SMENR1;
    UART5_SM_reg*  = RCC_SYS.RCC_APB1SMENR1;

    USART1_SM_pos* = 14;
    USART2_SM_pos* = 17;
    USART3_SM_pos* = 18;
    UART4_SM_pos*  = 19;
    UART5_SM_pos*  = 20;

    (* RCC: functional clock FC *)
    UART_FC_reg* = RCC_SYS.RCC_CCIPR1;

    USART1_FC_pos* = 0;
    USART2_FC_pos* = 2;
    USART3_FC_pos* = 4;
    UART4_FC_pos*  = 6;
    UART5_FC_pos*  = 8;

    UART_FC_width* = 2;

    (* GTZC: Secure *)
    USART1_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR2_Offset;
    USART2_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    USART3_SEC_reg* = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART4_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;
    UART5_SEC_reg*  = GTZC_SYS.GTZC1_TZSC + GTZC_SYS.TZSC_SECCFGR1_Offset;

    USART1_SEC_pos* = 3;
    USART2_SEC_pos* = 9;
    USART3_SEC_pos* = 10;
    UART4_SEC_pos*  = 11;
    UART5_SEC_pos*  = 12;

END UART_DEV.
