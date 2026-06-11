MODULE BASE;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  MCU register and memory addresses, bits, values, assembly instructions
  --
  MCU: RP2350, Pico2
  --
  Copyright (c) 2024-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumCores*       = 2;

    (* == atomic register access, datasheet 2.1.3, p26 == *)
    (*
    addr + 0000H: normal read write access
    addr + 1000H: atomic XOR on write
    addr + 2000H: atomic bitmask set on write
    addr + 3000H: atomic bitmask clear on write
    *)
    AXOR* = 01000H;
    ASET* = 02000H;
    ACLR* = 03000H;

    (* == memory layout == *)
    (* AHB *)
    ROM_BASE*    = 000000000H;
    FLASH_BASE*  = 010000000H;
    SRAM_BASE*   = 020000000H;

    SRAM0_BASE*   = 020000000H;
    SRAM4_BASE*   = 020040000H;
    SRAM8_BASE*   = 020080000H;
    SRAM9_BASE*   = 020081000H;

    FLASH_Size*   = 0400000H; (* 4M original Pico 2 *)
    SRAM0_Size*   = 040000H;  (* 256k *)
    SRAM4_Size*   = 040000H;  (* 256k *)
    SRAM8_Size*   = 01000H;   (* 4k *)
    SRAM9_Size*   = 01000H;   (* 4k *)


    (* == peripheral devices base addresses == *)
    (* APB *)
    (* atomic access *)
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
    (* no atomic access for CORESIGHT_* registers *)
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

    (* AHB *)
    (* atomic access *)
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

    (* core-local *)
    SIO_BASE*     = 0D0000000H;
    SIO_NS_BASE*  = 0D0020000H;

    (* PPB *)
    PPB_BASE*             = 0E0000000H;
    PPB_NS_BASE*          = 0E0020000H;
    EPPB_BASE*            = 0E0080000H;

    (* XIP *)
    XIP_NOCACHE_NOALLOC_BASE* = 014000000H;
    XIP_MAINTENANCE_BASE*     = 018000000H;

END BASE.
