MODULE RESETS_SYS;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  RESETS
  datasheet 7.5.3, p494
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, ACCESSCTRL_SYS;

  CONST
    (* -- RESETS -- *)
    RESETS_BASE* = BASE.RESETS_BASE;

    RESETS_RESET*       = RESETS_BASE;
    RESETS_WDSEL*       = RESETS_BASE + 004H;
    RESETS_DONE*        = RESETS_BASE + 008H;

    (* bits in all RESETS_* registers *)
    RESETS_USBCTRL*     = 28;
    RESETS_UART1*       = 27;
    RESETS_UART0*       = 26;
    RESETS_TRNG*        = 25;
    RESETS_TIMER1*      = 24;
    RESETS_TIMER0*      = 23;
    RESETS_TBMAN*       = 22;
    RESETS_SYSINFO*     = 21;
    RESETS_SYSCFG*      = 20;
    RESETS_SPI1*        = 19;
    RESETS_SPI0*        = 18;
    RESETS_SHA256*      = 17;
    RESETS_PWM*         = 16;
    RESETS_PLL_USB*     = 15;
    RESETS_PLL_SYS*     = 14;
    RESETS_PIO2*        = 13;
    RESETS_PIO1*        = 12;
    RESETS_PIO0*        = 11;
    RESETS_PADS_QSPI*   = 10;
    RESETS_PADS_BANK0*  = 9;
    RESETS_JTAG*        = 8;
    RESETS_IO_QSPI*     = 7;
    RESETS_IO_BANK0*    = 6;
    RESETS_I2C1*        = 5;
    RESETS_I2C0*        = 4;
    RESETS_HSTX*        = 3;
    RESETS_DMA*         = 2;
    RESETS_BUSCTRL*     = 1;
    RESETS_ADC*         = 0;

    RESETS_ALL*         = {0 .. 28};

    (* -- PSM -- *)
    PSM_BASE* = BASE.PSM_BASE;

    PSM_FRCE_ON*              = PSM_BASE;
    PSM_FRCE_OFF*             = PSM_BASE + 004H;
    PSM_WDSEL*                = PSM_BASE + 008H;
    PSM_DONE*                 = PSM_BASE + 00CH;

    (* bits in all PSM_* registers *)
    PSM_PROC1*        = 24;
    PSM_PROC0*        = 23;
    PSM_ACCESSCTRL*   = 22;
    PSM_SIO*          = 21;
    PSM_XIP*          = 20;
    PSM_SRAM9*        = 19;
    PSM_SRAM8*        = 18;
    PSM_SRAM7*        = 17;
    PSM_SRAM6*        = 16;
    PSM_SRAM5*        = 15;
    PSM_SRAM4*        = 14;
    PSM_SRAM3*        = 13;
    PSM_SRAM2*        = 12;
    PSM_SRAM1*        = 11;
    PSM_SRAM0*        = 10;
    PSM_BOOTRAM*      = 9;
    PSM_ROM*          = 8;
    PSM_BUSFABRIC*    = 7;
    PSM_PSM_READY*    = 6;
    PSM_CLOCKS*       = 5;
    PSM_RESETS*       = 4;
    PSM_XOSC*         = 3;
    PSM_ROSC*         = 2;
    PSM_OTP*          = 1;
    PSM_COLD*         = 0;

    PSM_ALL*          = {0 .. 24};
    PSM_RESET*        = PSM_ALL - {PSM_COLD, PSM_OTP, PSM_ROSC, PSM_XOSC};

    (* reset PSM *)
    RESETS_PSM_reg* = PSM_DONE;
    RESETS_PSM_pos* = PSM_RESETS;

    (* secure *)
    RESETS_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_RESETS;

END RESETS_SYS.
