MODULE GPIO_DEV;
(**
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RCC_SYS;

  CONST
    GPIOA_BASE* = BASE.GPIOA_BASE;
    GPIOB_BASE* = BASE.GPIOB_BASE;
    GPIOC_BASE* = BASE.GPIOC_BASE;
    GPIOD_BASE* = BASE.GPIOD_BASE;
    GPIOE_BASE* = BASE.GPIOE_BASE;
    GPIOF_BASE* = BASE.GPIOF_BASE;
    GPIOG_BASE* = BASE.GPIOG_BASE;
    GPIOH_BASE* = BASE.GPIOH_BASE;
    GPIOI_BASE* = BASE.GPIOI_BASE;

    (* port handles *)
    GPIO_PORTA* = GPIOA_BASE;
    GPIO_PORTB* = GPIOB_BASE;
    GPIO_PORTC* = GPIOC_BASE;
    GPIO_PORTD* = GPIOD_BASE;
    GPIO_PORTE* = GPIOE_BASE;
    GPIO_PORTF* = GPIOF_BASE;
    GPIO_PORTG* = GPIOG_BASE;
    GPIO_PORTH* = GPIOH_BASE;
    GPIO_PORTI* = GPIOI_BASE;


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

    (* RCC: bus clock BC *)
    GPIO_BC_reg* = RCC_SYS.RCC_AHB2ENR;
    (* pos = portNo *)

    (* RCC: reset *)
    GPIO_RST_reg* = RCC_SYS.RCC_AHB2RSTR;
    (* pos = portNo *)

    (* RCC: sleep mode clock *)
    GPIO_SM_reg* = RCC_SYS.RCC_AHB2LPENR;
    (* pos = portNo *)

    (* RCC: functional clock *)
    (* no functional clock *)

    (* Secure *)
    (* own pin SECCFGR register *)

END GPIO_DEV.
