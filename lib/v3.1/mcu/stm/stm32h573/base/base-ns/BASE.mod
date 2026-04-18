MODULE BASE;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Non-secure MCU definitions
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    (* == MCU constants == *)
    NumCores*  = 1;

    (* == memory layout == *)
    (* non-secure *)
    (* non-secure: C bus/code *)
    FLASH_Cb_NS_BASE*  = 008000000H;
    SRAM1_Cb_NS_BASE*  = 00A000000H;
    SRAM2_Cb_NS_BASE*  = 00A040000H;
    SRAM3_Cb_NS_BASE*  = 00A050000H;

    (* non-secure: S bus/data *)
    SRAM1_Sb_NS_BASE*  = 020000000H;
    SRAM2_Sb_NS_BASE*  = 020040000H;
    SRAM3_Sb_NS_BASE*  = 020050000H;
                      (* 0200A0000H *)


    (* secure/non-secure callable *)
    FLASH_Cb_S_Offset* = 004000000H;
    SRAM_Cb_S_Offset*  = 004000000H;
    SRAM_Sb_S_Offset*  = 010000000H;

    (* secure: C bus/code *)
    FLASH_Cb_S_BASE*  = FLASH_Cb_NS_BASE + FLASH_Cb_S_Offset;
    SRAM1_Cb_S_BASE*  = SRAM1_Cb_NS_BASE + SRAM_Cb_S_Offset;
    SRAM2_Cb_S_BASE*  = SRAM2_Cb_NS_BASE + SRAM_Cb_S_Offset;
    SRAM3_Cb_S_BASE*  = SRAM3_Cb_NS_BASE + SRAM_Cb_S_Offset;

    (* secure: S bus/data *)
    SRAM1_Sb_S_BASE*   = SRAM1_Sb_NS_BASE + SRAM_Sb_S_Offset;
    SRAM2_Sb_S_BASE*   = SRAM2_Sb_NS_BASE + SRAM_Sb_S_Offset;
    SRAM3_Sb_S_BASE*   = SRAM3_Sb_NS_BASE + SRAM_Sb_S_Offset;


    (* sizes *)
    FLASH_Size* = 0200000H; (* 2M *)
    FLASH_BLK_Size* = 0100000H; (* 1M *)
    SRAM1_Size* = 0040000H; (* 256k *)
    SRAM2_Size* = 0010000H; (* 64k *)
    SRAM3_Size* = 0050000H; (* 320k *)

    (* == peripheral devices S/NS address offset == *)
    PERI_S_Offset*  = 010000000H;

    (* APB1 *)
    TIM2_BASE*        = 040000000H;
    TIM3_BASE*        = 040000400H;
    TIM4_BASE*        = 040000800H;
    TIM5_BASE*        = 040000C00H;
    TIM6_BASE*        = 040001000H;
    TIM7_BASE*        = 040001400H;
    TIM12_BASE*       = 040001800H;
    TIM13_BASE*       = 040001C00H;
    TIM14_BASE*       = 040002000H;
    WWDG_BASE*        = 040002C00H;
    IWDG_BASE*        = 040003000H;
    SPI2_BASE*        = 040003800H;
    SPI3_BASE*        = 040003C00H;
    USART2_BASE*      = 040004400H;
    USART3_BASE*      = 040004800H;
    UART4_BASE*       = 040004C00H;
    UART5_BASE*       = 040005000H;
    I2C1_BASE*        = 040005400H;
    I2C2_BASE*        = 040005800H;
    I3C1_BASE*        = 040005C00H;
    CRS_BASE*         = 040006000H;
    USART6_BASE*      = 040006400H;
    USART10_BASE*     = 040006800H;
    USART11_BASE*     = 040006C00H;
    HDMI_CEC_BASE*    = 040007000H;
    UART7_BASE*       = 040007800H;
    UART8_BASE*       = 040007C00H;
    UART9_BASE*       = 040008000H;
    UART12_BASE*      = 040008400H;
    DTS_BASE*         = 040008C00H;
    LPTIM2_BASE*      = 040009400H;
    FDCAN1_BASE*      = 04000A400H;
    FDCAN2_BASE*      = 04000A800H;
    FDCAN_RAM*        = 04000AC00H;
    UCPD1_BASE*       = 04000DC00H;

    (* APB2 *)
    TIM1_BASE*        = 040012C00H;
    SPI1_BASE*        = 040013000H;
    TIM8_BASE*        = 040013400H;
    USART1_BASE*      = 040013800H;
    TIM15_BASE*       = 040014000H;
    TIM16_BASE*       = 040014400H;
    TIM17_BASE*       = 040014800H;
    SPI4_BASE*        = 040014C00H;
    SPI6_BASE*        = 040015000H;
    SAI1_BASE*        = 040015400H;
    SAI2_BASE*        = 040015800H;
    USB_FS_BASE*      = 040016000H;
    USB_FS_RAM*       = 040016400H;

    (* AHB1 *)
    GPDMA1_BASE*      = 040020000H;
    GPDMA2_BASE*      = 040021000H;
    FLASH_BASE*       = 040022000H;
    CRC_BASE*         = 040023000H;
    CORDIC_BASE*      = 040023800H;
    FMAC_BASE*        = 040023C00H;
    RAMCFG_BASE*      = 040026000H;
    ETH_MAC_BASE*     = 040028000H;
    ICACHE_BASE*      = 040030400H;
    DCACHE_BASE*      = 040031400H;
    GTZC1_BASE*       = 040032400H;

    (* AHB 2 *)
    GPIOA_BASE*       = 042020000H;
    GPIOB_BASE*       = 042020400H;
    GPIOC_BASE*       = 042020800H;
    GPIOD_BASE*       = 042020C00H;
    GPIOE_BASE*       = 042021000H;
    GPIOF_BASE*       = 042021400H;
    GPIOG_BASE*       = 042021800H;
    GPIOH_BASE*       = 042021C00H;
    GPIOI_BASE*       = 042022000H;
    ADC12_BASE*       = 042028000H;
    DAC1_BASE*        = 042028400H;
    DCMI_BASE*        = 04202C000H;
    PSSI_BASE*        = 04202C400H;
    AES_BASE*         = 0420C0000H;
    HASH_BASE*        = 0420C0400H;
    RNG_BASE*         = 0420C0800H;
    SAES_BASE*        = 0420C0C00H;
    PKA_BASE*         = 0420C2000H;

    (* APB3 *)
    SBS_BASE*         = 044000400H;
    SPI5_BASE*        = 044002000H;
    LPUART1_BASE*     = 044002400H;
    I2C3_BASE*        = 044002800H;
    I2C4_BASE*        = 044002C00H;
    LPTIM1_BASE*      = 044004400H;
    LPTIM3_BASE*      = 044004800H;
    LPTIM4_BASE*      = 044004C00H;
    LPTIM5_BASE*      = 044005000H;
    LPTIM6_BASE*      = 044005400H;
    VREFBUF_BASE*     = 044007400H;
    RTC_BASE*         = 044007800H;
    TAMP_BASE*        = 044007C00H;

    (* AHB3 *)
    PWR_BASE*         = 044020800H;
    RCC_BASE*         = 044020C00H;
    EXTI_BASE*        = 044022000H;
    DEBUG_BASE*       = 044024000H;

    (* AHB4 *)
    OTFDEC1_BASE*     = 046005000H;
    SDMMC1_BASE*      = 046008000H;
    DLYBSD1_BASE*     = 046008400H;
    DLYBSD2_BASE*     = 046008800H;
    SDMMC2_BASE*      = 046008C00H;
    DLYBOS1_BASE*     = 04600F000H;
    FMC_BASE*         = 047000400H;
    OCTOSPI1_BASE*    = 047001400H;


    (* PPB *)
    PPB_BASE*         = 0E0000000H;
    PPB_NS_BASE*      = 0E0020000H;

END BASE.
