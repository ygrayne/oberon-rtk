MODULE DEV2;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Definitions for IO devices
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT MCU, DEV0;

  CONST

  (* == USART, UART ==*)

    (* APB1 *)
    USART2_BASE*  = MCU.USART2_BASE;
    USART3_BASE*  = MCU.USART3_BASE;
    UART4_BASE*   = MCU.UART4_BASE;
    UART5_BASE*   = MCU.UART5_BASE;

    (* APB2 *)
    USART1_BASE*  = MCU.USART1_BASE;

    (* -- UART -- *)
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

    (* -- RCC -- *)
    (* bus clock enable *)
    USART1_BC_reg* = DEV0.RCC_APB2ENR;
    USART2_BC_reg* = DEV0.RCC_APB1ENR1;
    USART3_BC_reg* = DEV0.RCC_APB1ENR1;
    UART4_BC_reg* = DEV0.RCC_APB1ENR1;
    UART5_BC_reg* = DEV0.RCC_APB1ENR1;

    USART1_BC_pos* = 14;
    USART2_BC_pos* = 17;
    USART3_BC_pos* = 18;
    UART4_BC_pos* = 19;
    UART5_BC_pos* = 20;

    (* functional clock *)
    USART_FC_reg* = DEV0.RCC_CCIPR1;

    USART1_FC_pos* = 0;
    USART2_FC_pos* = 2;
    USART3_FC_pos* = 4;
    UART4_FC_pos* = 6;
    UART5_FC_pos* = 8;

    USART_FC_width* = 2;

    (* Secure *)
    USART1_SEC_reg* = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR2_Offset;
    USART2_SEC_reg* = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    USART3_SEC_reg* = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    UART4_SEC_reg* = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;
    UART5_SEC_reg* = DEV0.GTZC1_TZSC + DEV0.TZSC_SECCFGR1_Offset;

    USART1_SEC_pos* = 3;
    USART2_SEC_pos* = 9;
    USART3_SEC_pos* = 10;
    UART4_SEC_pos*  = 11;
    UART5_SEC_pos*  = 12;


(* == GPIO == *)
(* ref manual ch13, p641 *)

    GPIOA_BASE* = MCU.GPIOA_BASE;
    GPIOB_BASE* = MCU.GPIOB_BASE;
    GPIOC_BASE* = MCU.GPIOC_BASE;
    GPIOD_BASE* = MCU.GPIOD_BASE;
    GPIOE_BASE* = MCU.GPIOE_BASE;
    GPIOF_BASE* = MCU.GPIOF_BASE;
    GPIOG_BASE* = MCU.GPIOG_BASE;
    GPIOH_BASE* = MCU.GPIOH_BASE;
    GPIOI_BASE* = MCU.GPIOI_BASE;

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

    (* bus clock *)
    GPIO_BC_EN* = DEV0.RCC_AHB2ENR1;
    (* pos = portNo *)

    (* Secure *)
    (* own pin SECCFGR register *)


(* == SYSTICK == *)
    (* functional clock *)
    SYSTICK_FC_reg* = DEV0.RCC_CCIPR1;
    SYSTICK_FC_pos* = 22;
    SYSTICK_FC_width* = 2;

END DEV2.
