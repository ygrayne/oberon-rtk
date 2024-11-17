MODULE MCU2;
(**
  Oberon RTK Framework v2
  --
  MCU register and memory addresses, bits, values, assembly instructions
  --
  MCU: RP2350, Pico2
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumCores*       = 2;
    NumUART*        = 2;
    NumSPI*         = 2;
    NumI2C*         = 2;
    NumTimers*      = 2;
    NumPIO*         = 3;
    NumPWMchan*     = 12;
    NumDMAchan*     = 16;
    NumGPIO*        = 30; (* QFN-60 package as on Pico2 *)
    NumInterrupts*  = 52;

    (* as configured in Clocks.mod *)
    SysClkFreq*  = 125 * 1000000; (* from SYS PLL *)
    RefClkFreq*  =  12 * 1000000; (* from USB PLL *)
    PeriClkFreq* =  48 * 1000000; (* from USB PLL *)
    SysTickFreq* =   1 * 1000000; (* via clock divider in ticks gen, from ref clock *)

    (* atomic register access, datasheet 2.1.3, p26
    addr + 0000H: normal read write access
    addr + 1000H: atomic XOR on write
    addr + 2000H: atomic bitmask set on write
    addr + 3000H: atomic bitmask clear on write
    *)
    AXOR* = 01000H;
    ASET* = 02000H;
    ACLR* = 03000H;

    (* == base addresses == *)
    (* datasheet 2.2, p30 *)
    (* -- memory base addresses -- *)
    ROM_BASE*           = 000000000H;
    XIP_BASE*           = 010000000H; (* see also "XIP" below *)
    SRAM_BASE*          = 020000000H; (* see also "SRAM" below *)

    (* -- apb base addresses -- *)
    SYSINFO_BASE*     = 040000000H;
    SYSCFG_BASE*      = 040008000H;
    CLOCKS_BASE*      = 040010000H;
    PSM_BASE*         = 040018000H;
    RESETS_BASE*      = 040020000H;
    IO_BANK0_BASE*    = 040028000H;
    IO_QSPI_BASE*     = 040030000H;
    PADS_BANK0_BASE*  = 040038000H;
    PADS_QSPI_BASE*   = 040040000H;
    XOSC_BASE*        = 040048000H;
    PLL_SYS_BASE*     = 040050000H;
    PLL_USB_BASE*     = 040058000H;
    ACCESSCTRL_BASE*  = 040060000H;
    BUSCTRL_BASE*     = 040068000H;
    UART0_BASE*       = 040070000H;
    UART1_BASE*       = 040078000H;
    SPI0_BASE*        = 040080000H;
    SPI1_BASE*        = 040088000H;
    I2C0_BASE*        = 040090000H;
    I2C1_BASE*        = 040098000H;
    ADC_BASE*         = 0400A0000H;
    PWM_BASE*         = 0400A8000H;
    TIMER0_BASE*      = 0400B0000H;
    TIMER1_BASE*      = 0400B8000H;
    HSTX_CTRL_BASE*   = 0400C0000H;
    XIP_CTRL_BASE*    = 0400C8000H;
    XIP_QMI_BASE*     = 0400D0000H;
    WATCHDOG_BASE*    = 0400D8000H;
    BOOTRAM_BASE*     = 0400E0000H;
    ROSC_BASE*        = 0400E8000H;
    TRNG_BASE*        = 0400F0000H;
    SHA256_BASE*      = 0400F8000H;
    POWMAN_BASE*      = 040100000H;
    TICKS_BASE*       = 040108000H;
    OTP_BASE*                     = 040120000H;
    OTP_DATA_BASE*                = 040130000H;
    OTP_DATA_RAW_BASE*            = 040134000H;
    OTP_DATA_GUARDED_BASE*        = 040138000H;
    OTP_DATA_RAW_GUARDED_BASE*    = 04013C000H;
    CORESIGHT_PERIPH_BASE*        = 040140000H;
    CORESIGHT_ROMTABLE_BASE*      = 040140000H;
    CORESIGHT_AHB_AP_CORE0_BASE*  = 040142000H;
    CORESIGHT_AHB_AP_CORE1_BASE*  = 040144000H;
    CORESIGHT_TIMESTAMP_GEN_BASE* = 040146000H;
    CORESIGHT_ATB_FUNNEL_BASE*    = 040147000H;
    CORESIGHT_TPIU_BASE*          = 040148000H;
    CORESIGHT_CTI_BASE*           = 040149000H;
    CORESIGHT_ABP_AP_RISCV_BASE*  = 04014A000H;
    GLITCH_DETECTOR_BASE*         = 040158000H;
    TBMAN_BASE*                   = 040160000H;

    (* -- ahb base addresses -- *)
    DMA_BASE*             = 050000000H;
    USBCTRL_BASE*         = 050100000H;
    USBCTRL_DPRAM_BASE*   = 050100000H;
    USB_CTRL_REGS_BASE*   = 050110000H;
    PIO0_BASE*            = 050200000H;
    PIO1_BASE*            = 050300000H;
    PIO2_BASE*            = 050400000H;
    XIP_AUX_BASE*         = 050500000H;
    HSTX_FIFO_BASE*       = 050600000H;
    CORESIGHT_TRACE_BASE* = 050700000H;

    (* -- core-local base addresses -- *)
    SIO_BASE*             = 0D0000000H;
    SIO_NONSEC_BASE*      = 0D0020000H;

    (* -- PPB base addresses -- *)
    PPB_BASE*             = 0E0000000H;
    PPB_NONSEC_BASE*      = 0E0020000H;
    EPPB_BASE*            = 0E0080000H;

    (* == XIP == *)
    XIP_NOCACHE_NOALLOC_BASE* = 014000000H;
    XIP_MAINTENANCE_BASE*     = 018000000H;

    (* == SRAM == *)
    SRAM0_BASE*           = 020000000H;
    SRAM4_BASE*           = 020040000H;
    SRAM8_BASE*           = 020080000H;
    SRAM9_BASE*           = 020081000H;
    SRAM_HALF_BASE*       = SRAM4_BASE;
    SRAM_EXT0*            = SRAM8_BASE;
    SRAM_EXT1*            = SRAM9_BASE;


  (* ====== APB: Advanced Peripheral Bus ====== *)

    (* == SYSINFO == *)
    (* datasheet 12.15.1, p1236 *)
    SYSINFO_CHIP_ID*      = SYSINFO_BASE;
    SYSINFO_PACKAGE_SEL*  = SYSINFO_BASE + 004H;
    SYSINFO_PLATFORM*     = SYSINFO_BASE + 008H;
    SYSINFO_GITREF*       = SYSINFO_BASE + 014H;

    (* == SYSCFG == *)
    (* datasheet 12.15.2, p1236 *)
    SYSCFG_PROC_CONFIG*             = SYSCFG_BASE;
    SYSCFG_PROC_IN_SYNC_BYPASS*     = SYSCFG_BASE + 004H;
    SYSCFG_PROC_IN_SYNC_BYPASS_HI*  = SYSCFG_BASE + 008H;
    SYSCFG_DBGFORCE*                = SYSCFG_BASE + 00CH;
    SYSCFG_MEMPOWERDOWN*            = SYSCFG_BASE + 010H;
    SYSCFG_AUXCTRL*                 = SYSCFG_BASE + 014H;

    (* == CLOCKS == *)
    (* datasheet 8.1.6, p518 *)
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

    (* == PSM: power-on state machine == *)
    (* datasheet 7.4.4, p488 *)
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

    (* == RESETS: sub-system resets == *)
    (* datasheet 7.5.3, p494 *)
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

    (* == IO_BANK0 == *)
    (* datasheet 9.11.1, p592 *)
    IO_BANK0_GPIO0_STATUS*  = IO_BANK0_BASE;
    IO_BANK0_GPIO0_CTRL*    = IO_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO47 *)
      (* block offset *)
      IO_BANK0_GPIO_Offset* = 8;
      (* block register offsets *)
      IO_BANK0_GPIO_STATUS_Offset*  = 0;
      IO_BANK0_GPIO_CTRL_Offset*    = 4;

    (* IO functions *)
    IO_BANK0_Fhstx*   = 0;
    IO_BANK0_Fspi*    = 1;
    IO_BANK0_Fuart*   = 2;
    IO_BANK0_Fi2c*    = 3;
    IO_BANK0_Fpwm*    = 4;
    IO_BANK0_Fsio*    = 5;
    IO_BANK0_Fpio0*   = 6;
    IO_BANK0_Fpio1*   = 7;
    IO_BANK0_Fpio2*   = 8;
    IO_BANK0_Fqmi*    = 9;
    IO_BANK0_Ftrc*    = 9;
    IO_BANK0_Fclk*    = 9;
    IO_BANK0_Fusb*    = 10;
    IO_BANK0_FuartAlt* = 11;

    IO_BANK0_Functions* = {IO_BANK0_Fhstx .. IO_BANK0_FuartAlt};

    (* note: identifiers abbreviated due to compiler name length restrictions *)
    IO_BANK0_IRQSUM_PROC0_SEC0*       = IO_BANK0_BASE + 0200H;
    IO_BANK0_IRQSUM_PROC0_SEC1*       = IO_BANK0_BASE + 0204H;
    IO_BANK0_IRQSUM_PROC0_NONSEC0*    = IO_BANK0_BASE + 0208H;
    IO_BANK0_IRQSUM_PROC0_NONSEC1*    = IO_BANK0_BASE + 020CH;
    IO_BANK0_IRQSUM_PROC1_SEC0*       = IO_BANK0_BASE + 0210H;
    IO_BANK0_IRQSUM_PROC1_SEC1*       = IO_BANK0_BASE + 0214H;
    IO_BANK0_IRQSUM_PROC1_NONSEC0*    = IO_BANK0_BASE + 0218H;
    IO_BANK0_IRQSUM_PROC1_NONSEC1*    = IO_BANK0_BASE + 021CH;
    IO_BANK0_IRQSUM_COMA_WK_SEC0*     = IO_BANK0_BASE + 0220H;
    IO_BANK0_IRQSUM_COMA_WK_SEC1*     = IO_BANK0_BASE + 0224H;
    IO_BANK0_IRQSUM_COMA_WK_NONSEC0*  = IO_BANK0_BASE + 0228H;
    IO_BANK0_IRQSUM_COMA_WK_NONSEC1*  = IO_BANK0_BASE + 022CH;

    (* raw interrupts *)
    IO_BANK0_INTR0*                   = IO_BANK0_BASE + 0230H;
    IO_BANK0_INTR1*                   = IO_BANK0_BASE + 0234H;
    IO_BANK0_INTR2*                   = IO_BANK0_BASE + 0238H;
    IO_BANK0_INTR3*                   = IO_BANK0_BASE + 023CH;
    IO_BANK0_INTR4*                   = IO_BANK0_BASE + 0240H;
    IO_BANK0_INTR5*                   = IO_BANK0_BASE + 0244H;
      IO_BANK0_INTR_Offset* = 4;

    (* core 0 interrupt enable *)
    IO_BANK0_PROC0_INTE0*             = IO_BANK0_BASE + 0248H;
    IO_BANK0_PROC0_INTE1*             = IO_BANK0_BASE + 024CH;
    IO_BANK0_PROC0_INTE2*             = IO_BANK0_BASE + 0250H;
    IO_BANK0_PROC0_INTE3*             = IO_BANK0_BASE + 0254H;
    IO_BANK0_PROC0_INTE4*             = IO_BANK0_BASE + 0258H;
    IO_BANK0_PROC0_INTE5*             = IO_BANK0_BASE + 025CH;
      IO_BANK0_PROC0_INTE_Offset* = 4;

    (* core 0 interrupt force *)
    IO_BANK0_PROC0_INTF0*             = IO_BANK0_BASE + 0260H;
    IO_BANK0_PROC0_INTF1*             = IO_BANK0_BASE + 0264H;
    IO_BANK0_PROC0_INTF2*             = IO_BANK0_BASE + 0268H;
    IO_BANK0_PROC0_INTF3*             = IO_BANK0_BASE + 026CH;
    IO_BANK0_PROC0_INTF4*             = IO_BANK0_BASE + 0270H;
    IO_BANK0_PROC0_INTF5*             = IO_BANK0_BASE + 0274H;
      IO_BANK0_PROC0_INTF_Offset* = 4;

    (* core 0 interrupt status *)
    IO_BANK0_PROC0_INTS0*             = IO_BANK0_BASE + 0278H;
    IO_BANK0_PROC0_INTS1*             = IO_BANK0_BASE + 027CH;
    IO_BANK0_PROC0_INTS2*             = IO_BANK0_BASE + 0280H;
    IO_BANK0_PROC0_INTS3*             = IO_BANK0_BASE + 0284H;
    IO_BANK0_PROC0_INTS4*             = IO_BANK0_BASE + 0288H;
    IO_BANK0_PROC0_INTS5*             = IO_BANK0_BASE + 028CH;
      IO_BANK0_PROC0_INTS_Offset* = 4;

    (* core 1 interrupt enable *)
    IO_BANK0_PROC1_INTE0*             = IO_BANK0_BASE + 0290H;
    IO_BANK0_PROC1_INTE1*             = IO_BANK0_BASE + 0294H;
    IO_BANK0_PROC1_INTE2*             = IO_BANK0_BASE + 0298H;
    IO_BANK0_PROC1_INTE3*             = IO_BANK0_BASE + 029CH;
    IO_BANK0_PROC1_INTE4*             = IO_BANK0_BASE + 02A0H;
    IO_BANK0_PROC1_INTE5*             = IO_BANK0_BASE + 02A4H;
      IO_BANK0_PROC1_INTE_Offset* = 4;

    (* core 1 interrupt force *)
    IO_BANK0_PROC1_INTF0*             = IO_BANK0_BASE + 02A8H;
    IO_BANK0_PROC1_INTF1*             = IO_BANK0_BASE + 02ACH;
    IO_BANK0_PROC1_INTF2*             = IO_BANK0_BASE + 02B0H;
    IO_BANK0_PROC1_INTF3*             = IO_BANK0_BASE + 02B4H;
    IO_BANK0_PROC1_INTF4*             = IO_BANK0_BASE + 02B8H;
    IO_BANK0_PROC1_INTF5*             = IO_BANK0_BASE + 02BCH;
      IO_BANK0_PROC1_INTF_Offset* = 4;

    (* core 1 interrupt status *)
    IO_BANK0_PROC1_INTS0*             = IO_BANK0_BASE + 02C0H;
    IO_BANK0_PROC1_INTS1*             = IO_BANK0_BASE + 02C4H;
    IO_BANK0_PROC1_INTS2*             = IO_BANK0_BASE + 02C8H;
    IO_BANK0_PROC1_INTS3*             = IO_BANK0_BASE + 02CCH;
    IO_BANK0_PROC1_INTS4*             = IO_BANK0_BASE + 02D0H;
    IO_BANK0_PROC1_INTS5*             = IO_BANK0_BASE + 02D4H;
      IO_BANK0_PROC1_INTS_Offset* = 4;

    (* dormant_wake interrupt enable *)
    IO_BANK0_DORMANT_WAKE_INTE0*      = IO_BANK0_BASE + 02D8H;
    IO_BANK0_DORMANT_WAKE_INTE1*      = IO_BANK0_BASE + 02DCH;
    IO_BANK0_DORMANT_WAKE_INTE2*      = IO_BANK0_BASE + 02E0H;
    IO_BANK0_DORMANT_WAKE_INTE3*      = IO_BANK0_BASE + 02E4H;
    IO_BANK0_DORMANT_WAKE_INTE4*      = IO_BANK0_BASE + 02E8H;
    IO_BANK0_DORMANT_WAKE_INTE5*      = IO_BANK0_BASE + 02ECH;
      IO_BANK0_DORMANT_WAKE_INTE_Offset* = 4;

    (* dormant_wake interrupt force *)
    IO_BANK0_DORMANT_WAKE_INTF0*      = IO_BANK0_BASE + 02F0H;
    IO_BANK0_DORMANT_WAKE_INTF1*      = IO_BANK0_BASE + 02F4H;
    IO_BANK0_DORMANT_WAKE_INTF2*      = IO_BANK0_BASE + 02F8H;
    IO_BANK0_DORMANT_WAKE_INTF3*      = IO_BANK0_BASE + 02FCH;
    IO_BANK0_DORMANT_WAKE_INTF4*      = IO_BANK0_BASE + 0300H;
    IO_BANK0_DORMANT_WAKE_INTF5*      = IO_BANK0_BASE + 0304H;
      IO_BANK0_DORMANT_WAKE_INTF_Offset* = 4;

    (* dormant_wake interrupt status *)
    IO_BANK0_DORMANT_WAKE_INTS0*      = IO_BANK0_BASE + 0308H;
    IO_BANK0_DORMANT_WAKE_INTS1*      = IO_BANK0_BASE + 030CH;
    IO_BANK0_DORMANT_WAKE_INTS2*      = IO_BANK0_BASE + 0310H;
    IO_BANK0_DORMANT_WAKE_INTS3*      = IO_BANK0_BASE + 0314H;
    IO_BANK0_DORMANT_WAKE_INTS4*      = IO_BANK0_BASE + 0318H;
    IO_BANK0_DORMANT_WAKE_INTS5*      = IO_BANK0_BASE + 031CH;
      IO_BANK0_DORMANT_WAKE_INTS_Offset* = 4;

    (* == IO_QSPI == *)
    (* datasheet 9.11.2, p746 *)
    IO_QSPI_SCLK_STATUS*        = IO_QSPI_BASE;
    IO_QSPI_SCLK_CTRL*          = IO_QSPI_BASE + 004H;
    IO_QSPI_CS_STATUS*          = IO_QSPI_BASE + 008H;
    IO_QSPI_CS_CTRL*            = IO_QSPI_BASE + 00CH;
    IO_QSPI_SD0_STATUS*         = IO_QSPI_BASE + 010H;
    IO_QSPI_SD0_CTRL*           = IO_QSPI_BASE + 014H;
    IO_QSPI_SD1_STATUS*         = IO_QSPI_BASE + 018H;
    IO_QSPI_SD1_CTRL*           = IO_QSPI_BASE + 01CH;
    IO_QSPI_SD2_STATUS*         = IO_QSPI_BASE + 020H;
    IO_QSPI_SD2_CTRL*           = IO_QSPI_BASE + 024H;
    IO_QSPI_SD3_STATUS*         = IO_QSPI_BASE + 028H;
    IO_QSPI_SD3_CTRL*           = IO_QSPI_BASE + 02CH;
    IO_QSPI_INTR*               = IO_QSPI_BASE + 030H;
    IO_QSPI_PROC0_INTE*         = IO_QSPI_BASE + 034H;
    IO_QSPI_PROC0_INTF*         = IO_QSPI_BASE + 038H;
    IO_QSPI_PROC0_INTS*         = IO_QSPI_BASE + 03CH;
    IO_QSPI_PROC1_INTE*         = IO_QSPI_BASE + 040H;
    IO_QSPI_PROC1_INTF*         = IO_QSPI_BASE + 044H;
    IO_QSPI_PROC1_INTS*         = IO_QSPI_BASE + 048H;
    IO_QSPI_DORMANT_WAKE_INTE*  = IO_QSPI_BASE + 04CH;
    IO_QSPI_DORMANT_WAKE_INTF*  = IO_QSPI_BASE + 050H;
    IO_QSPI_DORMANT_WAKE_INTS*  = IO_QSPI_BASE + 054H;

    (* == PADS_BANK0 == *)
    (* datasheet 9.11.3, p771 *)
    PADS_BANK0_VOLTAGE_SELECT*  = PADS_BANK0_BASE;

    (* bank base & offset *)
    PADS_BANK0_GPIO0*           = PADS_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO47 *)
      PADS_BANK0_GPIO_Offset* = 4;

    PADS_BANK0_SWCLK*           = PADS_BANK0_BASE + 0C4H;
    PADS_BANK0_SWD*             = PADS_BANK0_BASE + 0C8H;

    (* == PADS_QSPI == *)
    (* datasheet 9.11.4, p798 *)
    PADS_QSPI_VOLTAGE_SELECT* = PADS_QSPI_BASE;
    PADS_QSPI_SCKL*           = PADS_QSPI_BASE + 004H;
    PADS_QSPI_SD0*            = PADS_QSPI_BASE + 008H;
    PADS_QSPI_SD1*            = PADS_QSPI_BASE + 00CH;
    PADS_QSPI_SD2*            = PADS_QSPI_BASE + 010H;
    PADS_QSPI_SD3*            = PADS_QSPI_BASE + 014H;
    PADS_QSPI_CS*             = PADS_QSPI_BASE + 018H;

    (* == XOSC == *)
    (* datasheet 8.2.8, p547 *)
    XOSC_CTRL*    = XOSC_BASE;
    XOSC_STATUS*  = XOSC_BASE + 004H;
    XOSC_DORMANT* = XOSC_BASE + 008H;
    XOSC_STARTUP* = XOSC_BASE + 00CH;
    XOSC_COUNT*   = XOSC_BASE + 010H;

    (* == PLL_SYS == *)
    (* datasheet 8.6.5, p571 *)
    PLL_SYS_CS*         = PLL_SYS_BASE;
    PLL_SYS_PWR*        = PLL_SYS_BASE + 004H;
    PLL_SYS_FBDIV_INT*  = PLL_SYS_BASE + 008H;
    PLL_SYS_PRIM*       = PLL_SYS_BASE + 00CH;
    PLL_SYS_INTR*       = PLL_SYS_BASE + 010H;
    PLL_SYS_INTE*       = PLL_SYS_BASE + 014H;
    PLL_SYS_INTF*       = PLL_SYS_BASE + 018H;
    PLL_SYS_INTS*       = PLL_SYS_BASE + 01CH;

    (* == PLL_USB == *)
    (* datasheet 8.6.5, p571 *)
    PLL_USB_CS*         = PLL_USB_BASE;
    PLL_USB_PWR*        = PLL_USB_BASE + 004H;
    PLL_USB_FBDIV_INT*  = PLL_USB_BASE + 008H;
    PLL_USB_PRIM*       = PLL_USB_BASE + 00CH;
    PLL_USB_INTR*       = PLL_USB_BASE + 010H;
    PLL_USB_INTE*       = PLL_USB_BASE + 014H;
    PLL_USB_INTF*       = PLL_USB_BASE + 018H;
    PLL_USB_INTS*       = PLL_USB_BASE + 01CH;

    (* == ACCESSCTRL == *)
    (* datasheet 10.6.3, p812 *)
    ACCESSCTRL_LOCK*          = ACCESSCTRL_BASE;
    ACCESSCTRL_FORCE_CORE_NS* = ACCESSCTRL_BASE + 004H;
    ACCESSCTRL_CFGRESET*      = ACCESSCTRL_BASE + 008H;
    ACCESSCTRL_GPIO_NSMASK0*  = ACCESSCTRL_BASE + 00CH;
    ACCESSCTRL_GPIO_NSMASK1*  = ACCESSCTRL_BASE + 010H;
    ACCESSCTRL_ROM*           = ACCESSCTRL_BASE + 014H;
    ACCESSCTRL_XIP_MAIN*      = ACCESSCTRL_BASE + 018H;
    ACCESSCTRL_SRAM0*         = ACCESSCTRL_BASE + 01CH;
    ACCESSCTRL_SRAM1*         = ACCESSCTRL_BASE + 020H;
    ACCESSCTRL_SRAM2*         = ACCESSCTRL_BASE + 024H;
    ACCESSCTRL_SRAM3*         = ACCESSCTRL_BASE + 028H;
    ACCESSCTRL_SRAM4*         = ACCESSCTRL_BASE + 02CH;
    ACCESSCTRL_SRAM5*         = ACCESSCTRL_BASE + 030H;
    ACCESSCTRL_SRAM6*         = ACCESSCTRL_BASE + 034H;
    ACCESSCTRL_SRAM7*         = ACCESSCTRL_BASE + 038H;
    ACCESSCTRL_SRAM8*         = ACCESSCTRL_BASE + 03CH;
    ACCESSCTRL_SRAM9*         = ACCESSCTRL_BASE + 040H;
    ACCESSCTRL_DMA*           = ACCESSCTRL_BASE + 044H;
    ACCESSCTRL_USBCTRL*       = ACCESSCTRL_BASE + 048H;
    ACCESSCTRL_PIO0*          = ACCESSCTRL_BASE + 04CH;
    ACCESSCTRL_PIO1*          = ACCESSCTRL_BASE + 050H;
    ACCESSCTRL_PIO2*          = ACCESSCTRL_BASE + 054H;
    ACCESSCTRL_CORESIGHT_TRACE*   = ACCESSCTRL_BASE + 058H;
    ACCESSCTRL_CORESIGHT_PERIPH*  = ACCESSCTRL_BASE + 05CH;
    ACCESSCTRL_SYSINFO*       = ACCESSCTRL_BASE + 060H;
    ACCESSCTRL_RESETS*        = ACCESSCTRL_BASE + 064H;
    ACCESSCTRL_IO_BANK0*      = ACCESSCTRL_BASE + 068H;
    ACCESSCTRL_IO_BANK1*      = ACCESSCTRL_BASE + 06CH;
    ACCESSCTRL_PADS_BANK0*    = ACCESSCTRL_BASE + 070H;
    ACCESSCTRL_PADS_QSPI*     = ACCESSCTRL_BASE + 074H;
    ACCESSCTRL_BUSCTRL*       = ACCESSCTRL_BASE + 078H;
    ACCESSCTRL_ADC*           = ACCESSCTRL_BASE + 07CH;
    ACCESSCTRL_HSTX*          = ACCESSCTRL_BASE + 080H;
    ACCESSCTRL_I2C0*          = ACCESSCTRL_BASE + 084H;
    ACCESSCTRL_I2C1*          = ACCESSCTRL_BASE + 088H;
    ACCESSCTRL_PWM*           = ACCESSCTRL_BASE + 08CH;
    ACCESSCTRL_SPI0*          = ACCESSCTRL_BASE + 090H;
    ACCESSCTRL_SPI1*          = ACCESSCTRL_BASE + 094H;
    ACCESSCTRL_TIMER0*        = ACCESSCTRL_BASE + 098H;
    ACCESSCTRL_TIMER1*        = ACCESSCTRL_BASE + 09CH;
    ACCESSCTRL_UART0*         = ACCESSCTRL_BASE + 0A0H;
    ACCESSCTRL_UART1*         = ACCESSCTRL_BASE + 0A4H;
    ACCESSCTRL_OTP*           = ACCESSCTRL_BASE + 0A8H;
    ACCESSCTRL_TBMAN*         = ACCESSCTRL_BASE + 0ACH;
    ACCESSCTRL_POWMAN*        = ACCESSCTRL_BASE + 0B0H;
    ACCESSCTRL_TRNG*          = ACCESSCTRL_BASE + 0B4H;
    ACCESSCTRL_SHA256*        = ACCESSCTRL_BASE + 0B8H;
    ACCESSCTRL_SYSCFG*        = ACCESSCTRL_BASE + 0BCH;
    ACCESSCTRL_CLOCKS*        = ACCESSCTRL_BASE + 0C0H;
    ACCESSCTRL_XOSC*          = ACCESSCTRL_BASE + 0C4H;
    ACCESSCTRL_ROSC*          = ACCESSCTRL_BASE + 0C8H;
    ACCESSCTRL_PLL_SYS*       = ACCESSCTRL_BASE + 0CCH;
    ACCESSCTRL_PLL_USB*       = ACCESSCTRL_BASE + 0D0H;
    ACCESSCTRL_TICKS*         = ACCESSCTRL_BASE + 0D4H;
    ACCESSCTRL_WATCHDOG*      = ACCESSCTRL_BASE + 0D8H;
    ACCESSCTRL_PSM*           = ACCESSCTRL_BASE + 0DCH;
    ACCESSCTRL_XIP_CTRL*      = ACCESSCTRL_BASE + 0E0H;
    ACCESSCTRL_XIP_QMI*       = ACCESSCTRL_BASE + 0E4H;
    ACCESSCTRL_XIP_AUX*       = ACCESSCTRL_BASE + 0E8H;

    (* bits in ACCESSCTRL_* registers *)
    (* ACCESSCTRL_ROM to ACCESSCTRL_XIP_AUX *)
    ACCESSSCTRL_DBG*    = 7;
    ACCESSSCTRL_DMA*    = 6;
    ACCESSSCTRL_CORE1*  = 5;
    ACCESSSCTRL_CORE0*  = 4;
    ACCESSSCTRL_SP*     = 3;
    ACCESSSCTRL_SU*     = 2;
    ACCESSSCTRL_NSP*    = 1;
    ACCESSSCTRL_NSU*    = 0;


    (* == BUSCTRL == *)
    (* datasheet 12.15.4, p1240 *)
    BUSCTRL_BUS_PRIORITY*     = BUSCTRL_BASE;
    BUSCTRL_BUS_PRIORITY_ACK* = BUSCTRL_BASE + 004H;
    BUSCTRL_PERFCTR_EN*       = BUSCTRL_BASE + 008H;
    BUSCTRL_PERFCTR0*         = BUSCTRL_BASE + 00CH;
    BUSCTRL_PERFSEL0*         = BUSCTRL_BASE + 010H;
    BUSCTRL_PERFCTR1*         = BUSCTRL_BASE + 014H;
    BUSCTRL_PERFSEL1*         = BUSCTRL_BASE + 018H;
    BUSCTRL_PERFCTR2*         = BUSCTRL_BASE + 01CH;
    BUSCTRL_PERFSEL2*         = BUSCTRL_BASE + 020H;
    BUSCTRL_PERFCTR3*         = BUSCTRL_BASE + 024H;
    BUSCTRL_PERFSEL3*         = BUSCTRL_BASE + 028H;

    (* PERFSEL events *)
    PERFSEL_APB_ACC_CONT*       = 00AH;
    PERFSEL_APB_ACC*            = 00BH;
    PERFSEL_FASTPERI_ACC_CONT*  = 00EH;
    PERFSEL_FASTPERI_ACC*       = 00FH;

    PERFSEL_SRAM9_ACC_CONT*     = 012H;
    PERFSEL_SRAM9_ACC*          = 013H;
    PERFSEL_SRAM8_ACC_CONT*     = 016H;
    PERFSEL_SRAM8_ACC*          = 017H;
    PERFSEL_SRAM7_ACC_CONT*     = 01AH;
    PERFSEL_SRAM7_ACC*          = 01BH;
    PERFSEL_SRAM6_ACC_CONT*     = 01EH;
    PERFSEL_SRAM6_ACC*          = 01FH;
    PERFSEL_SRAM5_ACC_CONT*     = 022H;
    PERFSEL_SRAM5_ACC*          = 023H;
    PERFSEL_SRAM4_ACC_CONT*     = 026H;
    PERFSEL_SRAM4_ACC*          = 027H;
    PERFSEL_SRAM3_ACC_CONT*     = 02AH;
    PERFSEL_SRAM3_ACC*          = 02BH;
    PERFSEL_SRAM2_ACC_CONT*     = 02EH;
    PERFSEL_SRAM2_ACC*          = 02FH;
    PERFSEL_SRAM1_ACC_CONT*     = 032H;
    PERFSEL_SRAM1_ACC*          = 033H;
    PERFSEL_SRAM0_ACC_CONT*     = 036H;
    PERFSEL_SRAM0_ACC*          = 037H;

    PERFSEL_XIP_MAIN1_ACC_CONT* = 03AH;
    PERFSEL_XIP_MAIN1_ACC*      = 03BH;
    PERFSEL_XIP_MAIN0_ACC_CONT* = 03EH;
    PERFSEL_XIP_MAIN0_ACC*      = 03FH;

    PERFSEL_ROM_ACC_CONT*       = 042H;
    PERFSEL_ROM_ACC*            = 043H;


    (* == UART0, UART1 == *)
    (* datasheet 12.1.8, p958 *)
    (* offsets from UART0_BASE, UART1_BASE *)
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

    (* == SPI0, SPI1 == *)
    (* datasheet 12.3.5, p1046 *)
    (* offsets from SPI0_BASE, SPI1_BASE *)
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

    (* == I2C0, I2C1 == *)
    (* datasheet 12.2.17, p994 *)
    (* offsets from I2C0_BASE, I2C1_BASE *)
    I2C_CON_Offset*                 = 000H;
    I2C_TAR_Offset*                 = 004H;
    I2C_SAR_Offset*                 = 008H;
    I2C_DATA_CMD_Offset*            = 010H;
    I2C_SS_SCL_HCNT_Offset*         = 014H;
    I2C_SS_SCL_LCNT_Offset*         = 018H;
    I2C_FS_SCL_HCNT_Offset*         = 01CH;
    I2C_FS_SCL_LCNT_Offset*         = 020H;
    I2C_INTR_STAT_Offset*           = 02CH;
    I2C_INTR_MASK_Offset*           = 030H;
    I2C_RAW_INTR_STAT_Offset*       = 034H;
    I2C_RX_TL_Offset*               = 038H;
    I2C_TX_TL_Offset*               = 03CH;
    I2C_CLR_INTR_Offset*            = 040H;
    I2C_CLR_RX_UNDER_Offset*        = 044H;
    I2C_CLR_RX_OVER_Offset*         = 048H;
    I2C_CLR_TX_OVER_Offset*         = 04CH;
    I2C_CLR_RD_REQ_Offset*          = 050H;
    I2C_CLR_TX_ABRT_Offset*         = 054H;
    I2C_CLR_RX_DONE_Offset*         = 058H;
    I2C_CLR_ACTIVITY_Offset*        = 05CH;
    I2C_CLR_STOP_DET_Offset*        = 060H;
    I2C_CLR_START_DET_Offset*       = 064H;
    I2C_CLR_GEN_CALL_Offset*        = 068H;
    I2C_ENABLE_Offset*              = 06CH;
    I2C_STATUS_Offset*              = 070H;
    I2C_TXFLR_Offset*               = 074H;
    I2C_RXFLR_Offset*               = 078H;
    I2C_SDA_HOLD_Offset*            = 07CH;
    I2C_TX_ABRT_SOURCE_Offset*      = 080H;
    I2C_SLV_DATA_NACK_ONLY_Offset*  = 084H;
    I2C_DMA_CR_Offset*              = 088H;
    I2C_DMA_TDLR_Offset*            = 08CH;
    I2C_DMA_RDLR_Offset*            = 090H;
    I2C_SDA_SETUP_Offset*           = 094H;
    I2C_ACK_GENERAL_CALL_Offset*    = 098H;
    I2C_ENABLE_STATUS_Offset*       = 09CH;
    I2C_FS_SPKLEN_Offset*           = 0A0H;
    I2C_CLR_RESTART_DET_Offset*     = 0A8H;
    I2C_COMP_PARAM_1_Offset*        = 0F4H;
    I2C_COMP_VERSION_Offset*        = 0F8H;
    I2C_COMP_TYPE_Offset*           = 0FCH;

    (* == ADC == *)
    (* datasheet 12.4.7, p1059 *)
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
    (* datasheet 12.5.3, p1072 *)
    PWM_CH0_CSR*  = PWM_BASE;
    PWM_CH0_DIV*  = PWM_BASE + 004H;
    PWM_CH0_CTR*  = PWM_BASE + 008H;
    PWM_CH0_CC*   = PWM_BASE + 00CH;
    PWM_CH0_TOP*  = PWM_BASE + 010H;
      (* CH0 .. CH11 *)
      (* block offset *)
      PWM_CH_Offset*  = 014H;
      (* block register offsets *)
      PWM_CSR_Offset* = 000H;
      PWM_DIV_Offset* = 004H;
      PWM_CTR_Offset* = 008H;
      PWM_CC_Offset*  = 00CH;
      PWM_TOP_Offset* = 010H;

    PWM_EN*         = PWM_BASE + 00F0H;
    PWM_INTR*       = PWM_BASE + 00F4H;
    PWM_IRQ0_INTE*  = PWM_BASE + 00F8H;
    PWM_IRQ0_INTF*  = PWM_BASE + 00FCH;
    PWM_IRQ0_INTS*  = PWM_BASE + 0100H;
    PWM_IRQ1_INTE*  = PWM_BASE + 0104H;
    PWM_IRQ1_INTF*  = PWM_BASE + 0108H;
    PWM_IRQ1_INTS*  = PWM_BASE + 010CH;

    (* == TIMER0, TIMER1 == *)
    (* datasheet 12.8.5, p1173 *)
    (* offsets from TIMER0_BASE, TIMER1_BASE *)
    TIMER_Offset*           = TIMER1_BASE - TIMER0_BASE;
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

    (* == HSTX_CTRL: high speed serial transmit == *)
    (* datasheet 12.11.8, p1193 *)
    HSTX_CTRL_CSR*          = HSTX_CTRL_BASE;

    HSTX_CTRL_BIT0*     = HSTX_CTRL_BASE + 004H;
    HSTX_CTRL_BIT1*     = HSTX_CTRL_BASE + 008H;
    HSTX_CTRL_BIT2*     = HSTX_CTRL_BASE + 00CH;
    HSTX_CTRL_BIT3*     = HSTX_CTRL_BASE + 010H;
    HSTX_CTRL_BIT4*     = HSTX_CTRL_BASE + 014H;
    HSTX_CTRL_BIT5*     = HSTX_CTRL_BASE + 018H;
    HSTX_CTRL_BIT6*     = HSTX_CTRL_BASE + 01CH;
    HSTX_CTRL_BIT7*     = HSTX_CTRL_BASE + 020H;
      HSTX_CTRL_BIT_Offset* = 4;

    HSTX_CTRL_EXPAND_SHIFT* = HSTX_CTRL_BASE + 024H;
    HSTX_CTRL_EXPAND_TMDS*  = HSTX_CTRL_BASE + 028H;

    (* == XIP_CTRL == *)
    (* datasheet 4.4.5, p339 *)
    XIP_CTRL*             = XIP_CTRL_BASE;
    XIP_STAT*             = XIP_CTRL_BASE + 008H;
    XIP_CTR_HIT*          = XIP_CTRL_BASE + 00CH;
    XIP_CTR_ACC*          = XIP_CTRL_BASE + 010H;
    XIP_STREAM_ADDR*      = XIP_CTRL_BASE + 014H;
    XIP_STREAM_CTR*       = XIP_CTRL_BASE + 018H;
    XIP_STREAM_FIFO*      = XIP_CTRL_BASE + 01CH;

    (* == XIP_QMI == *)
    (* datasheet 12.14.6, p1221 *)
    QMI_DIRECT_CSR*   = XIP_QMI_BASE;
    (* .. *)

    (* == WATCHDOG == *)
    (* datasheet 12.9.7, p1181 *)
    WATCHDOG_CTRL*      = WATCHDOG_BASE;
    WATCHDOG_LOAD*          = WATCHDOG_BASE + 004H;
    WATCHDOG_REASON*        = WATCHDOG_BASE + 008H;

    WATCHDOG_SCRATCH0*  = WATCHDOG_BASE + 00CH;
    WATCHDOG_SCRATCH1*  = WATCHDOG_BASE + 010H;
    WATCHDOG_SCRATCH2*  = WATCHDOG_BASE + 014H;
    WATCHDOG_SCRATCH3*  = WATCHDOG_BASE + 018H;
    WATCHDOG_SCRATCH4*  = WATCHDOG_BASE + 01CH;
    WATCHDOG_SCRATCH5*  = WATCHDOG_BASE + 020H;
    WATCHDOG_SCRATCH6*  = WATCHDOG_BASE + 024H;
    WATCHDOG_SCRATCH7*  = WATCHDOG_BASE + 028H;
      WATCHDOG_SCRATCH_Offset* = 4;

    (* == BOOTRAM == *)
    (* datasheet 4.3.1, p432 *)
    BOOTRAM_WRITE_ONCE0*  = BOOTRAM_BASE + 0800H;
    (* .. *)

    (* == ROSC == *)
    (* datasheet 8.3.10. p553 *)
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

    (* == TRNG: true random number generator == *)
    (* datasheet 12.12.5, p1200 *)
    TRNG_IMR* = TRNG_BASE + 0100H;
    (* .. *)

    (* == SHA256 == *)
    (* datasheet 12.13.5, p1208 *)
    SHA256_CSR*       = SHA256_BASE;
    SHA256_WDATA*     = SHA256_BASE + 004H;

    SHA256_SUM0*      = SHA256_BASE + 008H;
    SHA256_SUM1*      = SHA256_BASE + 00CH;
    SHA256_SUM2*      = SHA256_BASE + 010H;
    SHA256_SUM3*      = SHA256_BASE + 014H;
    SHA256_SUM4*      = SHA256_BASE + 018H;
    SHA256_SUM5*      = SHA256_BASE + 01CH;
    SHA256_SUM6*      = SHA256_BASE + 020H;
    SHA256_SUM7*      = SHA256_BASE + 024H;
      SHA256_SUM_Offset* = 4;

    (* == POWMAN == *)
    (* datasheet 6.4, p446 *)
    POWMAN_BADPASSWD* = POWMAN_BASE;
    (* .. *)

    (* == TICKS == *)
    (* datasheet 8.5.2, p559 *)
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

    (* == OTP == *)
    (* datasheet 13.8, p1264 *)
    OTP_SW_LOCK0*   = OTP_BASE;
      (* 0 .. 63 *)
      OTP_SW_LOCK_Offset* = 4;

    (* .. *)

    (* == GLITCH_DETECTOR == *)
    (* datasheet 10.9.3, p857 *)
    GLITCH_DETECTOR_ARM*          = GLITCH_DETECTOR_BASE;
    GLITCH_DETECTOR_DISARM*       = GLITCH_DETECTOR_ARM + 004H;
    GLITCH_DETECTOR_SENSITIVITY*  = GLITCH_DETECTOR_BASE + 008H;
    GLITCH_DETECTOR_LOCK*         = GLITCH_DETECTOR_BASE + 00CH;
    GLITCH_DETECTOR_TRIG_STATUS*  = GLITCH_DETECTOR_BASE + 010H;
    GLITCH_DETECTOR_TRIG_FORCE*   = GLITCH_DETECTOR_BASE + 014H;


    (* == TBMAN == *)
    (* datasheet 12.15.3, p1239 *)
    TBMAN_PLATFORM* = TBMAN_BASE;

  (* ===== AHB: Advanced High-performance Bus ===== *)

    (* == DMA == *)
    (* datasheet 12.6.10, p1098 *)
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
      (* CH0 .. CH15 *)
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

    DMA_INTR*           = DMA_BASE + 0400H;
    DMA_INTE0*          = DMA_BASE + 0404H;
    DMA_INTF0*          = DMA_BASE + 0408H;
    DMA_INTS0*          = DMA_BASE + 040CH;
    DMA_INTE1*          = DMA_BASE + 0414H;
    DMA_INTF1*          = DMA_BASE + 0418H;
    DMA_INTS1*          = DMA_BASE + 041CH;
    DMA_INTE2*          = DMA_BASE + 0424H;
    DMA_INTF2*          = DMA_BASE + 0428H;
    DMA_INTS2*          = DMA_BASE + 042CH;
    DMA_INTE3*          = DMA_BASE + 0434H;
    DMA_INTF3*          = DMA_BASE + 0438H;
    DMA_INTS3*          = DMA_BASE + 043CH;

    DMA_TIMER0*         = DMA_BASE + 0440H;
    DMA_TIMER1*         = DMA_BASE + 0444H;
    DMA_TIMER2*         = DMA_BASE + 0448H;
    DMA_TIMER3*         = DMA_BASE + 044CH;

    DMA_MULTI_CHAN_TRIGGER* = DMA_BASE + 0450H;
    DMA_SNIFF_CTRL*     = DMA_BASE + 0454H;
    DMA_SNIFF_DATA*     = DMA_BASE + 0458H;
    DMA_FIFO_LEVELS*    = DMA_BASE + 0460H;
    DMA_CHAN_ABORT*     = DMA_BASE + 0464H;
    DMA_N_CHANNELS*     = DMA_BASE + 0468H;

    DMA_SECCFG_CH0*     = DMA_BASE + 0480H;
      (* CH0 .. CH15 *)
      (* block offset *)
      DMA_SECCFG_CH_Offset* = 4;

    DMA_SECCFG_IRQ0*    = DMA_BASE + 04C0H;
    DMA_SECCFG_IRQ1*    = DMA_BASE + 04C0H;
    DMA_SECCFG_IRQ2*    = DMA_BASE + 04C0H;
    DMA_SECCFG_IRQ3*    = DMA_BASE + 04C0H;
      DMA_DECCFG_IRQ_Offset* = 4;

    DMA_SECCFG_MISC*    = DMA_BASE + 04D0H;

    DMA_MPU_CTRL*       = DMA_BASE + 0500H;

    DMA_MPU_BAR0*       = DMA_BASE + 0504H;
    DMA_MPU_LAR0*       = DMA_BASE + 0508H;
      (* BAR0/LAR0 .. BAR7/LAR7 *)
      (* block offset *)
      DMA_MPU_Offset* = 8;
      (* block register offsets *)
      DMA_MPU_BAR_Offset* = 0;
      DMA_MPU_LAR_Offset* = 4;

    DMA_CH0_DBG_CTDREQ* = DMA_BASE + 0800H;
    DMA_CH0_DBG_TCR*    = DMA_BASE + 0804H;
      (* CH0 .. CH15 *)
      (* block offset *)
      DMA_CH_DBG_Offset* = 040H;
      (* block register offsets *)
      DMA_CH_DBG_CTDREQ_Offset* = 0;
      DMA_CH_DBG_TCR_Offset*    = 4;

    (* DREQ *)
    (* ... *)

    (* == USBCTRL == *)
    (* == USBCTRL_DPRAM == *)
    (* == USB_CTRL_REGS == *)

    (* == PIO0, PIO1, PIO2 == *)
    (* datasheet 11.7, p925 *)
    (* offsets from PIO0_BASE, PIO1_BASE, PIO2_BASE *)
    PIO_Offset*                   = PIO1_BASE - PIO0_BASE;
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

    PIO_SM0_Offset*               = 00C8H;
    PIO_SM0_CLKDIV_Offset*        = PIO_SM0_Offset;
    PIO_SM0_EXECCTRL_Offset*      = 00CCH;
    PIO_SM0_SHIFTCTRL_Offset*     = 00D0H;
    PIO_SM0_ADDR_Offset*          = 00D4H;
    PIO_SM0_INSTR_Offset*         = 00D8H;
    PIO_SM0_PINCTRL_Offset*       = 00DCH;
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

    PIO_RXF0_PUTGET0_Offset*      = 0128H;
    PIO_RXF0_PUTGET1_Offset*      = 012CH;
    PIO_RXF0_PUTGET2_Offset*      = 0130H;
    PIO_RXF0_PUTGET3_Offset*      = 0134H;
      (* RXF0 .. RXF3 *)
      (* block offset *)
      PIO_RXF_Offset* = 010H;
      (* block register offsets *)
      PIO_RXF_PUTGET0_Offset* = 000H;
      PIO_RXF_PUTGET1_Offset* = 004H;
      PIO_RXF_PUTGET2_Offset* = 008H;
      PIO_RXF_PUTGET3_Offset* = 00CH;

    PIO_GPIOBASE_Offset*        = 0168H;
    PIO_INTR_Offset*            = 016CH;
    PIO_IRQ0_INTE_Offset*       = 0170H;
    PIO_IRQ0_INTF_Offset*       = 0174H;
    PIO_IRQ0_INTS_Offset*       = 0178H;
    PIO_IRQ1_INTE_Offset*       = 017CH;
    PIO_IRQ1_INTF_Offset*       = 0180H;
    PIO_IRQ1_INTS_Offset*       = 0184H;

    (* == XIP_AUX == *)
    (* datasheet 4.4.6, p343 *)
    XIP_AUX_STREAM*           = XIP_AUX_BASE;
    XIP_AUX__QMI_DIRECT_TX*   = XIP_AUX_BASE + 004H;
    XIP_AUX__QMI_DIRECT_RX*   = XIP_AUX_BASE + 008H;

    (* == HSTX_FIFO == *)
    (* datasheet 12.11.8, p1197 *)
    HSTX_FIFO_STAT* = HSTX_FIFO_BASE;
    HSTX_FIFO_FIFO* = HSTX_FIFO_BASE + 004H;

    (* == CORESIGHT_TRACE == *)

    (*** core-local ***)

    (* == SIO == *)
    (* datasheet 3.1.11, p54 *)
    SIO_CPUID*              = SIO_BASE;
    SIO_GPIO_IN*            = SIO_BASE + 00004H;
    SIO_GPIO_HI_IN*         = SIO_BASE + 00008H;
    SIO_GPIO_OUT*           = SIO_BASE + 00010H;
    SIO_GPIO_HI_OUT*        = SIO_BASE + 00014H;
    SIO_GPIO_OUT_SET*       = SIO_BASE + 00018H;
    SIO_GPIO_HI_OUT_SET*    = SIO_BASE + 0001CH;
    SIO_GPIO_OUT_CLR*       = SIO_BASE + 00020H;
    SIO_GPIO_HI_OUT_CLR*    = SIO_BASE + 00024H;
    SIO_GPIO_OUT_XOR*       = SIO_BASE + 00028H;
    SIO_GPIO_HI_OUT_XOR*    = SIO_BASE + 0002CH;
    SIO_GPIO_OE*            = SIO_BASE + 00030H;
    SIO_GPIO_HI_OE*         = SIO_BASE + 00034H;
    SIO_GPIO_OE_SET*        = SIO_BASE + 00038H;
    SIO_GPIO_HI_OE_SET*     = SIO_BASE + 0003CH;
    SIO_GPIO_OE_CLR*        = SIO_BASE + 00040H;
    SIO_GPIO_HI_OE_CLR*     = SIO_BASE + 00044H;
    SIO_GPIO_OE_XOR*        = SIO_BASE + 00048H;
    SIO_GPIO_HI_OE_XOR*     = SIO_BASE + 0004CH;
    SIO_FIFO_ST*            = SIO_BASE + 00050H;
    SIO_FIFO_WR*            = SIO_BASE + 00054H;
    SIO_FIFO_RD*            = SIO_BASE + 00058H;
    SIO_SPINLOCK_ST*        = SIO_BASE + 0005CH;

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

    SIO_DOORBELL_OUT_SET*     = SIO_BASE + 00180H;
    SIO_DOORBELL_OUT_CLR*     = SIO_BASE + 00184H;
    SIO_DOORBELL_IN_SET*      = SIO_BASE + 00188H;
    SIO_DOORBELL_IN_CLR*      = SIO_BASE + 0018CH;
    SIO_PERI_NONSEC*          = SIO_BASE + 00190H;
    SIO_RISCV_SOFTIRQ*        = SIO_BASE + 001A0H;
    SIO_MTIME_CTRL*           = SIO_BASE + 001A4H;
    SIO_MTIME*                = SIO_BASE + 001B0H;
    SIO_MTIMEH*               = SIO_BASE + 001B4H;
    SIO_MTIMECMP*             = SIO_BASE + 001B8H;
    SIO_MTIMECMPH*            = SIO_BASE + 001BCH;
    SIO_TMDS_CTRL*            = SIO_BASE + 001C0H;
    SIO_TMDS_WDATA*           = SIO_BASE + 001C4H;
    SIO_TMDS_PEEK_SINGLE*     = SIO_BASE + 001C8H;
    SIO_TMDS_POP_SINGLE*      = SIO_BASE + 001CCH;
    SIO_TMDS_PEEK_DOUBLE_L0*  = SIO_BASE + 001D0H;
    SIO_TMDS_POP_DOUBLE_L0*   = SIO_BASE + 001D4H;
    SIO_TMDS_PEEK_DOUBLE_L1*  = SIO_BASE + 001D8H;
    SIO_TMDS_POP_DOUBLE_L1*   = SIO_BASE + 001DCH;
    SIO_TMDS_PEEK_DOUBLE_L2*  = SIO_BASE + 001E0H;
    SIO_TMDS_POP_DOUBLE_L2*   = SIO_BASE + 001E4H;


  (* ===== PPB: processor private bus ===== *)

    (* datasheet 3.7.5, p141 *)
    PPB_NONSEC_Offset*  = 020000H;

    (* -- ITM: instrumentation trace macrocell -- *)
    PPB_ITM_STIM0*    = PPB_BASE;
      (* STIM0 .. STIM 31 *)
      (* block offset *)
      PPB_ITM_STIM_Offset* = 4;

    PPB_ITM_TER0*     = PPB_BASE + 00E00H;
    PPB_ITM_TPR*      = PPB_BASE + 00E40H;
    PPB_ITM_TCR*      = PPB_BASE + 00E80H;
    PPB_INT_ATREADY*  = PPB_BASE + 00EF0H;
    PPB_INT_ATVALID*  = PPB_BASE + 00EF8H;
    PPB_ITCTRL*       = PPB_BASE + 00F00H;
    PPB_ITM_DEVARCH*  = PPB_BASE + 00FBCH;
    PPB_ITM_DEVTYPE*  = PPB_BASE + 00FCCH;
    (* .. *)

    (* -- DWT: data watchpoint and trace -- *)
    PPB_DWT_CTRL*     = PPB_BASE + 01000H;
    PPB_DWT_CYCCNT*   = PPB_BASE + 01004H;
    PPB_DWT_EXCCNT*   = PPB_BASE + 0100CH;
    (* .. *)

    (* -- FPB: flash patch and breakpoint -- *)
    PPB_FP_CTRL*      = PPB_BASE + 02000H;
    (* .. *)

    (* -- implementation control block -- *)
    PPB_ICTR*         = PPB_BASE + 0E004H;
    PPB_ACTLR*        = PPB_BASE + 0E008H;

    (* -- SysTick -- *)
    PPB_SYST_CSR*     = PPB_BASE + 0E010H;
    PPB_SYST_RVR*     = PPB_BASE + 0E014H;
    PPB_SYST_CVR*     = PPB_BASE + 0E018H;
    PPB_SYST_CALIB*   = PPB_BASE + 0E01CH;

    (* -- NVIC -- *)
    PPB_NVIC_ISER0*   = PPB_BASE + 0E100H;
    PPB_NVIC_ISER1*   = PPB_BASE + 0E104H;

    PPB_NVIC_ICER0*    = PPB_BASE + 0E180H;
    PPB_NVIC_ICER1*    = PPB_BASE + 0E184H;

    PPB_NVIC_ISPR0*   = PPB_BASE + 0E200H;
    PPB_NVIC_ISPR1*   = PPB_BASE + 0E204H;

    PPB_NVIC_ICPR0*   = PPB_BASE + 0E280H;
    PPB_NVIC_ICPR1*   = PPB_BASE + 0E284H;

    PPB_NVIC_IABR0*   = PPB_BASE + 0E300H;
    PPB_NVIC_IABR1*   = PPB_BASE + 0E304H;

    PPB_NVIC_ITNS0*   = PPB_BASE + 0E380H;
    PPB_NVIC_ITNS1*   = PPB_BASE + 0E384H;

    PPB_NVIC_IPR0*    = PPB_BASE + 0E400H;
    PPB_NVIC_IPR1*    = PPB_BASE + 0E404H;
    PPB_NVIC_IPR2*    = PPB_BASE + 0E408H;
    PPB_NVIC_IPR3*    = PPB_BASE + 0E40CH;
    PPB_NVIC_IPR4*    = PPB_BASE + 0E410H;
    PPB_NVIC_IPR5*    = PPB_BASE + 0E414H;
    PPB_NVIC_IPR6*    = PPB_BASE + 0E418H;
    PPB_NVIC_IPR7*    = PPB_BASE + 0E41CH;
    PPB_NVIC_IPR8*    = PPB_BASE + 0E420H;
    PPB_NVIC_IPR9*    = PPB_BASE + 0E424H;
    PPB_NVIC_IPR10*   = PPB_BASE + 0E428H;
    PPB_NVIC_IPR11*   = PPB_BASE + 0E42CH;
    PPB_NVIC_IPR12*   = PPB_BASE + 0E430H;
    PPB_NVIC_IPR13*   = PPB_BASE + 0E434H;
    PPB_NVIC_IPR14*   = PPB_BASE + 0E438H;
    PPB_NVIC_IPR15*   = PPB_BASE + 0E43CH;

    (* IRQ numbers *)
    (* datasheet 3.2, p83 *)
    PPB_TIMER0_IRQ_0*      = 0;
    PPB_TIMER0_IRQ_1*      = 1;
    PPB_TIMER0_IRQ_2*      = 2;
    PPB_TIMER0_IRQ_3*      = 3;
    PPB_TIMER1_IRQ_0*      = 4;
    PPB_TIMER2_IRQ_1*      = 5;
    PPB_TIMER3_IRQ_2*      = 6;
    PPB_TIMER4_IRQ_3*      = 7;
    PPB_PWM_IRQ_WRAP_0*    = 8;
    PPB_PWM_IRQ_WRAP_1*    = 9;
    PPB_DMA_IRQ_0*         = 10;
    PPB_DMA_IRQ_1*         = 11;
    PPB_DMA_IRQ_2*         = 12;
    PPB_DMA_IRQ_3*         = 13;
    PPB_USBCTRL_IRQ*       = 14;
    PPB_PIO0_IRQ_0*        = 15;
    PPB_PIO0_IRQ_1*        = 16;
    PPB_PIO1_IRQ_0*        = 17;
    PPB_PIO1_IRQ_1*        = 18;
    PPB_PIO2_IRQ_0*        = 19;
    PPB_PIO2_IRQ_1*        = 20;
    PPB_IO_IRQ_BANK0*      = 21; (* core local *)
    PPB_IO_IRQ_BANK0_NS*   = 22; (* core local *)
    PPB_IO_IRQ_QSPI*       = 23; (* core local *)
    PPB_IO_IRQ_QSPI_NS*    = 24; (* core local *)
    PPB_SIO_IRQ_FIFO*      = 25; (* core local *)
    PPB_SIO_IRQ_BELL*      = 26; (* core local *)
    PPB_SIO_IRQ_FIFO_NS*   = 27; (* core local *)
    PPB_SIO_IRQ_BELL_NS*   = 28; (* core local *)
    PPB_SIO_IRQ_MTIMECMP*  = 29; (* core local *)
    PPB_CLOCKS_IRQ*        = 30;
    PPB_SPI0_IRQ*          = 31;
    PPB_SPI1_IRQ*          = 32;
    PPB_UART0_IRQ*         = 33;
    PPB_UART1_IRQ*         = 34;
    PPB_ADC_IRQ_FIFO*      = 35;
    PPB_I2C0_IRQ*          = 36;
    PPB_I2C1_IRQ*          = 37;
    PPB_OTP_IRQ*           = 38;
    PPB_TRNG_IRQ*          = 39;
    PPB_PROC0_IRQ_CTI*     = 40;
    PPB_PROC1_IRQ_CTI*     = 41;
    PPB_PLL_SYS_IRQ*       = 42;
    PPB_PLL_USB_IRQ*       = 43;
    PPB_POWMAN_IRQ_POW*    = 44;
    PPB_POWMAN_IRQ_TIMER*  = 45;
    PPB_SPAREIRQ_IRQ0*     = 46;
    PPB_SPAREIRQ_IRQ1*     = 47;
    PPB_SPAREIRQ_IRQ2*     = 48;
    PPB_SPAREIRQ_IRQ3*     = 49;
    PPB_SPAREIRQ_IRQ4*     = 50;
    PPB_SPAREIRQ_IRQ5*     = 51;

    (* IRQ exception numbers *)
    (* exception number = IRQ number + PPB_IRQ_BASE *)
    PPB_IRQ_BASE* = 16;

    (* exception numbers *)
    PPB_NMI_Exc*           = 2;
    PPB_HardFault_Exc*     = 3;
    PPB_MemMgmtFault_Exc*  = 4;
    PPB_BusFault_Exc*      = 5;
    PPB_UsageFault_Exc*    = 6;
    PPB_SecureFault_Exc*   = 7;
    PPB_SVC_Exc*           = 11;
    PPB_DebugMon_Exc*      = 12;
    PPB_PendSV_Exc*        = 14;
    PPB_SysTick_Exc*       = 15;

    PPB_SysExc*  = {3, 4, 5, 6, 7, 11, 14, 15};

    PPB_ExcPrio0* = 000H; (* 0000 0000 *)
    PPB_ExcPrio1* = 020H; (* 0010 0000 *)
    PPB_ExcPrio2* = 040H; (* 0100 0000 *)
    PPB_ExcPrio3* = 060H; (* 0110 0000 *)
    PPB_ExcPrio4* = 080H; (* 1000 0000 *)
    PPB_ExcPrio5* = 0A0H; (* 1010 0000 *)
    PPB_ExcPrio6* = 0C0H; (* 1100 0000 *)
    PPB_ExcPrio7* = 0E0H; (* 1110 0000 *)

    (* vector table *)
    VectorTableSize*            = 272; (* bytes, 16 sys exceptions + 52 interrupts, one word each *)
    ResetHandlerOffset*         = 004H;
    NMIhandlerOffset*           = 008H;
    HardFaultHandlerOffset*     = 00CH;
    MemMgmtFaultHandlerOffset*  = 010H;
    BusFaultHandlerOffset*      = 014H;
    UsageFaultHandlerOffset*    = 018H;
    SecureFaultHandlerOffset*   = 01CH;
    SVChandlerOffset*           = 02CH;
    DebugMonitorOffset*         = 030H;
    PendSVhandlerOffset*        = 038H;
    SysTickHandlerOffset*       = 03CH;

    (* -- SCB -- *)
    (* 0ECFCH *)
    PPB_CPUID*        = PPB_BASE + 0ED00H;
    PPB_ICSR*         = PPB_BASE + 0ED04H;
    PPB_VTOR*         = PPB_BASE + 0ED08H;
    PPB_AIRCR*        = PPB_BASE + 0ED0CH;
    PPB_SCR*          = PPB_BASE + 0ED10H;
    PPB_CCR*          = PPB_BASE + 0ED14H;

    PPB_SHPR1*        = PPB_BASE + 0ED18H;
    PPB_SHPR2*        = PPB_BASE + 0ED1CH;
    PPB_SHPR3*        = PPB_BASE + 0ED20H;

    PPB_SHCSR*        = PPB_BASE + 0ED24H;

    PPB_CFSR*         = PPB_BASE + 0ED28H;
    PPB_HFSR*         = PPB_BASE + 0ED2CH;
    PPB_DFSR*         = PPB_BASE + 0ED30H;
    PPB_MMFAR*        = PPB_BASE + 0ED34H;
    PPB_BFAR*         = PPB_BASE + 0ED38H;
    (* PPB_ID... *)
    PPB_CPACR*        = PPB_BASE + 0ED88H;
    PPB_NSACR*        = PPB_BASE + 0ED8CH;


    (* -- MPU -- *)
    PPB_MPU_TYPE*     = PPB_BASE + 0ED90H;
    PPB_MPU_CTRL*     = PPB_BASE + 0ED94H;
    PPB_MPU_RNR*      = PPB_BASE + 0ED98H;
    PPB_MPU_RBAR*     = PPB_BASE + 0ED9CH;
    PPB_MPU_RLAR*     = PPB_BASE + 0EDA0H;
    PPB_MPU_RBAR_A1*  = PPB_BASE + 0EDA4H;
    PPB_MPU_RLAR_A1*  = PPB_BASE + 0EDA8H;
    PPB_MPU_RBAR_A2*  = PPB_BASE + 0EDACH;
    PPB_MPU_RLAR_A2*  = PPB_BASE + 0EDB0H;
    PPB_MPU_RBAR_A3*  = PPB_BASE + 0EDB4H;
    PPB_MPU_RLAR_A3*  = PPB_BASE + 0EDB8H;
    PPB_MPU_MAIR0*    = PPB_BASE + 0EDC0H;
    PPB_MPU_MAIR1*    = PPB_BASE + 0EDC4H;

    (* -- SAU security attribution unit -- *)
    PPB_SAU_CTRL*     = PPB_BASE + 0EDD0H;
    PPB_SAU_TYPE*     = PPB_BASE + 0EDD4H;
    PPB_SAU_RNR*      = PPB_BASE + 0EDD8H;
    PPB_SAU_RBAR*     = PPB_BASE + 0EDDCH;
    PPB_SAU_RLAR*     = PPB_BASE + 0EDE0H;
    PPB_SFSR*         = PPB_BASE + 0EDE4H;
    PPB_SFAR*         = PPB_BASE + 0EDE8H;

    (* -- debug control block -- *)
    PPB_DHCSR*        = PPB_BASE + 0EDF0H;
    (* ... *)

    (* -- sw interrupt generation -- *)
    PPB_STIR*         = PPB_BASE + 0EF00H;

    (* -- FPU floating point extension -- *)
    PPB_FPCCR*        = PPB_BASE + 0EF34H;
    PPB_FPCAR*        = PPB_BASE + 0EF38H;
    PPB_FPDSCR*       = PPB_BASE + 0EF3CH;
    (* .. *)

    (* -- debug identifiation block -- *)
    PPB_DDEVARCH*     = PPB_BASE + 0EFBCH;
    (* .. *)

    (* -- TPIU trace port identification unit -- *)
    (* 040000H *)

    (* -- ETM embedded trace macrocell -- *)
    PPB_TRCPRGCTRL*   = PPB_BASE + 041004H;

    (* -- CTI cross trigger interface -- *)
    PPB_CTICONTROL*   = PPB_BASE + 042000H;
    (* .. *)

    (* -- MTB micro trace buffer -- *)
    (* 043000H *)

    (* == EPPB == *)
    EPPB_NMI_MASK0*   = EPPB_BASE;
    EPPB_NMI_MASK1*   = EPPB_BASE + 04H;
    EPPB_SLEEPCTRL*   = EPPB_BASE + 08H;

    (* RP2040 compatibility aliases *)
    SYSCFG_PROC0_NMI_MASK* = EPPB_NMI_MASK0;
    SYSCFG_PROC1_NMI_MASK* = EPPB_NMI_MASK1;


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
    MRS_R00_MSP*  = 0F3EF8008H;  (* move MSP to r0 *)

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

    (* disable/enable interrupts via PRIMASK *)
    CPSIE* = 0B662H; (* enable: 1011 0110 0110 0010 *)
    CPSID* = 0B672H; (* disable: 1011 0110 0111 0010 *)

END MCU2.
