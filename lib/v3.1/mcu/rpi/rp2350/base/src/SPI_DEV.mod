MODULE SPI_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  SPI
  datasheet 12.3.5, p1046
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, ACCESSCTRL_SYS;

  CONST
    SPI0* = 0;
    SPI1* = 1;

    SPI_all* = {0, 1};

    SPI0_BASE* = BASE.SPI0_BASE;
    SPI1_BASE* = BASE.SPI1_BASE;

    SPI_Offset*       = SPI1_BASE - SPI0_BASE;
    SPI_CR0_Offset*   = 000H;
    SPI_CR1_Offset*   = 004H;
    SPI_DR_Offset*    = 008H;
    SPI_SR_Offset*    = 00CH;
    SPI_CPSR_Offset*  = 010H;
    SPI_IMSC_Offset*  = 014H;
    SPI_RIS_Offset*   = 018H;
    SPI_MIS_Offset*   = 01CH;
    SPI_ICR_Offset*   = 020H;
    SPI_DMACR_Offset* = 024H;

    (* reset *)
    SPI_RST_reg* = RESETS_SYS.RESETS_RESET;
    SPI0_RST_pos* = RESETS_SYS.RESETS_SPI0;
    SPI1_RST_pos* = RESETS_SYS.RESETS_SPI1;

    (* secure *)
    SPI0_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_SPI0;
    SPI1_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_SPI1;


END SPI_DEV.
