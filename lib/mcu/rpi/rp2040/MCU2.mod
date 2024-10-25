MODULE MCU2;
(**
  Oberon RTK Framework
  --
  MCU register and memory addresses, bits, values, assembly instructions
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumCores*   = 2;
    NumUART*    = 2;
    NumSPI*     = 2;
    NumI2C*     = 2;
    NumTimers*  = 1;
    NumPIO*     = 2;
    NumPWMchan* = 8;
    NumDMAchan* = 12;
    NumGPIO*    = 30;

    (* as configured in Clocks.mod *)
    SysClkFreq*  = 125 * 1000000; (* from SYS PLL *)
    RefClkFreq*  =  48 * 1000000; (* from USB PLL *)
    PeriClkFreq* =  48 * 1000000; (* from USB PLL *)
    SysTickFreq* =   1 * 1000000; (* via clock divider in watchdog, from ref clock *)

    (* atomic register access, datasheet 2.1.2, p18
    addr + 0000H: normal read write access
    addr + 1000H: atomic XOR on write
    addr + 2000H: atomic bitmask set on write
    addr + 3000H: atomic bitmask clear on write
    *)
    AXOR* = 01000H; (* atomic XOR on write *)
    ASET* = 02000H; (* atomic bitmask set on write *)
    ACLR* = 03000H; (* atomic bitmask clear on write *)

    (* == base addresses == *)
    (* -- memory base addresses -- *)
    ROM_BASE*           = 000000000H;
    XIP_BASE*           = 010000000H;
    XIP_BASE_UNCACHED*  = 014000000H;
    SRAM_BASE*          = 020000000H;

    (* -- APB base addresses -- *)
    SYSINFO_BASE*     = 040000000H;
    SYSCFG_BASE*      = 040004000H;
    CLOCKS_BASE*      = 040008000H;
    RESETS_BASE*      = 04000C000H;
    PSM_BASE*         = 040010000H;
    IO_BANK0_BASE*    = 040014000H;
    IO_QSPI_BASE*     = 040018000H;
    PADS_BANK0_BASE*  = 04001C000H;
    PADS_QSPI_BASE*   = 040020000H;
    XOSC_BASE*        = 040024000H;
    PLL_SYS_BASE*     = 040028000H;
    PLL_USB_BASE*     = 04002C000H;
    BUSCTRL_BASE*     = 040030000H;
    UART0_BASE*       = 040034000H;
    UART1_BASE*       = 040038000H;
    SPIO_BASE*        = 04003C000H;
    SPI1_BASE*        = 040040000H;
    I2C0_BASE*        = 040044000H;
    I2C1_BASE*        = 040048000H;
    ADC_BASE*         = 04004C000H;
    PWM_BASE*         = 040050000H;
    TIMER0_BASE*      = 040054000H;
    WATCHDOG_BASE*    = 040058000H;
    RTC_BASE*         = 04005C000H;
    ROSC_BASE*        = 040060000H;
    VREG_AND_CHIP_RESET_BASE* = 040064000H;
    TBMAN_BASE*       = 04006C000H;

    (* -- AHB-lite base addresses -- *)
    DMA_BASE*             = 050000000H;
    USBCTRL_BASE*         = 050100000H;
    USBCTRL_DPRAM_BASE*   = 050100000H;
    USB_CTRL_REGS_BASE*   = 050110000H;
    PIO0_BASE*            = 050200000H;
    PIO1_BASE*            = 050300000H;
    XIP_AUX_BASE*         = 050400000H;

    (* -- core-local base address -- *)
    SIO_BASE*             = 0D0000000H;

    (* -- PPB base address -- *)
    PPB_BASE*             = 0E0000000H;

    (* == SRAM == *)
    SRAM0_BASE*           = 020000000H;
    SRAM_HALF_BASE*       = 020020000H;
    SRAM4_BASE*           = 020040000H;
    SRAM5_BASE*           = 020041000H;
    SRAM_EXT0*            = SRAM4_BASE;
    SRAM_EXT1*            = SRAM5_BASE;


  (* ====== APB: Advanced Peripheral Bus ====== *)

    (* == SYSINFO == *)
    (* datasheet 2.20.2, p303 *)
    SYSINFO_CHIP_ID*      = SYSINFO_BASE;
    SYSINFO_PLATFORM*     = SYSINFO_BASE + 004H;
    SYSINFO_GITREF*       = SYSINFO_BASE + 008H;

    (* == SYSCFG == *)
    (* datasheet 2.21.2, p304 *)
    SYSCFG_PROC0_NMI_MASK*          = SYSCFG_BASE;
    SYSCFG_PROC1_NMI_MASK*          = SYSCFG_BASE + 004H;
    SYSCFG_PROC_CONFIG*             = SYSCFG_BASE + 008H;
    SYSCFG_PROC_IN_SYNC_BYPASS*     = SYSCFG_BASE + 00CH;
    SYSCFG_PROC_IN_SYNC_BYPASS_HI*  = SYSCFG_BASE + 010H;
    SYSCFG_DBGFORCE*                = SYSCFG_BASE + 014H;
    SYSCFG_MEMPOWERDOWN*            = SYSCFG_BASE + 018H;

    (* == CLOCKS == *)
    (* datasheet 2.15.7, p195 *)
    (* clk_gpout0 - 3 *)
    CLK_GPOUT0_CTRL*      = CLOCKS_BASE;
    CLK_GPOUT0_DIV*       = CLOCKS_BASE + 004H;
    CLK_GPOUT0_SELECTED*  = CLOCKS_BASE + 008H;
    CLK_GPOUT1_CTRL*      = CLOCKS_BASE + 00CH;
    CLK_GPOUT1_DIV*       = CLOCKS_BASE + 010H;
    CLK_GPOUT1_SELECTED*  = CLOCKS_BASE + 014H;
    CLK_GPOUT2_CTRL*      = CLOCKS_BASE + 018H;
    CLK_GPOUT2_DIV*       = CLOCKS_BASE + 01CH;
    CLK_GPOUT2_SELECTED*  = CLOCKS_BASE + 020H;
    CLK_GPOUT3_CTRL*      = CLOCKS_BASE + 024H;
    CLK_GPOUT3_DIV*       = CLOCKS_BASE + 028H;
    CLK_GPOUT3_SELECTED*  = CLOCKS_BASE + 02CH;
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
    CLK_PERI_SELECTED*    = CLOCKS_BASE + 050H;
    (* clk_usb *)
    CLK_USB_CTRL*         = CLOCKS_BASE + 054H;
    CLK_USB_DIV*          = CLOCKS_BASE + 058H;
    CLK_USB_SELECTED*     = CLOCKS_BASE + 05CH;
    (* clk_adc *)
    CLK_ADC_CTRL*         = CLOCKS_BASE + 060H;
    CLK_ADC_DIV*          = CLOCKS_BASE + 064H;
    CLK_ADC_SELECTED*     = CLOCKS_BASE + 068H;
    (* clk_rtc *)
    CLK_RTC_CTRL*         = CLOCKS_BASE + 06CH;
    CLK_RTC_DIV*          = CLOCKS_BASE + 070H;
    CLK_RTC_SELECTED*     = CLOCKS_BASE + 074H;
    (* resus *)
    CLK_SYS_RESUS_CTRL*   = CLOCKS_BASE + 078H;
    CLK_SYS_RESUS_STATUS* = CLOCKS_BASE + 07CH;
    (* frequency counter *)
    CLK_FC0_REF_KHZ*      = CLOCKS_BASE + 080H;
    CLK_FC0_MIN_KHZ*      = CLOCKS_BASE + 084H;
    CLK_FC0_MAX_KHZ*      = CLOCKS_BASE + 088H;
    CLK_FC0_DELAY*        = CLOCKS_BASE + 08CH;
    CLK_FC0_INTERVAL*     = CLOCKS_BASE + 090H;
    CLK_FC0_SRC*          = CLOCKS_BASE + 094H;
    CLK_FC0_STATUS*       = CLOCKS_BASE + 098H;
    CLK_FC0_RESULT*       = CLOCKS_BASE + 09CH;
    (* clock gating, resets to all enabled *)
    CLK_WAKE_EN0*         = CLOCKS_BASE + 0A0H;
    CLK_WAKE_EN1*         = CLOCKS_BASE + 0A4H;
    CLK_SLEEP_EN0*        = CLOCKS_BASE + 0A8H;
    CLK_SLEEP_EN1*        = CLOCKS_BASE + 0ACH;
    CLK_ENABLED0*         = CLOCKS_BASE + 0B0H;
    CLK_ENABLED1*         = CLOCKS_BASE + 0B4H;
    (* interrupts *)
    CLK_INTR*             = CLOCKS_BASE + 0B8H;
    CLK_INTE*             = CLOCKS_BASE + 0BCH;
    CLK_INTF*             = CLOCKS_BASE + 0C0H;
    CLK_INTS*             = CLOCKS_BASE + 0C4H;

    (* bits in CLK_WAKE_EN0, CLK_SLEEP_EN0, CLK_ENABLED0 *)
    CLK_SYS_SRAM3*      = 31;
    CLK_SYS_SRAM2*      = 30;
    CLK_SYS_SRAM1*      = 29;
    CLK_SYS_SRAM0*      = 28;
    CLK_SYS_SPI1*       = 27;
    CLK_PERI_SPI1*      = 26;
    CLK_SYS_SPI0*       = 25;
    CLK_PERI_SPI0*      = 24;
    CLK_SYS_SIO*        = 23;
    CLK_SYS_RTC*        = 22;
    CLK_RTC_RTC*        = 21;
    CLK_SYS_ROSC*       = 20;
    CLK_SYS_ROM*        = 19;
    CLK_SYS_RESETS*     = 18;
    CLK_SYS_PWM*        = 17;
    CLK_SYS_PSM*        = 16;
    CLK_SYS_PLL_USB*    = 15;
    CLK_SYS_PLL_SYS*    = 14;
    CLK_SYS_PIO1*       = 13;
    CLK_SYS_PIO0*       = 12;
    CLK_SYS_PADS*       = 11;
    CLK_SYS_VREG_AND_CHIP_RESET*   = 10;
    CLK_SYS_JTAG*       = 9;
    CLK_SYS_IO*         = 8;
    CLK_SYS_I2C1*       = 7;
    CLK_SYS_I2C0*       = 6;
    CLK_SYS_DMA*        = 5;
    CLK_SYS_BUSFABRIC*  = 4;
    CLK_SYS_BUSCTRL*    = 3;
    CLK_SYS_ADC*        = 2;
    CLK_ADC_ADC*        = 1;
    CLK_SYS_CLOCKS*     = 0;

    (* bits in CLK_WAKE_EN1, CLK_SLEEP_EN1, CLK_ENABLED1 *)
    CLK_SYS_XOSC*       = 14;
    CLK_SYS_XIP*        = 13;
    CLK_SYS_WATCHDOG*   = 12;
    CLK_USB_USBCTRL*    = 11;
    CLK_SYS_USBCTRL*    = 10;
    CLK_SYS_UART1*      = 9;
    CLK_PERI_UART1*     = 8;
    CLK_SYS_UART0*      = 7;
    CLK_PERI_UART0*     = 6;
    CLK_SYS_TIMER*      = 5;
    CLK_SYS_TBMAN*      = 4;
    CLK_SYS_SYSINFO*    = 3;
    CLK_SYS_SYSCFG*     = 2;
    CLK_SYS_SRAM5*      = 1;
    CLK_SYS_SRAM4*      = 0;

    (* == PSM: power-on state machine == *)
    (* datasheet 2.13.5, p171 *)
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

    (* == RESETS: sub-system resets == *)
    (* datasheet 2.14.3, p177 *)
    RESETS_RESET*       = RESETS_BASE;
    RESETS_WDSEL*       = RESETS_BASE + 004H;
    RESETS_DONE*        = RESETS_BASE + 008H;

    (* bits in all RESETS_* registers *)
    RESETS_USBCTRL*     = 24;
    RESETS_UART1*       = 23;
    RESETS_UART0*       = 22;
    RESETS_TIMER0*      = 21;
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

    (* == IO_BANK0 == *)
    (* datasheet 2.19.6.1, p243 *)
    IO_BANK0_GPIO0_STATUS*   = IO_BANK0_BASE;
    IO_BANK0_GPIO0_CTRL*     = IO_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO29 *)
      (* block offset *)
      IO_BANK0_GPIO_Offset* = 8;
      (* block register offsets *)
      IO_BANK0_GPIO_STATUS_Offset*  = 0;
      IO_BANK0_GPIO_CTRL_Offset*    = 4;

    (* IO functions *)
    IO_BANK0_Fspi*    = 1;
    IO_BANK0_Fuart*   = 2;
    IO_BANK0_Fi2c*    = 3;
    IO_BANK0_Fpwm*    = 4;
    IO_BANK0_Fsio*    = 5;
    IO_BANK0_Fpio0*   = 6;
    IO_BANK0_Fpio1*   = 7;
    IO_BANK0_Fclk*    = 8;
    IO_BANK0_Fusb*    = 9;

    IO_BANK0_Functions* = {IO_BANK0_Fspi .. IO_BANK0_Fusb};

    (* raw interrupts *)
    IO_BANK0_INTR0*       = IO_BANK0_BASE + 00F0H;
    IO_BANK1_INTR0*       = IO_BANK0_BASE + 00F4H;
    IO_BANK2_INTR0*       = IO_BANK0_BASE + 00F8H;
    IO_BANK3_INTR0*       = IO_BANK0_BASE + 00FCH;
      IO_BANK0_INTR_Offset* = 4;

    (* core 0 interrupt enable *)
    IO_BANK0_PROC0_INTE0* = IO_BANK0_BASE + 0100H;
    IO_BANK0_PROC0_INTE1* = IO_BANK0_BASE + 0104H;
    IO_BANK0_PROC0_INTE2* = IO_BANK0_BASE + 0108H;
    IO_BANK0_PROC0_INTE3* = IO_BANK0_BASE + 010CH;
      IO_BANK0_PROC0_INTE_Offset* = 4;

    (* core 0 interrupt force *)
    IO_BANK0_PROC0_INTF0* = IO_BANK0_BASE + 0110H;
    IO_BANK0_PROC0_INTF1* = IO_BANK0_BASE + 0114H;
    IO_BANK0_PROC0_INTF2* = IO_BANK0_BASE + 0118H;
    IO_BANK0_PROC0_INTF3* = IO_BANK0_BASE + 011CH;
      IO_BANK0_PROC0_INTF_Offset* = 4;

    (* core 0 interrupt status *)
    IO_BANK0_PROC0_INTS0* = IO_BANK0_BASE + 0120H;
    IO_BANK0_PROC0_INTS1* = IO_BANK0_BASE + 0124H;
    IO_BANK0_PROC0_INTS2* = IO_BANK0_BASE + 0128H;
    IO_BANK0_PROC0_INTS3* = IO_BANK0_BASE + 012CH;
      IO_BANK0_PROC0_INTS_Offset* = 4;

    (* core 1 interrupt enable *)
    IO_BANK0_PROC1_INTE0* = IO_BANK0_BASE + 0130H;
    IO_BANK0_PROC1_INTE1* = IO_BANK0_BASE + 0134H;
    IO_BANK0_PROC1_INTE2* = IO_BANK0_BASE + 0138H;
    IO_BANK0_PROC1_INTE3* = IO_BANK0_BASE + 013CH;
      IO_BANK0_PROC1_INTE_Offset* = 4;

    (* core 1 interrupt force *)
    IO_BANK0_PROC1_INTF0* = IO_BANK0_BASE + 0140H;
    IO_BANK0_PROC1_INTF1* = IO_BANK0_BASE + 0144H;
    IO_BANK0_PROC1_INTF2* = IO_BANK0_BASE + 0148H;
    IO_BANK0_PROC1_INTF3* = IO_BANK0_BASE + 014CH;
      IO_BANK0_PROC1_INTF_Offset* = 4;

    (* core 1 interrupt status *)
    IO_BANK0_PROC1_INTS0* = IO_BANK0_BASE + 0150H;
    IO_BANK0_PROC1_INTS1* = IO_BANK0_BASE + 0154H;
    IO_BANK0_PROC1_INTS2* = IO_BANK0_BASE + 0158H;
    IO_BANK0_PROC1_INTS3* = IO_BANK0_BASE + 015CH;
      IO_BANK0_PROC1_INTS_Offset* = 4;

    (* dormant_wake interrupt enable *)
    IO_BANK0_DORMANT_WAKE_INTE0*  = IO_BANK0_BASE + 0160H;
    IO_BANK0_DORMANT_WAKE_INTE1*  = IO_BANK0_BASE + 0164H;
    IO_BANK0_DORMANT_WAKE_INTE2*  = IO_BANK0_BASE + 0168H;
    IO_BANK0_DORMANT_WAKE_INTE3*  = IO_BANK0_BASE + 016CH;
      IO_BANK0_DORMANT_WAKE_INTE_Offset* = 4;

    (* dormant_wake interrupt force *)
    IO_BANK0_DORMANT_WAKE_INTF0*  = IO_BANK0_BASE + 0170H;
    IO_BANK0_DORMANT_WAKE_INTF1*  = IO_BANK0_BASE + 0174H;
    IO_BANK0_DORMANT_WAKE_INTF2*  = IO_BANK0_BASE + 0178H;
    IO_BANK0_DORMANT_WAKE_INTF3*  = IO_BANK0_BASE + 017CH;
      IO_BANK0_DORMANT_WAKE_INTF_Offset* = 4;

    (* dormant_wake interrupt status *)
    IO_BANK0_DORMANT_WAKE_INTS0*  = IO_BANK0_BASE + 0180H;
    IO_BANK0_DORMANT_WAKE_INTS1*  = IO_BANK0_BASE + 0184H;
    IO_BANK0_DORMANT_WAKE_INTS2*  = IO_BANK0_BASE + 0188H;
    IO_BANK0_DORMANT_WAKE_INTS3*  = IO_BANK0_BASE + 018CH;
      IO_BANK0_DORMANT_WAKE_INTS_Offset* = 4;

    (* == IO_QSPI == *)
    (* datasheet 2.19.6.2, p287 *)
    IO_QSPI_SCLK_STATUS*  = IO_QSPI_BASE;
    IO_QSPI_SCLK_CTRL*    = IO_QSPI_BASE + 004H;
    IO_QSPI_CS_STATUS*    = IO_QSPI_BASE + 008H;
    IO_QSPI_CS_CTRL*      = IO_QSPI_BASE + 00CH;
    IO_QSPI_SD0_STATUS*   = IO_QSPI_BASE + 010H;
    IO_QSPI_SD0_CTRL*     = IO_QSPI_BASE + 014H;
    IO_QSPI_SD1_STATUS*   = IO_QSPI_BASE + 018H;
    IO_QSPI_SD1_CTRL*     = IO_QSPI_BASE + 01CH;
    IO_QSPI_SD2_STATUS*   = IO_QSPI_BASE + 020H;
    IO_QSPI_SD2_CTRL*     = IO_QSPI_BASE + 024H;
    IO_QSPI_SD3_STATUS*   = IO_QSPI_BASE + 028H;
    IO_QSPI_SD3_CTRL*     = IO_QSPI_BASE + 02CH;

    (* == PADS_BANK0 == *)
    (* datasheet 2.19.6.3, p298 *)
    PADS_BANK0_VOLTAGE_SELECT*  = PADS_BANK0_BASE;

    (* bank base & offset *)
    PADS_BANK0_GPIO0*           = PADS_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO29 *)
      PADS_BANK0_GPIO_Offset* = 4;

    PADS_BANK0_SWCLK*           = PADS_BANK0_BASE + 07CH;
    PADS_BANK0_SWD*             = PADS_BANK0_BASE + 080H;

    (* == PADS_QSPI == *)
    (* datasheet 2.19.6.4 *)
    PADS_QSPI_VOLTAGE_SELECT* = PADS_QSPI_BASE;
    PADS_QSPI_SCKL*           = PADS_QSPI_BASE + 004H;
    PADS_QSPI_SD0*            = PADS_QSPI_BASE + 008H;
    PADS_QSPI_SD1*            = PADS_QSPI_BASE + 00CH;
    PADS_QSPI_SD2*            = PADS_QSPI_BASE + 010H;
    PADS_QSPI_SD3*            = PADS_QSPI_BASE + 014H;
    PADS_QSPI_CS*             = PADS_QSPI_BASE + 018H;

    (* == XOSC == *)
    (* datasheet 2.16.7, p219 *)
    XOSC_CTRL*    = XOSC_BASE;
    XOSC_STATUS*  = XOSC_BASE + 004H;
    XOSC_DORMANT* = XOSC_BASE + 008H;
    XOSC_STARTUP* = XOSC_BASE + 00CH;
    XOSC_COUNT*   = XOSC_BASE + 01CH;

    (* == PLL_SYS == *)
    (* datasheet 2.18.4, p233 *)
    PLL_SYS_CS*         = PLL_SYS_BASE;
    PLL_SYS_PWR*        = PLL_SYS_BASE + 004H;
    PLL_SYS_FBDIV_INT*  = PLL_SYS_BASE + 008H;
    PLL_SYS_PRIM*       = PLL_SYS_BASE + 00CH;

    (* == PLL_USB == *)
    (* datasheet 2.18.4, p233 *)
    PLL_USB_CS*         = PLL_USB_BASE;
    PLL_USB_PWR*        = PLL_USB_BASE + 004H;
    PLL_USB_FBDIV_INT*  = PLL_USB_BASE + 008H;
    PLL_USB_PRIM*       = PLL_USB_BASE + 00CH;

    (* == BUSCTRL == *)
    (* datasheet 2.1.5, p19 *)
    BUSCTRL_BUS_PRIORITY*     = BUSCTRL_BASE;
    BUSCTRL_BUS_PRIORITY_ACK* = BUSCTRL_BASE + 004H;
    BUSCTRL_PERFCTR0*         = BUSCTRL_BASE + 008H;
    BUSCTRL_PERFSEL0*         = BUSCTRL_BASE + 00CH;
    BUSCTRL_PERFCTR1*         = BUSCTRL_BASE + 010H;
    BUSCTRL_PERFSEL1*         = BUSCTRL_BASE + 014H;
    BUSCTRL_PERFCTR2*         = BUSCTRL_BASE + 018H;
    BUSCTRL_PERFSEL2*         = BUSCTRL_BASE + 01CH;
    BUSCTRL_PERFCTR3*         = BUSCTRL_BASE + 020H;
    BUSCTRL_PERFSEL3*         = BUSCTRL_BASE + 024H;

    (* PERFSEL events *)
    BUSCTRL_PERFSEL_APB_CONT*       = 000H;
    BUSCTRL_PERFSEL_APB*            = 001H;
    BUSCTRL_PERFSEL_FASTPERI_CONT*  = 002H;
    BUSCTRL_PERFSEL_FASTPERI*       = 003H;
    BUSCTRL_PERFSEL_SRAM5_CONT*     = 004H;
    BUSCTRL_PERFSEL_SRAM5*          = 005H;
    BUSCTRL_PERFSEL_SRAM4_CONT*     = 006H;
    BUSCTRL_PERFSEL_SRAM4*          = 007H;
    BUSCTRL_PERFSEL_SRAM3_CONT*     = 008H;
    BUSCTRL_PERFSEL_SRAM3*          = 009H;
    BUSCTRL_PERFSEL_SRAM2_CONT*     = 00AH;
    BUSCTRL_PERFSEL_SRAM2*          = 00BH;
    BUSCTRL_PERFSEL_SRAM1_CONT*     = 00CH;
    BUSCTRL_PERFSEL_SRAM1*          = 00DH;
    BUSCTRL_PERFSEL_SRAM0_CONT*     = 00EH;
    BUSCTRL_PERFSEL_SRAM0*          = 00FH;
    BUSCTRL_PERFSEL_XPI_CONT*       = 010H;
    BUSCTRL_PERFSEL_XPI*            = 011H;
    BUSCTRL_PERFSEL_ROM_CONT*       = 012H;
    BUSCTRL_PERFSEL_ROM*            = 013H;

    (* == UART0, UART1 == *)
    (* datasheet 4.2.8, p427 *)
    (* offsets from UART0_BASE, UART1_BASE *)
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

    (* == SPI0, SPI1 == *)
    (* datasheet 4.4.4, p516 *)
    (* offsets from SPI0_BASE, SPI1_BASE *)
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

    (* == I2C0, I2C1 == *)
    (* datasheet 4.3.17, p464 *)
    (* offsets from I2C0_BASE, I2C1_BASE *)
    I2C_CON_Offset*                 = 0000H;
    I2C_TAR_Offset*                 = 0004H;
    I2C_SAR_Offset*                 = 0008H;
    I2C_DATA_CMD_Offset*            = 0010H;
    I2C_SS_SCL_HCNT_Offset*         = 0014H;
    I2C_SS_SCL_LCNT_Offset*         = 0018H;
    I2C_FS_SCL_HCNT_Offset*         = 001CH;
    I2C_FS_SCL_LCNT_Offset*         = 0020H;
    I2C_INTR_STAT_Offset*           = 002CH;
    I2C_INTR_MASK_Offset*           = 0030H;
    I2C_RAW_INTR_STAT_Offset*       = 0034H;
    I2C_RX_TL_Offset*               = 0038H;
    I2C_TX_TL_Offset*               = 003CH;
    I2C_CLR_INTR_Offset*            = 0040H;
    I2C_CLR_RX_UNDER_Offset*        = 0044H;
    I2C_CLR_RX_OVER_Offset*         = 0048H;
    I2C_CLR_TX_OVER_Offset*         = 004CH;
    I2C_CLR_RD_REQ_Offset*          = 0050H;
    I2C_CLR_TX_ABRT_Offset*         = 0054H;
    I2C_CLR_RX_DONE_Offset*         = 0058H;
    I2C_CLR_ACTIVITY_Offset*        = 005CH;
    I2C_CLR_STOP_DET_Offset*        = 0060H;
    I2C_CLR_START_DET_Offset*       = 0064H;
    I2C_CLR_GEN_CALL_Offset*        = 0068H;
    I2C_ENABLE_Offset*              = 006CH;
    I2C_STATUS_Offset*              = 0070H;
    I2C_TXFLR_Offset*               = 0074H;
    I2C_RXFLR_Offset*               = 0078H;
    I2C_SDA_HOLD_Offset*            = 007CH;
    I2C_TX_ABRT_SOURCE_Offset*      = 0080H;
    I2C_SLV_DATA_NACK_ONLY_Offset*  = 0084H;
    I2C_DMA_CR_Offset*              = 0088H;
    I2C_DMA_TDLR_Offset*            = 008CH;
    I2C_DMA_RDLR_Offset*            = 0090H;
    I2C_SDA_SETUP_Offset*           = 0094H;
    I2C_ACK_GENERAL_CALL_Offset*    = 0098H;
    I2C_ENABLE_STATUS_Offset*       = 009CH;
    I2C_FS_SPKLEN_Offset*           = 00A0H;
    I2C_CLR_RESTART_DET_Offset*     = 00A8H;
    I2C_COMP_PARAM_1_Offset*        = 00F4H;
    I2C_COMP_VERSION_Offset*        = 00F8H;
    I2C_COMP_TYPE_Offset*           = 00FCH;

    (* == ADC == *)
    (* datasheet 4.9.6, p566 *)
    ADC_CS*     = ADC_BASE;
    ADC_RESULT* = ADC_BASE + 004H;
    ADC_FCS*    = ADC_BASE + 008H;
    ADC_FIFO*   = ADC_BASE + 00CH;
    ADC_DIV*    = ADC_BASE + 010H;
    ADC_INTR*   = ADC_BASE + 014H;
    ADC_INTE*   = ADC_BASE + 018H;
    ADC_INTF*   = ADC_BASE + 01CH;
    ADC_INTS*   = ADC_BASE + 020H;

    (* == PWM == *)
    (* datasheet 4.5.3, p531 *)
    PWM_CH0_CSR*  = PWM_BASE;
    PWM_CH0_DIV*  = PWM_BASE + 004H;
    PWM_CH0_CTR*  = PWM_BASE + 008H;
    PWM_CH0_CC*   = PWM_BASE + 00CH;
    PWM_CH0_TOP*  = PWM_BASE + 010H;
      (* CH0 .. CH7 *)
      (* block offset *)
      PWM_CH_Offset*  = 014H;
      (* block register offsets *)
      PWM_CSR_Offset* = 000H;
      PWM_DIV_Offset* = 004H;
      PWM_CTR_Offset* = 008H;
      PWM_CC_Offset*  = 00CH;
      PWM_TOP_Offset* = 010H;

    PWM_EN*         = PWM_BASE + 00A0H;
    PWM_INTR*       = PWM_BASE + 00A4H;
    PWM_IRQ0_INTE*  = PWM_BASE + 00A8H; (* "IRQ0": rp2350 compatibility *)
    PWM_IRQ0_INTF*  = PWM_BASE + 00ACH;
    PWM_IRQ0_INTS*  = PWM_BASE + 00B0H;

    (* == TIMER == *)
    (* datasheet 4.6.5, p541 *)
    (* offsets from TIMER0_BASE *)
    TIMER_TIMEHW_Offset*    = 000H;
    TIMER_TIMELW_Offset*    = 004H;
    TIMER_TIMEHR_Offset*    = 008H;
    TIMER_TIMELR_Offset*    = 00CH;
    TIMER_ALARM0_Offset*    = 010H;
    TIMER_ALARM1_Offset*    = 014H;
    TIMER_ALARM2_Offset*    = 018H;
    TIMER_ALARM3_Offset*    = 01CH;
    TIMER_ARMED_Offset*     = 020H;
    TIMER_TIMERAWH_Offset*  = 024H;
    TIMER_TIMERAWL_Offset*  = 028H;
    TIMER_DBGPAUSE_Offset*  = 02CH;
    TIMER_PAUSE_Offset*     = 030H;
    TIMER_LOCKED_Offset*    = 034H;
    TIMER_SOURCE_Offset*    = 038H;
    TIMER_INTR_Offset*      = 03CH;
    TIMER_INTE_Offset*      = 040H;
    TIMER_INTF_Offset*      = 044H;
    TIMER_INTS_Offset*      = 048H;

    (* == WATCHDOG == *)
    WATCHDOG_CTRL*      = WATCHDOG_BASE;
    WATCHDOG_LOAD*      = WATCHDOG_BASE + 004H;
    WATCHDOG_REASON*    = WATCHDOG_BASE + 008H;

    WATCHDOG_SCRATCH0*  = WATCHDOG_BASE + 00CH;
    WATCHDOG_SCRATCH1*  = WATCHDOG_BASE + 010H;
    WATCHDOG_SCRATCH2*  = WATCHDOG_BASE + 014H;
    WATCHDOG_SCRATCH3*  = WATCHDOG_BASE + 018H;
    WATCHDOG_SCRATCH4*  = WATCHDOG_BASE + 01CH;
    WATCHDOG_SCRATCH5*  = WATCHDOG_BASE + 020H;
    WATCHDOG_SCRATCH6*  = WATCHDOG_BASE + 024H;
    WATCHDOG_SCRATCH7*  = WATCHDOG_BASE + 028H;
      WATCHDOG_SCRATCH_Offset* = 4;

    WATCHDOG_TICK*     = WATCHDOG_BASE + 02CH;


    (* == RTC == *)
    (* datasheet 4.8.6, p555 *)
    RTC_CLKDIV_M1*   = RTC_BASE;
    RTC_SETUP_0*     = RTC_BASE + 004H;
    RTC_SETUP_1*     = RTC_BASE + 008H;
    RTC_CTRL*        = RTC_BASE + 00CH;
    RTC_IRQ_SETUP_0* = RTC_BASE + 010H;
    RTC_IRQ_SETUP_1* = RTC_BASE + 014H;
    RTC_RTC_1*       = RTC_BASE + 018H;
    RTC_RTC_0*       = RTC_BASE + 01CH;
    RTC_INTR*        = RTC_BASE + 020H;
    RTC_INTE*        = RTC_BASE + 024H;
    RTC_INTF*        = RTC_BASE + 028H;
    RTC_INTS*        = RTC_BASE + 02CH;

    (* == ROSC == *)
    (* datasheet 2.17.8, p223 *)
    ROSC_CTRL*      = ROSC_BASE;
    ROSC_FREQA*     = ROSC_BASE + 004H;
    ROSC_FREQB*     = ROSC_BASE + 008H;
    ROSC_DORMANT*   = ROSC_BASE + 00CH;
    ROSC_DIV*       = ROSC_BASE + 010H;
    ROSC_PHASE*     = ROSC_BASE + 014H;
    ROSC_STATUS*    = ROSC_BASE + 018H;
    ROSC_RANDOMBIT* = ROSC_BASE + 01CH;
    ROSC_COUNT*     = ROSC_BASE + 020H;

    (* == VREG_AND_CHIP_RESET == *)
    VREG_AND_CHIP_RESET_VREG*       = VREG_AND_CHIP_RESET_BASE;
    VREG_AND_CHIP_RESET_BOD*        = VREG_AND_CHIP_RESET_BASE + 04H;
    VREG_AND_CHIP_RESET_CHIP_RESET* = VREG_AND_CHIP_RESET_BASE + 08H;

    (* == TBMAN == *)
    (* datasheet 2.22.1, p307 *)
    TBMAN_PLATFORM* = TBMAN_BASE;


  (* ===== AHB-Lite: Advanced High-performance Bus lite ====== *)

    (* == DMA == *)
    (* datasheet 2.5.7, p102 *)
    DMA_CH0_READ_ADDR*              = DMA_BASE;
    DMA_CH0_WRITE_ADDR*             = DMA_BASE + 0004H;
    DMA_CH0_TRANS_COUNT*            = DMA_BASE + 0008H;
    DMA_CH0_CTRL_TRIG*              = DMA_BASE + 000CH;
    DMA_CH0_ALT1_CTRL*              = DMA_BASE + 0010H;
    DMA_CH0_ALT1_READ_ADDR*         = DMA_BASE + 0014H;
    DMA_CH0_ALT1_WRITE_ADDR*        = DMA_BASE + 0018H;
    DMA_CH0_ALT1_TRANS_COUNT_TRIG*  = DMA_BASE + 001CH;
    DMA_CH0_ALT2_CTRL*              = DMA_BASE + 0020H;
    DMA_CH0_ALT2_TRANS_COUNT*       = DMA_BASE + 0024H;
    DMA_CH0_ALT2_READ_ADDR*         = DMA_BASE + 0028H;
    DMA_CH0_ALT2_WRITE_ADDR_TRIG*   = DMA_BASE + 002CH;
    DMA_CH0_ALT3_CTRL*              = DMA_BASE + 0030H;
    DMA_CH0_ALT3_WRITE_ADDR*        = DMA_BASE + 0034H;
    DMA_CH0_ALT3_TRANS_COUNT*       = DMA_BASE + 0038H;
    DMA_CH0_ALT3_READ_ADDR_TRIG*    = DMA_BASE + 003CH;
      (* CH0 .. CH11 *)
      (* block offset *)
      DMA_CH_Offset* = 040H;
      (* block register offsets *)
      DMA_CH_READ_ADDR_Offset*              = 0000H;
      DMA_CH_WRITE_ADDR_Offset*             = 0004H;
      DMA_CH_TRANS_COUNT_Offset*            = 0008H;
      DMA_CH_CTRL_TRIG_Offset*              = 000CH;
      DMA_CH_ALT1_CTRL_Offset*              = 0010H;
      DMA_CH_ALT1_READ_ADDR_Offset*         = 0014H;
      DMA_CH_ALT1_WRITE_ADDR_Offset*        = 0018H;
      DMA_CH_ALT1_TRANS_COUNT_TRIG_Offset*  = 001CH;
      DMA_CH_ALT2_CTRL_Offset*              = 0020H;
      DMA_CH_ALT2_TRANS_COUNT_Offset*       = 0024H;
      DMA_CH_ALT2_READ_ADDR_Offset*         = 0028H;
      DMA_CH_ALT2_WRITE_ADDR_TRIG_Offset*   = 002CH;
      DMA_CH_ALT3_CTRL_Offset*              = 0030H;
      DMA_CH_ALT3_WRITE_ADDR_Offset*        = 0034H;
      DMA_CH_ALT3_TRANS_COUNT_Offset*       = 0038H;
      DMA_CH_ALT3_READ_ADDR_TRIG_Offset*    = 003CH;

    DMA_INTR*         = DMA_BASE + 0400H;
    DMA_INTE0*        = DMA_BASE + 0404H;
    DMA_INTF0*        = DMA_BASE + 0408H;
    DMA_INTS0*        = DMA_BASE + 040CH;
    DMA_INTE1*        = DMA_BASE + 0414H;
    DMA_INTF1*        = DMA_BASE + 0418H;
    DMA_INTS1*        = DMA_BASE + 041CH;

    DMA_TIMER0*       = DMA_BASE + 0420H;
    DMA_TIMER1*       = DMA_BASE + 0424H;
    DMA_TIMER2*       = DMA_BASE + 0428H;
    DMA_TIMER3*       = DMA_BASE + 042CH;

    DMA_MULTI_CHAN_TRIGGER* = DMA_BASE + 0430H;
    DMA_SNIFF_CTRL*   = DMA_BASE + 0434H;
    DMA_SNIFF_DATA*   = DMA_BASE + 0438H;
    DMA_FIFO_LEVELS*  = DMA_BASE + 0440H;
    DMA_CHAN_ABORT*   = DMA_BASE + 0444H;
    DMA_N_CHANNELS*   = DMA_BASE + 0448H;

    DMA_CH0_DBG_CTDREQ* = DMA_BASE + 0800H;
    DMA_CH0_DBG_TCR*    = DMA_BASE + 0800H;
      (* CH0 .. CH7 *)
      DMA_CH_DBG_Offset* = 040H;
      (* block register offsets *)
      DMA_CH_DBG_CTDREQ_Offset* = 0;
      DMA_CH_DBG_TCR_Offset*    = 4;

    (* DREQ *)
    (* .. *)

    (* == USBCTRL == *)
    (* == USBCTRL_DPRAM == *)
    (* == USB_CTRL_REGS == *)

    (* == PIO0, PIO1 == *)
    (* datasheet 3.7, p366 *)
    (* offsets from PIO0_BASE, PIO1_BASE *)
    PIO_CTRL_Offset*              = 0000H;
    PIO_FSTAT_Offset*             = 0004H;
    PIO_FDEBUG_Offset*            = 0008H;
    PIO_FLEVEL_Offset*            = 000CH;
    PIO_TXF0_Offset*              = 0010H;
    PIO_TXF1_Offset*              = 0014H;
    PIO_TXF2_Offset*              = 0018H;
    PIO_TXF3_Offset*              = 001CH;
    PIO_RXF0_Offset*              = 0020H;
    PIO_RXF1_Offset*              = 0024H;
    PIO_RXF2_Offset*              = 0028H;
    PIO_RXF3_Offset*              = 002CH;
    PIO_IRQ_Offset*               = 0030H;
    PIO_IRQ_FORCE_Offset*         = 0034H;
    PIO_INPUT_SYNC_BYPASS_Offset* = 0038H;
    PIO_DBG_PADOUT_Offset*        = 003CH;
    PIO_DBG_PADOE_Offset*         = 0040H;
    PIO_DBG_CFGINFO_Offset*       = 0044H;

    PIO_INSTR_MEM0_Offset*        = 0048H;
      (* MEM0 .. MEM31 *)
      (* block offset *)
      PIO_INSTR_MEM_Offset* = 4;

    PIO_SM0_CLKDIV_Offset*       = 00C8H;
    PIO_SM0_EXECCTRL_Offset*     = 00CCH;
    PIO_SM0_SHIFTCTRL_Offset*    = 00D0H;
    PIO_SM0_ADDR_Offset*         = 00D4H;
    PIO_SM0_INSTR_Offset*        = 00D8H;
    PIO_SM0_PINCTRL_Offset*      = 00DCH;
      (* SM0 .. SM3 *)
      (* block offset *)
      PIO_SM_Offset* = 018H;
      (* block register offsets *)
      PIO_SM_CLKDIV_Offset*    = 000H;
      PIO_SM_EXECCTRL_Offset*  = 004H;
      PIO_SM_SHIFTCTRL_Offset* = 008H;
      PIO_SM_ADDR_Offset*      = 00CH;
      PIO_SM_INSTR_Offset*     = 010H;
      PIO_SM_PINCTRL_Offset*   = 014H;

    PIO_INTR_Offset*            = 0128H;
    PIO_IRQ0_INTE_Offset*       = 012CH;
    PIO_IRQ0_INTF_Offset*       = 0130H;
    PIO_IRQ0_INTS_Offset*       = 0134H;
    PIO_IRQ1_INTE_Offset*       = 0138H;
    PIO_IRQ1_INTF_Offset*       = 013CH;
    PIO_IRQ1_INTS_Offset*       = 0140H;

    (* == XIP_AUX == *)

    (* ===== core local ====== *)

    (* == SIO == *)
    SIO_CPUID*            = SIO_BASE;
    SIO_GPIO_IN*          = SIO_BASE + 004H;
    SIO_GPIO_HI_IN*       = SIO_BASE + 008H;
    SIO_GPIO_OUT*         = SIO_BASE + 010H;
    SIO_GPIO_OUT_SET*     = SIO_BASE + 014H;
    SIO_GPIO_OUT_CLR*     = SIO_BASE + 018H;
    SIO_GPIO_OUT_XOR*     = SIO_BASE + 01CH;
    SIO_GPIO_OE*          = SIO_BASE + 020H;
    SIO_GPIO_OE_SET*      = SIO_BASE + 024H;
    SIO_GPIO_OE_CLR*      = SIO_BASE + 028H;
    SIO_GPIO_OE_XOR*      = SIO_BASE + 02CH;
    SIO_GPIO_HI_OUT*      = SIO_BASE + 030H;
    SIO_GPIO_HI_OUT_SET*  = SIO_BASE + 034H;
    SIO_GPIO_HI_OUT_CLR*  = SIO_BASE + 038H;
    SIO_GPIO_HI_OUT_XOR*  = SIO_BASE + 03CH;
    SIO_GPIO_HI_OE*       = SIO_BASE + 040H;
    SIO_GPIO_HI_OE_SET*   = SIO_BASE + 044H;
    SIO_GPIO_HI_OE_CLR*   = SIO_BASE + 048H;
    SIO_GPIO_HI_OE_XOR*   = SIO_BASE + 04CH;
    SIO_FIFO_ST*          = SIO_BASE + 050H;
    SIO_FIFO_WR*          = SIO_BASE + 054H;
    SIO_FIFO_RD*          = SIO_BASE + 058H;
    SIO_SPINLOCK_ST*      = SIO_BASE + 05CH;

    SIO_DIV_UDIVIDEND*    = SIO_BASE + 060H;
    SIO_DIV_UDIVISOR*     = SIO_BASE + 064H;
    SIO_DIV_SDIVIDEND*    = SIO_BASE + 068H;
    SIO_DIV_SDIVISOR*     = SIO_BASE + 06CH;
    SIO_DIV_QUOTIENT*     = SIO_BASE + 070H;
    SIO_DIV_REMAINDER*    = SIO_BASE + 074H;
    SIO_DIV_CSR*          = SIO_BASE + 078H;

    SIO_INTERP0_ACCUM0*     = SIO_BASE + 00080H;
    SIO_INTERP0_ACCUM1*     = SIO_BASE + 00084H;
    SIO_INTERP0_BASE0*      = SIO_BASE + 00088H;
    SIO_INTERP0_BASE1*      = SIO_BASE + 0008CH;
    SIO_INTERP0_BASE2*      = SIO_BASE + 00090H;
    SIO_INTERP0_POP_LANE0*  = SIO_BASE + 00094H;
    SIO_INTERP0_POP_LANE1*  = SIO_BASE + 00098H;
    SIO_INTERP0_POP_FULL*   = SIO_BASE + 0009CH;
    SIO_INTERP0_PEEK_LANE0* = SIO_BASE + 000A0H;
    SIO_INTERP0_PEEK_LANE1* = SIO_BASE + 000A4H;
    SIO_INTERP0_PEEK_FULL*  = SIO_BASE + 000A8H;
    SIO_INTERP0_CTRL_LANE0* = SIO_BASE + 000ACH;
    SIO_INTERP0_CTRL_LANE1* = SIO_BASE + 000B0H;
    SIO_INTERP0_ACCUM0_ADD* = SIO_BASE + 000B4H;
    SIO_INTERP0_ACCUM1_ADD* = SIO_BASE + 000B8H;
    SIO_INTERP0_BASE_1AND0* = SIO_BASE + 000BCH;
      (* INTERP0 .. INTERP1 *)
      (* block offset *)
      SIO_INTERP_Offset* = 040H;
      (* block register offsets *)
      SIO_INTERP_ACCUM0_Offset*     = 000H;
      SIO_INTERP_ACCUM1_Offset*     = 004H;
      SIO_INTERP_BASE0_Offset*      = 008H;
      SIO_INTERP_BASE1_Offset*      = 00CH;
      SIO_INTERP_BASE2_Offset*      = 010H;
      SIO_INTERP_POP_LANE0_Offset*  = 014H;
      SIO_INTERP_POP_LANE1_Offset*  = 018H;
      SIO_INTERP_POP_FULL_Offset*   = 01CH;
      SIO_INTERP_PEEK_LANE0_Offset* = 020H;
      SIO_INTERP_PEEK_LANE1_Offset* = 024H;
      SIO_INTERP_PEEK_FULL_Offset*  = 028H;
      SIO_INTERP_CTRL_LANE0_Offset* = 02CH;
      SIO_INTERP_CTRL_LANE1_Offset* = 030H;
      SIO_INTERP_ACCUM0_ADD_Offset* = 034H;
      SIO_INTERP_ACCUM1_ADD_Offset* = 038H;
      SIO_INTERP_BASE_1AND0_Offset* = 03CH;

    SIO_SPINLOCK0*  = SIO_BASE + 00100H;
      (* SPINLOCK0 to SPINLOCK 31 *)
      (* block offset *)
      SIO_SPINLOCK_Offset* = 4;


  (* ===== PPB: processor private bus ===== *)

    (* datasheet 2.4.8, p77 *)
    (* -- SysTick -- *)
    PPB_SYST_CSR*     = PPB_BASE + 0E010H;
    PPB_SYST_RVR*     = PPB_BASE + 0E014H;
    PPB_SYST_CVR*     = PPB_BASE + 0E018H;
    PPB_SYST_CALIB*   = PPB_BASE + 0E01CH;

    (* -- NVIC -- *)
    PPB_NVIC_ISER0*   = PPB_BASE + 0E100H;
      PPB_NVIC_ISER_Offset* = 0;
    PPB_NVIC_ICER0*   = PPB_BASE + 0E180H;
      PPB_NVIC_ICER_Offset* = 0;
    PPB_NVIC_ISPR0*   = PPB_BASE + 0E200H;
      PPB_NVIC_ISPR_Offset* = 0;
    PPB_NVIC_ICPR0*   = PPB_BASE + 0E280H;
      PPB_NVIC_ICPR_Offset* = 0;

    PPB_NVIC_IPR0*    = PPB_BASE + 0E400H;
    PPB_NVIC_IPR1*    = PPB_BASE + 0E404H;
    PPB_NVIC_IPR2*    = PPB_BASE + 0E408H;
    PPB_NVIC_IPR3*    = PPB_BASE + 0E40CH;
    PPB_NVIC_IPR4*    = PPB_BASE + 0E410H;
    PPB_NVIC_IPR5*    = PPB_BASE + 0E414H;
    PPB_NVIC_IPR6*    = PPB_BASE + 0E418H;
    PPB_NVIC_IPR7*    = PPB_BASE + 0E41CH;
      PPB_NVIC_IPR_Offset* = 4;

    (* IRQ numbers *)
    (* datasheet 32.3.2, p60 *)
    PPB_NVIC_TIMER0_IRQ_0*   = 0;
    PPB_NVIC_TIMER0_IRQ_1*   = 1;
    PPB_NVIC_TIMER0_IRQ_2*   = 2;
    PPB_NVIC_TIMER0_IRQ_3*   = 3;
    PPB_NVIC_PWM_IRQ_WRAP_0* = 4;
    PPB_NVIC_USBCTRL_IRQ*    = 5;
    PPB_NVIC_XIP_IRQ*        = 6;
    PPB_NVIC_PIO0_IRQ_0*     = 7;
    PPB_NVIC_PIO0_IRQ_1*     = 8;
    PPB_NVIC_PIO1_IRQ_0*     = 9;
    PPB_NVIC_PIO1_IRQ_1*     = 10;
    PPB_NVIC_DMA_IRQ_0*      = 11;
    PPB_NVIC_DMA_IRQ_1*      = 12;
    PPB_NVIC_IO_IRQ_BANK0*   = 13;
    PPB_NVIC_IO_IRQ_QSPI*    = 14;
    PPB_NVIC_SIO_IRQ_PROC0*  = 15;
    PPB_NVIC_SIO_IRQ_PROC1*  = 16;
    PPB_NVIC_CLOCKS_IRQ*     = 17;
    PPB_NVIC_SPI0_IRQ*       = 18;
    PPB_NVIC_SPI1_IRQ*       = 19;
    PPB_NVIC_UART0_IRQ*      = 20;
    PPB_NVIC_UART1_IRQ*      = 21;
    PPB_NVIC_ADC_IRQ_FIFO*   = 22;
    PPB_NVIC_I2C0_IRQ*       = 23;
    PPB_NVIC_I2C1_IRQ*       = 24;
    PPB_NVIC_RTC_IRQ*        = 25;
    PPB_NVIC_SPAREIRQ_IRQ0*  = 26;
    PPB_NVIC_SPAREIRQ_IRQ1*  = 27;
    PPB_NVIC_SPAREIRQ_IRQ2*  = 28;
    PPB_NVIC_SPAREIRQ_IRQ3*  = 29;
    PPB_NVIC_SPAREIRQ_IRQ4*  = 30;
    PPB_NVIC_SPAREIRQ_IRQ5*  = 31;

    (* IRQ exception numbers *)
    (* exception number = IRQ number + PPB_IRQ_BASE *)
    PPB_IRQ_BASE* = 16;

    (* exception numbers *)
    PPB_NVIC_NMI_Exc*           = 2;
    PPB_NVIC_HardFault_Exc*     = 3;
    PPB_NVIC_MemMgmtFault_Exc*  = 4;  (* not implemented in M0+ *)
    PPB_NVIC_BusFault_Exc*      = 5;  (* not implemented in M0+ *)
    PPB_NVIC_UsageFault_Exc*    = 6;  (* not implemented in M0+ *)
    PPB_NVIC_SecureFault_Exc*   = 7;  (* not implemented in M0+ *)
    PPB_NVIC_SVC_Exc*           = 11;
    PPB_NVIC_PendSV_Exc*        = 14;
    PPB_NVIC_SysTick_Exc*       = 15;

    PPB_NVIC_SysExc*  = {3, 11, 14, 15};

    VectorTableSize*            = 192; (* 16 + 32 words *)
    ResetHandlerOffset*         = 004H;
    NMIhandlerOffset*           = 008H;
    HardFaultHandlerOffset*     = 00CH;
    SVChandlerOffset*           = 02CH;

    DebugMonitorOffset*         = 030H;   (* not implemented in M0+ *)

    SysTickHandlerOffset*       = 03CH;

    MissingHandlerOffset*       = 038H;
    IrqZeroHandlerOffset*       = 040H;

    (* -- SCB -- *)
    PPB_CPUID*        = PPB_BASE + 0ED00H;
    PPB_ICSR*         = PPB_BASE + 0ED04H;
    PPB_VTOR*         = PPB_BASE + 0ED08H;
    PPB_AIRCR*        = PPB_BASE + 0ED0CH;
    PPB_SCR*          = PPB_BASE + 0ED10H;
    PPB_CCR*          = PPB_BASE + 0ED14H;

    (* defining non-implemented 'PPB_SHPR1' allows to calculate other 'PPB_SHPRx' *)
    (* uniformly across M-architectures using the exception number *)
    PPB_SHPR1*        = PPB_BASE + 0ED18H;  (* not implemented in M0+ *)
    PPB_SHPR2*        = PPB_BASE + 0ED1CH;
    PPB_SHPR3*        = PPB_BASE + 0ED20H;
    PPB_SHCSR*        = PPB_BASE + 0ED24H;

    (* -- MPU -- *)
    PPB_MPU_TYPE*     = PPB_BASE + 0ED90H;
    PPB_MPU_CTRL*     = PPB_BASE + 0ED94H;
    PPB_MPU_RNR*      = PPB_BASE + 0ED98H;
    PPB_MPU_RBAR*     = PPB_BASE + 0ED9CH;
    PPB_MPU_RASR*     = PPB_BASE + 0EDA0H;


  (* ===== CPU registers ===== *)
    (* CONTROL special register *)
    CONTROL_SPSEL* = 1; (* enable PSP *)


  (* ===== assembly instructions ===== *)
    NOP* = 046C0H;

    (* read specical regs MRS *)
    (* 0F3EF8 B 09H r11(B) PSP(09) *)
    MRS_R11_IPSR* = 0F3EF8B05H;  (* move IPSR to r11 *)
    MRS_R03_IPSR* = 0F3EF8305H;  (* move IPSR to r3 *)
    MRS_R00_IPSR* = 0F3EF8005H;  (* move IPSR to r0 *)

    MRS_R11_XPSR* = 0F3EF8B03H;  (* move XPSR to r11 *)
    MRS_R03_XPSR* = 0F3EF8303H;  (* move XPSR to r3 *)

    MRS_R11_MSP*  = 0F3EF8B08H;  (* move MSP to r11 *)
    MRS_R03_MSP*  = 0F3EF8308H;  (* move MSP to r3 *)
    MRS_R00_MSP*  = 0F3EF8008H;  (* move MSP to r3 *)

    MRS_R11_PSP*  = 0F3EF8B09H;  (* move PSP to r11 *)
    MRS_R03_PSP*  = 0F3EF8309H;  (* move PSP to r3 *)
    MRS_R00_PSP*  = 0F3EF8009H;  (* move PSP to r0 *)

    MRS_R11_CTL*  = 0F3EF8B14H;  (* move CONTROL to r11 *)
    MRS_R03_CTL*  = 0F3EF8314H;  (* move CONTROL to r3 *)

    (* write special regs MSR *)
    (* 0F38 B 88 09H r11(B) PSP(09) *)
    MSR_PSP_R11* = 0F38B8809H;  (* move r11 to PSP *)
    MSR_CTL_R11* = 0F38B8814H;  (* move r11 to CONTROL *)

    (* instruction sync *)
    ISB* = 0F3BF8F6FH;

 END MCU2.
