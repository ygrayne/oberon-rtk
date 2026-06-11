MODULE SPI_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  SPI
  datasheet 4.4.4, p516
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS;

  CONST
    SPI0* = 0;
    SPI1* = 1;

    SPI_all* = {0, 1};

    SPI0_BASE* = BASE.SPI0_BASE;
    SPI1_BASE* = BASE.SPI1_BASE;

    SPI_Offset*       = SPI1_BASE - SPI0_BASE;
    SPI_CR0_Offset*   = 0000H;
    SPI_CR1_Offset*   = 0004H;
    SPI_DR_Offset*    = 0008H;
    SPI_SR_Offset*    = 000CH;
    SPI_CPSR_Offset*  = 0010H;
    SPI_IMSC_Offset*  = 0014H;
    SPI_RIS_Offset*   = 0018H;
    SPI_MIS_Offset*   = 001CH;
    SPI_ICR_Offset*   = 0020H;
    SPI_DMACR_Offset* = 0024H;

    (* reset *)
    SPI_RST_reg* = RESETS_SYS.RESETS_RESET;
    SPI0_RST_pos* = RESETS_SYS.RESETS_SPI0;
    SPI1_RST_pos* = RESETS_SYS.RESETS_SPI1;


END SPI_DEV.
