MODULE RESETS_SYS;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  RESETS
  datasheet 2.14.3, p177
  datasheet 2.13.5, p171 PSM
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE;

  CONST
    (* -- RESETS -- *)
    RESETS_BASE* = BASE.RESETS_BASE;

    RESETS_RESET*       = RESETS_BASE;
    RESETS_WDSEL*       = RESETS_BASE + 004H;
    RESETS_DONE*        = RESETS_BASE + 008H;

    (* bits in all RESETS_* registers *)
    RESETS_USBCTRL*     = 24;
    RESETS_UART1*       = 23;
    RESETS_UART0*       = 22;
    RESETS_TIMER0*      = 21;
    RESETS_TBMAN*       = 20;
    RESETS_SYSINFO*     = 19;
    RESETS_SYSCFG*      = 18;
    RESETS_SPI1*        = 17;
    RESETS_SPI0*        = 16;
    RESETS_RTC*         = 15;
    RESETS_PWM*         = 14;
    RESETS_PLL_USB*     = 13;
    RESETS_PLL_SYS*     = 12;
    RESETS_PIO1*        = 11;
    RESETS_PIO0*        = 10;
    RESETS_PADS_QSPI*   = 9;
    RESETS_PADS_BANK0*  = 8;
    RESETS_JTAG*        = 7;
    RESETS_IO_QSPI*     = 6;
    RESETS_IO_BANK0*    = 5;
    RESETS_I2C1*        = 4;
    RESETS_I2C0*        = 3;
    RESETS_DMA*         = 2;
    RESETS_BUSCTRL*     = 1;
    RESETS_ADC*         = 0;

    RESETS_ALL*         = {0 .. 24};

    (* -- PSM -- *)
    PSM_BASE* = BASE.PSM_BASE;

    PSM_FRCE_ON*        = PSM_BASE;
    PSM_FRCE_OFF*       = PSM_BASE + 004H;
    PSM_WDSEL*          = PSM_BASE + 008H;
    PSM_DONE*           = PSM_BASE + 00CH;

    (* bits in all PSM_* registers *)
    PSM_PROC1*      = 16;
    PSM_PROC0*      = 15;
    PSM_SIO*        = 14;
    PSM_VREG_AND_CHIP_RESET* = 13;
    PSM_XIP*        = 12;
    PSM_SRAM5*      = 11;
    PSM_SRAM4*      = 10;
    PSM_SRAM3*      = 9;
    PSM_SRAM2*      = 8;
    PSM_SRAM1*      = 7;
    PSM_SRAM0*      = 6;
    PSM_ROM*        = 5;
    PSM_BUSFABRIC*  = 4;
    PSM_RESETS*     = 3;
    PSM_CLOCKS*     = 2;
    PSM_XOSC*       = 1;
    PSM_ROSC*       = 0;

    PSM_ALL*        = {0 .. 16};
    PSM_RESET*      = PSM_ALL - {PSM_ROSC, PSM_XOSC};

    (* reset PSM *)
    RESETS_PSM_reg* = PSM_DONE;
    RESETS_PSM_pos* = PSM_RESETS;


    (* -- VREG_AND_CHIP_RESET -- *)
    VREG_AND_CHIP_RESET_BASE = BASE.VREG_AND_CHIP_RESET_BASE;

    VREG_AND_CHIP_RESET_VREG*       = VREG_AND_CHIP_RESET_BASE;
    VREG_AND_CHIP_RESET_BOD*        = VREG_AND_CHIP_RESET_BASE + 04H;
    VREG_AND_CHIP_RESET_CHIP_RESET* = VREG_AND_CHIP_RESET_BASE + 08H;

    CHIP_RESET* = VREG_AND_CHIP_RESET_CHIP_RESET;

END RESETS_SYS.
