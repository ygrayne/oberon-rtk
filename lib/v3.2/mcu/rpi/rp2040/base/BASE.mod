MODULE BASE;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  MCU register and memory addresses, bits, values, assembly instructions
  --
  MCU: RP2040, Pico
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumCores* = 2;

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
    ROM_BASE*     = 000000000H;
    FLASH_BASE*   = 010000000H;
    SRAM_BASE*    = 020000000H;

    SRAM0_BASE*   = 020000000H;
    SRAM4_BASE*   = 020040000H;
    SRAM5_BASE*   = 020041000H;

    FLASH_Size*   = 0200000H; (* 2M original Pico *)
    SRAM0_Size*   = 040000H;  (* 256k *)
    SRAM4_Size*   = 01000H;   (* 4k *)
    SRAM5_Size*   = 01000H;   (* 4k *)


    (* == peripheral devices base addresses == *)
    (* APB *)
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
    SPI0_BASE*        = 04003C000H;
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

    (* AHB-lite *)
    DMA_BASE*             = 050000000H;
    USBCTRL_BASE*         = 050100000H;
    USBCTRL_DPRAM_BASE*   = 050100000H;
    USB_CTRL_REGS_BASE*   = 050110000H;
    PIO0_BASE*            = 050200000H;
    PIO1_BASE*            = 050300000H;
    XIP_AUX_BASE*         = 050400000H;

    (* core-local *)
    SIO_BASE*             = 0D0000000H;

    (* PPB base address *)
    PPB_BASE*             = 0E0000000H;

END BASE.
