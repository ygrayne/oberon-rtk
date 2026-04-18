MODULE UART_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  UART
  datasheet 12.1.8, p958
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, EXC, RESETS_SYS, ACCESSCTRL_SYS;

  CONST
    UART0* = 0;
    UART1* = 1;

    UART_all* = {0, 1};
    NumUART* = 2;


    UART0_BASE* = BASE.UART0_BASE;
    UART1_BASE* = BASE.UART1_BASE;

    UART_Offset*        = UART1_BASE - UART0_BASE;
    UART_DR_Offset*     = 000H;
    UART_RSR_Offset*    = 004H;
    UART_FR_Offset*     = 018H;
    UART_ILPR_Offset*   = 020H;
    UART_IBRD_Offset*   = 024H;
    UART_FBRD_Offset*   = 028H;
    UART_LCR_H_Offset*  = 02CH;
    UART_CR_Offset*     = 030H;
    UART_IFLS_Offset*   = 034H;
    UART_IMSC_Offset*   = 038H;
    UART_RIS_Offset*    = 03CH;
    UART_MIS_Offset*    = 040H;
    UART_ICR_Offset*    = 044H;
    UART_DMACR_Offset*  = 048H;

    (* reset *)
    UART_RST_reg* = RESETS_SYS.RESETS_RESET;
    UART0_RST_pos* = RESETS_SYS.RESETS_UART0;
    UART1_RST_pos* = RESETS_SYS.RESETS_UART1;

    (* secure *)
    UART0_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_UART0;
    UART1_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_UART1;

    (* irq *)
    UART0_IRQ_no*  = EXC.IRQ_UART0;

END UART_DEV.
