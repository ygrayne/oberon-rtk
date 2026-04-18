MODULE CLK_SYS;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  CLK
  datasheet 8.1.6, p518
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, ACCESSCTRL_SYS;

  CONST
    PLLsys* = 0;
    PLLusb* = 1;

    (* -- CLK -- *)
    CLOCKS_BASE* = BASE.CLOCKS_BASE;

    CLK_GPOUT0_CTRL*      = CLOCKS_BASE;
    CLK_GPOUT0_DIV*       = CLOCKS_BASE + 004H;
    CLK_GPOUT1_CTRL*      = CLOCKS_BASE + 00CH;
    CLK_GPOUT1_DIV*       = CLOCKS_BASE + 010H;
    CLK_GPOUT2_CTRL*      = CLOCKS_BASE + 018H;
    CLK_GPOUT2_DIV*       = CLOCKS_BASE + 01CH;
    CLK_GPOUT3_CTRL*      = CLOCKS_BASE + 024H;
    CLK_GPOUT3_DIV*       = CLOCKS_BASE + 028H;
      CLK_GPOUT_Offset* = 12;
      CLK_GPOUT_CTRL_Offset* = 0;
      CLK_GPOUT_DIV_Offset* = 4;

    (* clock out sources *)
    CLK_GPOUT_PLLsys*   = 00H; (* reset value *)
    CLK_GPOUT_PLLusb*   = 03H;
    CLK_GPOUT_ROSC*     = 05H;
    CLK_GPOUT_XOSC*     = 06H;
    CLK_GPOUT_LPO*      = 07H;
    CLK_GPOUT_ClkSys*   = 08H;
    CLK_GPOUT_ClkUSB*   = 09H;
    CLK_GPOUT_ClkADC*   = 0AH;
    CLK_GPOUT_ClkRef*   = 0BH;
    CLK_GPOUT_ClkPeri*  = 0CH;
    CLK_GPOUT_ClkHSTX*  = 0DH;

    (* clock out bits *)
    CLK_GPOUT_CTRL_ENABLED*   = 28;
    CLK_GPOUT_CTRL_ENABLE*    = 11;
    CLK_GPOUT_CTRL_KILL*      = 10;
    CLK_GPOUT_CTRL_AUXSRC_1*  = 8;  (* [8:5] *)
    CLK_GPOUT_CTRL_AUXSRC_0*  = 5;
    CLK_GPOUT_DIV_INT_1*  = 31;     (* [31:16] *)
    CLK_GPOUT_DIV_INT_0*  = 16;
    CLK_GPOUT_DIV_FRAC_1* = 15;     (* [15:0] *)
    CLK_GPOUT_DIV_FRAC_0* = 0;

    (* clk_ref *)
    CLK_REF_CTRL*         = CLOCKS_BASE + 030H;
    CLK_REF_DIV*          = CLOCKS_BASE + 034H;
    CLK_REF_SELECTED*     = CLOCKS_BASE + 038H;
    (* clk_sys *)
    CLK_SYS_CTRL*         = CLOCKS_BASE + 03CH;
    CLK_SYS_DIV*          = CLOCKS_BASE + 040H;
    CLK_SYS_SELECTED*     = CLOCKS_BASE + 044H;
    (* clk_peri *)
    CLK_PERI_CTRL*        = CLOCKS_BASE + 048H;
    CLK_PERI_DIV*         = CLOCKS_BASE + 04CH;
    CLK_PERI_SELECTED*    = CLOCKS_BASE + 050H;
    (* clk_hstx *)
    CLK_HSTX_CTRL*        = CLOCKS_BASE + 054H;
    CLK_HSTX_DIV*         = CLOCKS_BASE + 058H;
    CLK_HSTX_SELECTED*    = CLOCKS_BASE + 05CH;
    (* clk_usb *)
    CLK_USB_CTRL*         = CLOCKS_BASE + 060H;
    CLK_USB_DIV*          = CLOCKS_BASE + 064H;
    CLK_USB_SELECTED*     = CLOCKS_BASE + 068H;
    (* clk_adc *)
    CLK_ADC_CTRL*         = CLOCKS_BASE + 06CH;
    CLK_ADC_DIV*          = CLOCKS_BASE + 070H;
    CLK_ADC_SELECTED*     = CLOCKS_BASE + 074H;
    (* dft *)
    DFTCLK_XOSC_CTRL*     = CLOCKS_BASE + 078H;
    DFTCLK_ROSC_CTRL*     = CLOCKS_BASE + 07CH;
    DFTCLK_LPOSC_CTRL*    = CLOCKS_BASE + 080H;
    (* resus *)
    CLK_SYS_RESUS_CTRL*   = CLOCKS_BASE + 084H;
    CLK_SYS_RESUS_STATUS* = CLOCKS_BASE + 088H;
    (* frequency counter *)
    CLK_FC0_REF_KHZ*      = CLOCKS_BASE + 08CH;
    CLK_FC0_MIN_KHZ*      = CLOCKS_BASE + 090H;
    CLK_FC0_MAX_KHZ*      = CLOCKS_BASE + 094H;
    CLK_FC0_DELAY*        = CLOCKS_BASE + 098H;
    CLK_FC0_INTERVAL*     = CLOCKS_BASE + 09CH;
    CLK_FC0_SRC*          = CLOCKS_BASE + 0A0H;
    CLK_FC0_STATUS*       = CLOCKS_BASE + 0A4H;
    CLK_FC0_RESULT*       = CLOCKS_BASE + 0A8H;
    (* clock gating, resets to all enabled *)
    CLK_WAKE_EN0*         =  CLOCKS_BASE + 0ACH;
    CLK_WAKE_EN1*         =  CLOCKS_BASE + 0B0H;
    CLK_SLEEP_EN0*        =  CLOCKS_BASE + 0B4H;
    CLK_SLEEP_EN1*        =  CLOCKS_BASE + 0B8H;
    CLK_ENABLED0*         =  CLOCKS_BASE + 0BCH;
    CLK_ENABLED1*         =  CLOCKS_BASE + 0C0H;
    (* interrupts *)
    CLK_INTR*             =  CLOCKS_BASE + 0C4H;
    CLK_INTE*             =  CLOCKS_BASE + 0C8H;
    CLK_INTF*             =  CLOCKS_BASE + 0CCH;
    CLK_INTS*             =  CLOCKS_BASE + 0D0H;

    (* bits in CLK_WAKE_EN0, CLK_SLEEP_EN0, CLK_ENABLED0 *)
    CLK_SYS_SIO*              = 31;
    CLK_SYS_SHA256*           = 30;
    CLK_SYS_PSM*              = 29;
    CLK_SYS_ROSC*             = 28;
    CLK_SYS_ROM*              = 27;
    CLK_SYS_RESETS*           = 26;
    CLK_SYS_PWM*              = 25;
    CLK_SYS_POWMAN*           = 24;
    CLK_REF_POWMAN*           = 23;
    CLK_SYS_PLL_USB*          = 22;
    CLK_SYS_PLL_SYS*          = 21;
    CLK_SYS_PIO2*             = 20;
    CLK_SYS_PIO1*             = 19;
    CLK_SYS_PIO0*             = 18;
    CLK_SYS_PADS*             = 17;
    CLK_SYS_OTP*              = 16;
    CLK_REF_OTP*              = 15;
    CLK_SYS_JTAG*             = 14;
    CLK_SYS_IO*               = 13;
    CLK_SYS_I2C1*             = 12;
    CLK_SYS_I2C0*             = 11;
    CLK_SYS_HSTX*             = 10;
    CLK_HSTX*                 = 9;
    CLK_SYS_GLITCH_DETECTOR*  = 8;
    CLK_SYS_DMA*              = 7;
    CLK_SYS_BUSFABRIC*        = 6;
    CLK_SYS_BUSTRL*           = 5;
    CLK_SYS_BOOTRAM*          = 4;
    CLK_SYS_ADC*              = 3;
    CLK_ADC_ADC*              = 2;
    CLK_SYS_ACCESSCTRL*       = 1;
    CLK_SYS_CLOCKS*           = 0;

    (* bits in CLK_WAKE_EN1, CLK_SLEEP_EN1, CLK_ENABLED1 *)
    CLK_SYS_XOSC*             = 30;
    CLK_SYS_XIP*              = 29;
    CLK_SYS_WATCHDOG*         = 28;
    CLK_USB*                  = 27;
    CLK_SYS_USBCTRL*          = 26;
    CLK_SYS_UART1*            = 25;
    CLK_PERI_UART1*           = 24;
    CLK_SYS_UART0*            = 23;
    CLK_PERI_UART0*           = 22;
    CLK_SYS_TRNG*             = 21;
    CLK_SYS_TIMER1*           = 20;
    CLK_SYS_TIMER0*           = 19;
    CLK_SYS_TICKS*            = 18;
    CLK_REF_TICKS*            = 17;
    CLK_SYS_TBMAN*            = 16;
    CLK_SYS_SYSINFO*          = 15;
    CLK_SYS_SYSCFG*           = 14;
    CLK_SYS_SRAM9*            = 13;
    CLK_SYS_SRAM8*            = 12;
    CLK_SYS_SRAM7*            = 11;
    CLK_SYS_SRAM6*            = 10;
    CLK_SYS_SRAM5*            = 9;
    CLK_SYS_SRAM4*            = 8;
    CLK_SYS_SRAM3*            = 7;
    CLK_SYS_SRAM2*            = 6;
    CLK_SYS_SRAM1*            = 5;
    CLK_SYS_SRAM0*            = 4;
    CLK_SYS_SPI1*             = 3;
    CLK_PERI_SPI1*            = 2;
    CLK_SYS_SPI0*             = 1;
    CLK_PERI_SPI0*            = 0;

    (* reset PSM *)
    CLK_PSM_reg* = RESETS_SYS.PSM_DONE;
    CLK_PSM_pos* = RESETS_SYS.PSM_CLOCKS;

    (* secure *)
    CLK_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_CLOCKS;

    (* -- PLL -- *)
    PLL_SYS_BASE* = BASE.PLL_SYS_BASE;
    PLL_USB_BASE* = BASE.PLL_USB_BASE;

    PLL_Offset* = PLL_USB_BASE - PLL_SYS_BASE;
    PLL_CS_Offset*         = 000H;
    PLL_PWR_Offset*        = 004H;
    PLL_FBDIV_INT_Offset*  = 008H;
    PLL_PRIM_Offset*       = 00CH;
    PLL_INTR_Offset*       = 010H;
    PLL_INTE_Offset*       = 014H;
    PLL_INTF_Offset*       = 018H;
    PLL_INTS_Offset*       = 01CH;

    (* resets *)
    PLL_SYS_RST_reg* = RESETS_SYS.RESETS_RESET;
    PLL_USB_RST_reg* = RESETS_SYS.RESETS_RESET;
    PLL_SYS_RST_pos* = RESETS_SYS.RESETS_PLL_SYS;
    PLL_USB_RST_pos* = RESETS_SYS.RESETS_PLL_USB;

    (* secure *)
    PLL_SYS_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_PLL_SYS;
    PLL_USB_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_PLL_USB;

    (* -- TICKS -- *)
    TICKS_BASE* = BASE.TICKS_BASE;

    TICKS_PROC0_CTRL*       = TICKS_BASE;
    TICKS_PROC0_CYCLES*     = TICKS_BASE + 004H;
    TICKS_PROC0_COUNT*      = TICKS_BASE + 008H;
    TICKS_PROC1_CTRL*       = TICKS_BASE + 00CH;
    TICKS_PROC1_CYCLES*     = TICKS_BASE + 010H;
    TICKS_PROC1_COUNT*      = TICKS_BASE + 014H;
    TICKS_TIMER0_CTRL*      = TICKS_BASE + 018H;
    TICKS_TIMER0_CYCLES*    = TICKS_BASE + 01CH;
    TICKS_TIMER0_COUNT*     = TICKS_BASE + 020H;
    TICKS_TIMER1_CTRL*      = TICKS_BASE + 024H;
    TICKS_TIMER1_CYCLES*    = TICKS_BASE + 028H;
    TICKS_TIMER1_COUNT*     = TICKS_BASE + 02CH;
    TICKS_WATCHDOG_CTRL*    = TICKS_BASE + 030H;
    TICKS_WATCHDOG_CYCLES*  = TICKS_BASE + 034H;
    TICKS_WATCHDOG_COUNT*   = TICKS_BASE + 038H;

    (* secure *)
    TICKS_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_TICKS;

    (* -- XOSC -- *)
    XOSC_BASE* = BASE.XOSC_BASE;

    XOSC_CTRL*    = XOSC_BASE;
    XOSC_STATUS*  = XOSC_BASE + 004H;
    XOSC_DORMANT* = XOSC_BASE + 008H;
    XOSC_STARTUP* = XOSC_BASE + 00CH;
    XOSC_COUNT*   = XOSC_BASE + 010H;

    (* reset PSM *)
    XOSC_PSM_reg* = RESETS_SYS.PSM_DONE;
    XOSC_PSM_pos* = RESETS_SYS.PSM_XOSC;

    (* secure *)
    XOSC_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_XOSC;

    (* -- ROSC -- *)
    ROSC_BASE* = BASE.ROSC_BASE;

    ROSC_CTRL*      = ROSC_BASE;
    ROSC_FREQA*     = ROSC_BASE + 004H;
    ROSC_FREQB*     = ROSC_BASE + 008H;
    ROSC_RANDOM*    = ROSC_BASE + 00CH;
    ROSC_DORMANT*   = ROSC_BASE + 010H;
    ROSC_DIV*       = ROSC_BASE + 014H;
    ROSC_PHASE*     = ROSC_BASE + 018H;
    ROSC_STATUS*    = ROSC_BASE + 01CH;
    ROSC_RANDOMBIT* = ROSC_BASE + 020H;
    ROSC_COUNT*     = ROSC_BASE + 024H;

    (* reset PSM *)
    ROSC_PSM_reg* = RESETS_SYS.PSM_DONE;
    ROSC_PSM_pos* = RESETS_SYS.PSM_ROSC;

    (* secure *)
    ROSC_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_ROSC;

END CLK_SYS.
