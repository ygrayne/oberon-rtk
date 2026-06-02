MODULE UART_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  UART
  datasheet 4.2.8, p427
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, EXC;

  CONST
    UART0* = 0;
    UART1* = 1;

    UART_all* = {0, 1};
    NumUART* = 2;

    UART0_BASE* = BASE.UART0_BASE;
    UART1_BASE* = BASE.UART1_BASE;

    UART_Offset*        = UART1_BASE - UART0_BASE;
    UART_DR_Offset*     = 0000H;
    UART_RSR_Offset*    = 0004H;
    UART_FR_Offset*     = 0018H;
    UART_ILPR_Offset*   = 0020H;
    UART_IBRD_Offset*   = 0024H;
    UART_FBRD_Offset*   = 0028H;
    UART_LCR_H_Offset*  = 002CH;
    UART_CR_Offset*     = 0030H;
    UART_IFLS_Offset*   = 0034H;
    UART_IMSC_Offset*   = 0038H;
    UART_RIS_Offset*    = 003CH;
    UART_MIS_Offset*    = 0040H;
    UART_ICR_Offset*    = 0044H;
    UART_DMACR_Offset*  = 0048H;


    (* reset *)
    UART_RST_reg* = RESETS_SYS.RESETS_RESET;
    UART0_RST_pos* = RESETS_SYS.RESETS_UART0;
    UART1_RST_pos* = RESETS_SYS.RESETS_UART1;

    (* irq *)
    UART0_IRQ_no*  = EXC.IRQ_UART0;

END UART_DEV.
