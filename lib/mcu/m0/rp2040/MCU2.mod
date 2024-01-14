MODULE MCU2;
(**
  Oberon RTK Framework
  MCU register addresses, bits, values
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  About the module name: I know that the forthcoming Astrobe with support
  for the RP2040 will most likely have a module 'MCU', so this just avoids
  any confusion and clash from the outset. :)
  --
  Note: all peripheral registers have these variants at different addresses:
  * addr + 0000H: normal read write access
  * addr + 1000H: atomic XOR on write
  * addr + 2000H: atomic bitmask set on write
  * addr + 3000H: atomic bitmask clear on write
  Not true for SIO, can't use there.
  Don't use for registers that work on a mask anyway, such as for NVIC.
  See datasheet 2.1., p18
  --
  Copyright (c) 2023 Gray gray@grayraven.org
**)

CONST
  (* add to register address to access their variants *)
  AXOR* = 01000H; (* atomic XOR on write *)
  ASET* = 02000H; (* atomic bitmask set on write *)
  ACLR* = 03000H; (* atomic bitmask clear on write *)

  (* as configured in Clocks.mod *)
  SysClkFreq*  = 125 * 1000000; (* from SYS PLL *)
  RefClkFreq*  =  48 * 1000000; (* from USB PLL *)
  PeriClkFreq* =  48 * 1000000; (* from USB PLL *)
  SysTickFreq* =   1 * 1000000; (* via clock divider in watchdog, from ref clock *)

  NumCores* = 2;

  (* === CPU registers *)
  (* CONTROL special register *)
  CONTROL_SPSEL* = 1; (* enable PSP *)

  (* === XIP ===*)
  (* chip level, config, not code execution address *)
  (* datasheet 2.6.3.6, p127 *)
  (* shared *)
  XIP_Base* = 014000000H; (* p127 *)
  XIP_CTRL* = XIP_Base;
  XIP_FLUSH* = XIP_Base + 040H;

  (* === bus fabric === *)
  (* datasheet 2.1.5, p19 *)
  (* shared *)
  BUSCTRL_Base* = 040030000H;
  BUSCTRL_BUS_PRIORITY*     = BUSCTRL_Base;
  BUSCTRL_BUS_PRIORITY_ACK* = BUSCTRL_Base + 04H;


  (* === system info and config === *)
  (* chip level, shared *)
  (* note: these are peripherals that need a reset release *)
  (* sys info *)
  (* datasheet 2.20, p303 *)
  SYSINFO_Base* = 040000000H;
  SYSINFO_CHIP_ID*        = SYSINFO_Base;
  SYSINFO_PLATFORM*       = SYSINFO_Base + 004H;
  SYSINFO_GITREF_RP2040*  = SYSINFO_Base + 008H;

  (* sys cfg *)
  (* datasheet 2.21, p204 *)
  SYSCFG_Base* = 040004000H;
  SYSCFG_PROC0_NMI_MASK*          = SYSCFG_Base;
  SYSCFG_PROC1_NMI_MASK*          = SYSCFG_Base + 004H;
  SYSCFG_PROC_CONFIG*             = SYSCFG_Base + 008H;
  SYSCFG_PROC_IN_SYNC_BYPASS*     = SYSCFG_Base + 00CH;
  SYSCFG_PROC_IN_SYNC_BYPASS_HI*  = SYSCFG_Base + 010H;
  SYSCFG_DBGFORCE*                = SYSCFG_Base + 014H;
  SYSCFG_MEMPOWERDOWN*            = SYSCFG_Base + 018H;


  (* === system control space === *)
  (* registers are core-specific, ie. not shared *)
  PPB_Base* = 0E0000000H; (* private peripheral bus *)
  (* sys tick *)
  (* datasheet 2.4.5.1.1, p75 *)
  (* datasheet 2.4.8, p77 *)
  SYST_Base* = PPB_Base + 0E010H;
  SYST_CSR*   = SYST_Base;
  SYST_RVR*   = SYST_Base + 04H;
  SYST_CVR*   = SYST_Base + 08H;
  SYST_CALIB* = SYST_Base + 0CH;

  (* NVIC *)
  (* datasheet 2.4.5.2, p75 *)
  (* datasheet 2.4.8, p77 *)
  NVIC_Base* = PPB_Base + 0E100H;
  NVIC_ISER* = NVIC_Base;
  NVIC_ICER* = NVIC_Base + 0080H;
  NVIC_ISPR* = NVIC_Base + 0100H;
  NVIC_ICPR* = NVIC_Base + 0180H;
  NVIC_IPR*  = NVIC_Base + 0300H;

  (* system control block, SCB *)
  (* datasheet 2.4.4, p74 *)
  (* datasheet 2.4.8, p77 *)
  SCB_Base* = PPB_Base + 0ED00H;
  SCB_CPUID*  = SCB_Base;
  SCB_ICSR*   = SCB_Base + 004H;
  SCB_VTOR*   = SCB_Base + 008H;
  SCB_AIRCR*  = SCB_Base + 00CH;
  SCB_SCR*    = SCB_Base + 010H;
  SCB_CCR*    = SCB_Base + 014H;
  SCB_SHPR2*  = SCB_Base + 01CH;
  SCB_SHPR3*  = SCB_Base + 020H;
  SCB_SHCSR*  = SCB_Base + 024H;

  SCB_SHPR*   = SCB_Base + 018H; (* SCB_SHPR1 on eg. M3 *)

  (* memory protection, MPU *)
  (* datasheet 2.4.6.2, p76 *)
  MPU_Base* = PPB_Base + 0ED90H;
  MPU_TYPE* = MPU_Base;
  MPU_CTRL* = MPU_Base + 004H;
  MPU_RNR*  = MPU_Base + 008H;
  MPU_RBAR* = MPU_Base + 00CH;
  MPU_RASR* = MPU_Base + 010H;


  (* === exception handler vector table === *)
  (* each core can have its own vector table, set VTOR *)
  VectorTableSize*          = 192; (* 16 + 32 words *)
  ResetHandlerOffset*       = 004H;
  NMIhandlerOffset*         = 008H;
  HardFaultHandlerOffset*   = 00CH;
  SVChandlerOffset*         = 02CH;
  SysTickHandlerOffset*     = 03CH;
  MissingHandlerOffset*     = 038H;
  IrqZeroHandlerOffset*     = 040H;


  (* === DMA === *)
  (* datasheet 2.5, p91 *)
  (* datasheet 2.5.7, p102 *)
  (* shared *)
  DMA_Base* = 050000000H;
  DMA_CH0_READ_ADDR*    = DMA_Base;
  DMA_CH0_WRITE_ADDR*   = DMA_Base + 0004H;
  DMA_CH0_TRANS_COUNT*  = DMA_Base + 0008H;
  DMA_CH0_CTRL_TRIG*    = DMA_Base + 000CH;
  (* ... *)
  (* 4 registers per DMA channel, offset: 040H, range 0 to 11 *)
  (* ... *)
  DMA_CH_Offset*    = 040H;

  DMA_INTR*         = DMA_Base + 0400H;
  DMA_INTE0*        = DMA_Base + 0404H;
  DMA_INTF0*        = DMA_Base + 0408H;
  DMA_INTS0*        = DMA_Base + 040CH;
  DMA_INTE1*        = DMA_Base + 0414H;
  DMA_INTF1*        = DMA_Base + 0418H;
  DMA_INTS1*        = DMA_Base + 041CH;
  DMA_TIMER0*       = DMA_Base + 0420H;
  DMA_TIMER1*       = DMA_Base + 0424H;
  DMA_TIMER2*       = DMA_Base + 0428H;
  DMA_TIMER3*       = DMA_Base + 042CH;
  DMA_MULTI_CHAN_TRIGGER* = DMA_Base + 0430H;
  DMA_SNIFF_CTRL*   = DMA_Base + 0434H;
  DMA_SNIFF_DATA*   = DMA_Base + 0438H;
  DMA_FIFO_LEVELS*  = DMA_Base + 0440H;
  DMA_CHAN_ABORT*   = DMA_Base + 0444H;
  DMA_N_CHANNELS*   = DMA_Base + 0448H;

  DMA_CH0_DBG_CTDREQ* = DMA_Base + 0800H;
  DMA_CH0_DBG_TCR*    = DMA_Base + 0800H;
  (* ... *)
  (* 2 registers per channel, offset 040H, range 0 to 11 *)
  (* ... *)
  DMA_CH_DBG_Offset* = 040H;


  (* === single-cycle IO (SIO) === *)
  (* datasheet 2.3.1.17, p42 *)
  (* shared *)
  SIO_Base* = 0D0000000H;
  SIO_CPUID*            = SIO_Base;
  (* GPIO lo bank, GPIO0 to GPIO29, "user GPIO"  *)
  SIO_GPIO_IN*          = SIO_Base + 04H;
  SIO_GPIO_HI_IN*       = SIO_Base + 08H;
  SIO_GPIO_OUT*         = SIO_Base + 010H;
  SIO_GPIO_OUT_SET*     = SIO_Base + 014H;
  SIO_GPIO_OUT_CLR*     = SIO_Base + 018H;
  SIO_GPIO_OUT_XOR*     = SIO_Base + 01CH;
  SIO_GPIO_OE*          = SIO_Base + 020H;
  SIO_GPIO_OE_SET*      = SIO_Base + 024H;
  SIO_GPIO_OE_CLR*      = SIO_Base + 028H;
  SIO_GPIO_OE_XOR*      = SIO_Base + 02CH;
  (* GPIO hi bank, QPSI *)
  SIO_GPIO_HI_OUT*      = SIO_Base + 030H;
  SIO_GPIO_HI_OUT_SET*  = SIO_Base + 034H;
  SIO_GPIO_HI_OUT_CLR*  = SIO_Base + 038H;
  SIO_GPIO_HI_OUT_XOR*  = SIO_Base + 03CH;
  SIO_GPIO_HI_OE*       = SIO_Base + 040H;
  SIO_GPIO_HI_OE_SET*   = SIO_Base + 044H;
  SIO_GPIO_HI_OE_CLR*   = SIO_Base + 048H;
  SIO_GPIO_HI_OE_XOR*   = SIO_Base + 04CH;
  (* inter-processor message FIFO *)
  SIO_FIFO_ST*          = SIO_Base + 050H;
  SIO_FIFO_WR*          = SIO_Base + 054H;
  SIO_FIFO_RD*          = SIO_Base + 058H;

  (* lots more here *)

  (* spinlocks *)
  SIO_SPINLOCK*         = SIO_Base + 0100H;
  (* ... *)
  (* 1 register per spinlock, offset: 04H, range 0 to 31 *)
  (* ... *)
  SIO_SPINLOCK_Offset* = 04H;

  (* === GPIO banks and pads === *)
  (* GPIO lo bank control *)
  (* datasheet 2.19.6.1, p243 *)
  (* shared *)
  IO_BANK0_Base* = 040014000H;
  IO_BANK0_GPIO_STATUS* = IO_BANK0_Base;
  IO_BANK0_GPIO_CTRL*   = IO_BANK0_Base + 04H;
  (* ... *)
  (* 2 registers per GPIO, offset: 08H, range 0 to 29 *)
  (* ... *)
  IO_BANK0_GPIO_Offset* = 8;

  IO_BANK0_PROC0_INTE0* = IO_BANK0_Base + 0100H;
  IO_BANK0_PROC0_INTE1* = IO_BANK0_Base + 0104H;
  IO_BANK0_PROC0_INTE2* = IO_BANK0_Base + 0108H;
  IO_BANK0_PROC0_INTE3* = IO_BANK0_Base + 010CH;

  IO_BANK0_PROC0_INTF0* = IO_BANK0_Base + 0110H;
  IO_BANK0_PROC0_INTF1* = IO_BANK0_Base + 0114H;
  IO_BANK0_PROC0_INTF2* = IO_BANK0_Base + 0118H;
  IO_BANK0_PROC0_INTF3* = IO_BANK0_Base + 011CH;

  IO_BANK0_PROC0_INTS0* = IO_BANK0_Base + 0120H;
  IO_BANK0_PROC0_INTS1* = IO_BANK0_Base + 0124H;
  IO_BANK0_PROC0_INTS2* = IO_BANK0_Base + 0128H;
  IO_BANK0_PROC0_INTS3* = IO_BANK0_Base + 012CH;

  IO_BANK0_PROC1_INTE0* = IO_BANK0_Base + 0130H;
  IO_BANK0_PROC1_INTE1* = IO_BANK0_Base + 0134H;
  IO_BANK0_PROC1_INTE2* = IO_BANK0_Base + 0138H;
  IO_BANK0_PROC1_INTE3* = IO_BANK0_Base + 013CH;

  IO_BANK0_PROC1_INTF0* = IO_BANK0_Base + 0140H;
  IO_BANK0_PROC1_INTF1* = IO_BANK0_Base + 0144H;
  IO_BANK0_PROC1_INTF2* = IO_BANK0_Base + 0148H;
  IO_BANK0_PROC1_INTF3* = IO_BANK0_Base + 014CH;

  IO_BANK0_PROC1_INTS0* = IO_BANK0_Base + 0150H;
  IO_BANK0_PROC1_INTS1* = IO_BANK0_Base + 0154H;
  IO_BANK0_PROC1_INTS2* = IO_BANK0_Base + 0158H;
  IO_BANK0_PROC1_INTS3* = IO_BANK0_Base + 015CH;

  IO_BANK0_DORMANT_WAKE_INTE0* = IO_BANK0_Base + 0160H;
  IO_BANK0_DORMANT_WAKE_INTE1* = IO_BANK0_Base + 0164H;
  IO_BANK0_DORMANT_WAKE_INTE2* = IO_BANK0_Base + 0168H;
  IO_BANK0_DORMANT_WAKE_INTE3* = IO_BANK0_Base + 016CH;

  IO_BANK0_DORMANT_WAKE_INTF0* = IO_BANK0_Base + 0170H;
  IO_BANK0_DORMANT_WAKE_INTF1* = IO_BANK0_Base + 0174H;
  IO_BANK0_DORMANT_WAKE_INTF2* = IO_BANK0_Base + 0178H;
  IO_BANK0_DORMANT_WAKE_INTF3* = IO_BANK0_Base + 017CH;

  IO_BANK0_DORMANT_WAKE_INTS0* = IO_BANK0_Base + 0180H;
  IO_BANK0_DORMANT_WAKE_INTS1* = IO_BANK0_Base + 0184H;
  IO_BANK0_DORMANT_WAKE_INTS2* = IO_BANK0_Base + 0188H;
  IO_BANK0_DORMANT_WAKE_INTS3* = IO_BANK0_Base + 018CH;


  (* GPIO hi bank control, QSPI *)
  (* datasheet 2.19.6.2, p287 *)
  IO_QSPI_Base* = 040018000H;
  IO_QSPI_SCLK_STATUS*  = IO_QSPI_Base;
  IO_QSPI_SCLK_CTRL*    = IO_QSPI_Base + 004H;
  IO_QSPI_CS_STATUS*    = IO_QSPI_Base + 008H;
  IO_QSPI_CS_SCTRL*     = IO_QSPI_Base + 00CH;
  IO_QSPI_SD0_STATUS*   = IO_QSPI_Base + 010H;
  IO_QSPI_SD0_CTRL*     = IO_QSPI_Base + 014H;
  IO_QSPI_SD1_STATUS*   = IO_QSPI_Base + 018H;
  IO_QSPI_SD1_CTRL*     = IO_QSPI_Base + 01CH;
  IO_QSPI_SD2_STATUS*   = IO_QSPI_Base + 020H;
  IO_QSPI_SD2_CTRL*     = IO_QSPI_Base + 024H;
  IO_QSPI_SD3_STATUS*   = IO_QSPI_Base + 028H;
  IO_QSPI_SD3_CTRL*     = IO_QSPI_Base + 02CH;

  (* GPIO lo bank PADS config *)
  (* datasheet 2.19.6.3, p298 *)
  PADS_BANK0_Base* = 04001C000H;
  PADS_BANK0_VOLTAGE_SELECT*  = PADS_BANK0_Base;
  PADS_BANK0_GPIO*            = PADS_BANK0_Base + 004H;
  (* ... *)
  (* 1 register per GPIO, offset: 04H, range 0 to 29 *)
  (* ... *)
  PADS_BANK0_GPIO_Offset*     = 4;

  PADS_BANK0_SWCLK*           = PADS_BANK0_Base + 07CH;
  PADS_BANK0_SWD*             = PADS_BANK0_Base + 080H;

  (* GPIO hi bank pads config *)
  (* datasheet 2.19.6.4, 301 *)
  PADS_QSPI_Base* = 040020000H;
  PADS_QSPI_VOLTAGE_SELECT* = PADS_QSPI_Base;
  PADS_QSPI_SCKL*           = PADS_QSPI_Base + 004H;
  PADS_QSPI_SD0*            = PADS_QSPI_Base + 008H;
  PADS_QSPI_SD1*            = PADS_QSPI_Base + 00CH;
  PADS_QSPI_SD2*            = PADS_QSPI_Base + 010H;
  PADS_QSPI_SD3*            = PADS_QSPI_Base + 014H;
  PADS_QSPI_CS*             = PADS_QSPI_Base + 018H;


  (* === clocks, PLL, oscillators === *)
  (* -- clocks -- *)
  (* datasheet 2.15.7, p195 *)
  (* shared *)
  CLK_Base* = 040008000H;
  (* clk_gpout0 - 3 *)
  CLK_GPOUT0_CTRL*      = CLK_Base;
  CLK_GPOUT0_DIV*       = CLK_Base + 004H;
  CLK_GPOUT0_SELECTED*  = CLK_Base + 008H;
  CLK_GPOUT1_CTRL*      = CLK_Base + 00CH;
  CLK_GPOUT1_DIV*       = CLK_Base + 010H;
  CLK_GPOUT1_SELECTED*  = CLK_Base + 014H;
  CLK_GPOUT2_CTRL*      = CLK_Base + 018H;
  CLK_GPOUT2_DIV*       = CLK_Base + 01CH;
  CLK_GPOUT2_SELECTED*  = CLK_Base + 020H;
  CLK_GPOUT3_CTRL*      = CLK_Base + 024H;
  CLK_GPOUT3_DIV*       = CLK_Base + 028H;
  CLK_GPOUT3_SELECTED*  = CLK_Base + 02CH;
  (* clk_ref *)
  CLK_REF_CTRL*         = CLK_Base + 030H;
  CLK_REF_DIV*          = CLK_Base + 034H;
  CLK_REF_SELECTED*     = CLK_Base + 038H;
  (* clk_sys *)
  CLK_SYS_CTRL*         = CLK_Base + 03CH;
  CLK_SYS_DIV*          = CLK_Base + 040H;
  CLK_SYS_SELECTED*     = CLK_Base + 044H;
  (* clk_peri *)
  CLK_PERI_CTRL*        = CLK_Base + 048H;
  (* clk_usb *)
  CLK_USB_CTRL*         = CLK_Base + 054H;
  CLK_USB_DIV*          = CLK_Base + 058H;
  CLK_USB_SELECTED*     = CLK_Base + 05CH;
  (* clk_adc *)
  CLK_ADC_CTRL*         = CLK_Base + 060H;
  CLK_ADC_DIV*          = CLK_Base + 064H;
  CLK_ADC_SELECTED*     = CLK_Base + 068H;
  (* clk_rtc *)
  CLK_RTC_CTRL*         = CLK_Base + 06CH;
  CLK_RTC_DIV*          = CLK_Base + 070H;
  CLK_RTC_SELECTED*     = CLK_Base + 074H;
  (* resus *)
  CLK_SYS_RESUS_CTRL*   = CLK_Base + 078H;
  CLK_SYS_RESUS_STATUS* = CLK_Base + 07CH;
  (* frequency counter *)
  (* TBD *)

  (* clock gating, resets to all enabled *)
  CLK_WAKE_EN0*  = CLK_Base + 0A0H;
  CLK_WAKE_EN1*  = CLK_Base + 0A4H;
  CLK_SLEEP_EN0* = CLK_Base + 0A8H;
  CLK_SLEEP_EN1* = CLK_Base + 0ACH;
  CLK_ENABLED0*  = CLK_Base + 0B0H;
  CLK_ENABLED1*  = CLK_Base + 0B4H;
  (* resus interrupts *)
  CLK_INTR*      = CLK_Base + 0B8H;
  CLK_INTE*      = CLK_Base + 0BCH;
  CLK_INTF*      = CLK_Base + 0C0H;
  CLK_INTS*      = CLK_Base + 0C4H;

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
  CLK_SYS_XOSC*     = 14;
  CLK_SYS_XIP*      = 13;
  CLK_SYS_WATCHDOG* = 12;
  CLK_USB_USBCTRL*  = 11;
  CLK_SYS_USBCTRL*  = 10;
  CLK_SYS_UART1*    = 9;
  CLK_PERI_UART1*   = 8;
  CLK_SYS_UART0*    = 7;
  CLK_PERI_UART0*   = 6;
  CLK_SYS_TIMER*    = 5;
  CLK_SYS_TBMAN*    = 4;
  CLK_SYS_SYSINFO*  = 3;
  CLK_SYS_SYSCFG*   = 2;
  CLK_SYS_SRAM5*    = 1;
  CLK_SYS_SRAM4*    = 0;


  (* external oscillator, 12 MHz on Pico *)
  (* datasheet 2.16.7, p219 *)
  XOSC_Base* = 040024000H;
  XOSC_CTRL*    = XOSC_Base;
  XOSC_STATUS*  = XOSC_Base + 004H;
  XOSC_DORMANT* = XOSC_Base + 008H;
  XOSC_STARTUP* = XOSC_Base + 00CH;
  XOSC_COUNT*   = XOSC_Base + 01CH;

  (* PLLs *)
  (* datasheet 2.18.4, p233 *)
  PLL_SYS_Base* = 040028000H;
  PLL_SYS_CS*         = PLL_SYS_Base;
  PLL_SYS_PWR*        = PLL_SYS_Base + 04H;
  PLL_SYS_FBDIV_INT*  = PLL_SYS_Base + 08H;
  PLL_SYS_PRIM*       = PLL_SYS_Base + 0CH;

  PLL_USB_Base* = 04002C000H;
  PLL_USB_CS*         = PLL_USB_Base;
  PLL_USB_PWR*        = PLL_USB_Base + 04H;
  PLL_USB_FBDIV_INT*  = PLL_USB_Base + 08H;
  PLL_USB_PRIM*       = PLL_USB_Base + 0CH;

  (* ring oscillator *)
  (* datasheet 2.17.8, p223 *)
  ROSC_Base* = 040060000H;
  ROSC_CTRL*      = ROSC_Base;
  ROSC_FREQA*     = ROSC_Base + 004H;
  ROSC_FREQB*     = ROSC_Base + 008H;
  ROSC_DORMANT*   = ROSC_Base + 00CH;
  ROSC_DIV*       = ROSC_Base + 010H;
  ROSC_PHASE*     = ROSC_Base + 014H;
  ROSC_STATUS*    = ROSC_Base + 018H;
  ROSC_RANDOMBIT* = ROSC_Base + 01CH;
  ROSC_COUNT*     = ROSC_Base + 020H;

  (* ROSC_CTRL[23:12] *)
  ROSC_CTRL_DISABLE* = 0D1EH;
  ROSC_CTRL_ENABLE*  = 0FABH;


  (* === power and reset === *)
  (* shared *)
  (* power-on state machine *)
  (* datasheet 2.13.5, p.171 *)

  (* blocks resets *)
  PSM_Base* = 40010000H;
  PSM_FRCE_ON*  = PSM_Base;         (* force block out of reset (i.e. power it on) *)
  PSM_FRCE_OFF* = PSM_Base + 04H;   (* force into reset (i.e. power it off) *)
  PSM_WDSEL*    = PSM_Base + 08H;   (* set to 1 if this block should be reset when the watchdog fires *)
  PSM_DONE*     = PSM_Base + 0CH;   (* indicates the blocks registers are ready to access *)

  (* bits in all PSM.* registers *)
  (* these numbers also represent the reset/release order *)
  (* of the power-on sequence, ie. ROSC is first, and *)
  (* the processors/cores are last *)
  (* Any bit set will cause the subsequent block in the sequence *)
  (* to be reset anyway, independent of their setting *)
  (* datasheet 2.13.2, p170 *)
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

  (* subsystem resets *)
  (* datasheet 2.14.3, p177 *)
  RESETS_Base* = 04000C000H;
  RESETS_RESET*       = RESETS_Base;        (* reset control: if a bit is set it means the peripheral is in reset *)
  RESETS_WDSEL*       = RESETS_Base + 04H;  (* set to 1 if this peripheral should be reset when the watchdog fires *)
  RESETS_DONE*        = RESETS_Base + 08H;  (* indicates that the peripheral�s registers are ready to be accessed *)

  (* bits in all RESETS.* registers *)
  RESETS_UART1*       = 23;
  RESETS_UART0*       = 22;
  RESETS_TIMER*       = 21;
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
  RESETS_PADS_BANK0*  = 8;
  RESETS_IO_BANK0*    = 5;
  RESETS_I2C1*        = 4;
  RESETS_I2C0*        = 3;
  RESETS_DMA*         = 2;
  RESETS_BUSCTRL*     = 1;
  RESETS_ADC*         = 0;


  (* voltage regulation and chip reset *)
  (* datasheet 2.16.10, p159 *)
  VREG_AND_CHIP_RESET_Base* = 040064000H; (* p159 *)
  VREG_AND_CHIP_RESET_VREG*       = VREG_AND_CHIP_RESET_Base;
  VREG_AND_CHIP_RESET_BOD*        = VREG_AND_CHIP_RESET_Base + 04H;
  VREG_AND_CHIP_RESET_CHIP_RESET* = VREG_AND_CHIP_RESET_Base + 08H;


  (* === programmable IO (PIO) === *)
  (* datasheet 3.7, p366 *)
  PIO0_Base* = 050200000H;
  PIO1_Base* = 050300000H;


  (* === peripherals === *)
  (* all peripherals are shared *)
  (* UARTs *)
  UART0_Base* = 040034000H;
  UART1_Base* = 040038000H;

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

  (* SPI *)
  SPIO0_Base* = 04003C000H;
  SPIO1_Base* = 040040000H;

  (* note: dropped the "SSP" prefix for every reg *)
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

  (* ... *)

  (* I2C *)
  I2C0_Base* = 040044000H;
  I2C1_Base* = 040048000H;

  (* note: dropped the "IC_" prefix for every register *)
  I2C_CON_Offset*              = 0000H;
  I2C_TAR_Offset*              = 0004H;
  I2C_SAR_Offset*              = 0008H;
  I2C_DATA_CMD_Offset*         = 0010H;
  I2C_SS_SCL_HCNT_Offset*      = 0014H;
  I2C_SS_SCL_LCNT_Offset*      = 0018H;
  I2C_FS_SCL_HCNT_Offset*      = 001CH;
  I2C_FS_SCL_LCNT_Offset*      = 0020H;
  I2C_INTR_STAT_Offset*        = 002CH;
  I2C_INTR_MASK_Offset*        = 0030H;
  I2C_RAW_INTR_STAT_Offset*    = 0034H;
  I2C_RX_TL_Offset*            = 0038H;
  I2C_TX_TL_Offset*            = 003CH;
  I2C_CLR_INTR_Offset*         = 0040H;
  I2C_CLR_RX_UNDER_Offset*     = 0044H;
  I2C_CLR_RX_OVER_Offset*      = 0048H;
  I2C_CLR_TX_OVER_Offset*      = 004CH;
  I2C_CLR_RD_REQ_Offset*       = 0050H;
  I2C_CLR_TX_ABRT_Offset*      = 0054H;
  I2C_CLR_RX_DONE_Offset*      = 0058H;
  I2C_CLR_ACTIVITY_Offset*     = 005CH;
  I2C_CLR_STOP_DET_Offset*     = 0060H;
  I2C_CLR_START_DET_Offset*    = 0064H;
  I2C_CLR_GEN_CALL_Offset*     = 0068H;
  I2C_ENABLE_Offset*           = 006CH;
  I2C_STATUS_Offset*           = 0070H;
  I2C_TXFLR_Offset*            = 0074H;
  I2C_RXFLR_Offset*            = 0078H;
  I2C_SDA_HOLD_Offset*         = 007CH;
  I2C_TX_ABRT_SOURCE_Offset*   = 0080H;
  I2C_SLV_DATA_NACK_ONLY_Offset* = 0084H;
  I2C_DMA_CR_Offset*           = 0088H;
  I2C_DMA_TDLR_Offset*         = 008CH;
  I2C_DMA_RDLR_Offset*         = 0090H;
  I2C_SDA_SETUP_Offset*        = 0094H;
  I2C_ACK_GENERAL_CALL_Offset* = 0098H;
  I2C_ENABLE_STATUS_Offset*    = 009CH;
  I2C_FS_SPKLEN_Offset*        = 00A0H;
  I2C_CLR_RESTART_DET_Offset*  = 00A8H;
  I2C_COMP_PARAM_1_Offset*     = 00F4H;
  I2C_COMP_VERSION_Offset*     = 00F8H;
  I2C_COMP_TYPE_Offset*        = 00FCH;


  (* PWM *)
  PWM_Base* = 040050000H;
  PWM_CSR_Offset* = 0000H;
  PWM_DIV_Offset* = 0004H;
  PWM_CTR_Offset* = 0008H;
  PWM_CC_Offset*  = 000CH;
  PWM_TOP_Offset* = 0010H;
  (* ... *)
  (* 5 registers per channel, offset: 14H, range 0 to 7 *)
  (* ... *)
  PWM_CH_Offset*  = 0014H;

  PWM_EN*         = PWM_Base + 00A0H;
  PWM_INTR*       = PWM_Base + 00A4H;
  PWM_INTE*       = PWM_Base + 00A8H;
  PWM_INTF*       = PWM_Base + 00ACH;
  PWM_INTS*       = PWM_Base + 00B0H;

  (* timer *)
  (* datasheet 4.6, p541 *)
  TIMER_Base* = 040054000H;
  TIMER_TIMEHW*   = TIMER_Base;
  TIMER_TIMELW*   = TIMER_Base + 004H;
  TIMER_TIMEHR*   = TIMER_Base + 008H;
  TIMER_TIMELR*   = TIMER_Base + 00CH;
  TIMER_ALARM0*   = TIMER_Base + 010H;
  TIMER_ALARM1*   = TIMER_Base + 014H;
  TIMER_ALARM2*   = TIMER_Base + 018H;
  TIMER_ALARM3*   = TIMER_Base + 01CH;
  TIMER_ARMED*    = TIMER_Base + 020H;
  TIMER_TIMERAWH* = TIMER_Base + 024H;
  TIMER_TIMERAWL* = TIMER_Base + 028H;
  TIMER_DBGPAUSE* = TIMER_Base + 02CH;
  TIMER_PAUSE*    = TIMER_Base + 030H;
  TIMER_INTR*     = TIMER_Base + 034H;
  TIMER_INTE*     = TIMER_Base + 038H;
  TIMER_INTF*     = TIMER_Base + 03CH;
  TIMER_INTS*     = TIMER_Base + 040H;

  TIMER_ALARM*   = TIMER_ALARM0;
  TIMER_ALARM_Offset* = 04H;

  (* watchdog *)
  (* datasheet 4.7, p549 *)
  WATCHDOG_Base*     = 040058000H;
  WATCHDOG_CTRL*     = WATCHDOG_Base;
  WATCHDOG_LOAD*     = WATCHDOG_Base + 004H;
  WATCHDOG_REASON*   = WATCHDOG_Base + 008H;
  WATCHDOG_SCRATCH0* = WATCHDOG_Base + 00CH;
  WATCHDOG_SCRATCH1* = WATCHDOG_Base + 010H;
  WATCHDOG_SCRATCH2* = WATCHDOG_Base + 014H;
  WATCHDOG_SCRATCH3* = WATCHDOG_Base + 018H;
  WATCHDOG_SCRATCH4* = WATCHDOG_Base + 01CH;
  WATCHDOG_SCRATCH5* = WATCHDOG_Base + 020H;
  WATCHDOG_SCRATCH6* = WATCHDOG_Base + 024H;
  WATCHDOG_SCRATCH7* = WATCHDOG_Base + 028H;
  WATCHDOG_TICK*     = WATCHDOG_Base + 02CH;

  WATCHDOG_SCRATCH*  = WATCHDOG_SCRATCH0;
  (* ... *)
  (* one register per scratch, offset 4, range 0 to 7 *)
  (* ... *)
  WATCHDOG_SCRATCH_Offset* = 4;

  WATCHDOG_TICK_EN*  = 9;

  (* rtc *)
  (* datasheet 4.8, p555 *)
  RTC_Base* = 04005C000H;
  RTC_CLKDIV_M1*   = RTC_Base;
  RTC_SETUP_0*     = RTC_Base + 004H;
  RTC_SETUP_1*     = RTC_Base + 008H;
  RTC_CTRL*        = RTC_Base + 00CH;
  RTC_IRQ_SETUP_0* = RTC_Base + 010H;
  RTC_IRQ_SETUP_1* = RTC_Base + 014H;
  RTC_RTC_1*       = RTC_Base + 018H;
  RTC_RTC_0*       = RTC_Base + 01CH;
  RTC_INTR*        = RTC_Base + 020H;
  RTC_INTE*        = RTC_Base + 024H;
  RTC_INTF*        = RTC_Base + 028H;
  RTC_INTS*        = RTC_Base + 02CH;

  (* adc *)
  (* datasheet 4.9, p566 *)
  ADC_Base* = 04004C000H;
  ADC_CS*     = ADC_Base;
  ADC_RESULT* = ADC_Base + 004H;
  ADC_FCS*    = ADC_Base + 008H;
  ADC_FIFO*   = ADC_Base + 00CH;
  ADC_DIV*    = ADC_Base + 010H;
  ADC_INTR*   = ADC_Base + 014H;
  ADC_INTE*   = ADC_Base + 018H;
  ADC_INTF*   = ADC_Base + 01CH;
  ADC_INTS*   = ADC_Base + 020H;

  (* USB p381 *)
  USBCTRL_Base* = 050100000H;
  USBCTRL_DPRAM_Base* = USBCTRL_Base;
  USBCTRL_REGS_Base* = 050110000H;

  (* testbench manager *)
  TBMAM_Base* = 04006C000H;


  (* === assembly instructions === *)
  NOP* = 046C0H;
  (* read specical regs *)
  (* 0F3EF8 B 09H r11(B) PSP(09) *)
  MRS_R11_IPSR* = 0F3EF8B05H; (* read IPSR into r11 *)
  MRS_R11_XPSR* = 0F3EF8B03H; (* read XPSR into r11 *)
  MRS_R11_MSP*  = 0F3EF8B08H;  (* read MSP into r11 *)
  MRS_R11_PSP*  = 0F3EF8B09H;  (* read PSP into r11 *)
  MRS_R11_CTL*  = 0F3EF8B14H;  (* read CONTROL into r11 *)
  (* write special regs *)
  (* 0F38 B 88 09H r11(B) PSP(09) *)
  MSR_R11_PSP* = 0F38B8809H;  (* read r11 into PSP *)
  MSR_R11_CTL* = 0F38B8814H;  (* read r11 into CONTROL *)

  (* instruction sync *)
  ISB* = 0F3BF8F6FH;

  (* disable/enable interrupts via PRIMASK *)
  CPSIE* = 0B662H; (* enable: 1011 0110 0110 0010 *)
  CPSID* = 0B672H; (* disable: 1011 0110 0111 0010 *)

END MCU2.