MODULE UARTdef;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  MCU-specific API definitions for UART
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    USART1* = 0;
    USART2* = 1;
    USART3* = 2;
    UART4* = 3;
    UART5* = 4;
    NumUART* = 5;

    (* functional/kernel clock values *)
    CLK_PCLK* = 0; (* reset *)
    CLK_SYSCLK* = 1;
    CLK_HSI16* = 2;
    CLK_LSE* = 3;

END UARTdef.
