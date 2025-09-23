MODULE MCU2;
(**
  Oberon RTK Framework v2
  --
  MCU register and memory addresses, bits, values, assembly instructions
  --
  MCU: MCX-A346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumCores* = 1;
    NumUART*  = 6;
    NumPorts* = 5;

    ASET* = 004H;
    ACLR* = 008H;
    AXOR* = 0C0H;

(* === module base addresses === *)

    (* peripheral bridge 0 *)
    INPUTMUX0_BASE* = 040001000H;
    CTIMER0_BASE*   = 040004000H;
    CTIMER1_BASE*   = 040005000H;
    CTIMER2_BASE*   = 040006000H;
    CTIMER3_BASE*   = 040007000H;
    CTIMER4_BASE*   = 040008000H;
    FREQME0_BASE*   = 040009000H;
    UTICK0_BASE*    = 04000B000H;
    WWDT0_BASE*     = 04000C000H;
    SmartDMA0_BASE* = 04000E000H;

    (* peripheral bridge 1 *)
    CMC_BASE*       = 04008B000H;
    ERM0_BASE*      = 04008D000H;
    MBC0_BASE*      = 04008E000H;
    SCG0_BASE*      = 04008F000H;
    SPC0_BASE*      = 040090000H;
    SYSCON_BASE*    = 040091000H;
    WUU0_BASE*      = 040092000H;
    VBAT0_BASE*     = 040093000H;
    FMC0_BASE*      = 040094000H;
    FMU0_BASE*      = 040095000H;
    LPI2C0_BASE*    = 04009A000H;
    LPI2C1_BASE*    = 04009B000H;
    LPSPI0_BASE*    = 04009C000H;
    LPSPI1_BASE*    = 04009D000H;
    LPUART0_BASE*   = 04009F000H;
    LPUART1_BASE*   = 0400A0000H;
    LPUART2_BASE*   = 0400A1000H;
    LPUART3_BASE*   = 0400A2000H;
    LPUART4_BASE*   = 0400A3000H;
    QDC0_BASE*      = 0400A7000H;
    QDC1_BASE*      = 0400A8000H;
    FlexPWM0_BASE*  = 0400A9000H;
    FlexPWM1_BASE*  = 0400AA000H;
    LPTMR0_BASE*    = 0400AB000H;
    OSTIMER0_BASE*  = 0400AD000H;
    WAKETIMER0_BASE* = 0400AE000H;
    HSADC0_BASE*    = 0400AF000H;
    HSADC1_BASE*    = 0400B0000H;
    CMP0_BASE*      = 0400B1000H;
    CMP1_BASE*      = 0400B2000H;
    CMP2_BASE*      = 0400B3000H;
    DAC0_BASE*      = 0400B4000H;
    OPAMP0_BASE*    = 0400B7000H;
    OPAMP1_BASE*    = 0400B8000H;
    OPAMP2_BASE*    = 0400B9000H;
    OPAMP3_BASE*    = 0400BA000H;
    PORT0_BASE*     = 0400BC000H;
    PORT1_BASE*     = 0400BD000H;
    PORT2_BASE*     = 0400BE000H;
    PORT3_BASE*     = 0400BF000H;
    PORT4_BASE*     = 0400C0000H;
    CAN0_BASE*      = 0400CC000H;
    CAN1_BASE*      = 0400D0000H;
    LPI2C2_BASE*    = 0400D4000H;
    LPI2C3_BASE*    = 0400D5000H;
    LPUART5_BASE*   = 0400DA000H;
    TDET0_BASE*     = 0400E9000H;
    PKC0_BASE*      = 0400EA000H;
    SGI0_BASE*      = 0400EB000H;
    TRNG0_BASE*     = 0400EC000H;
    UDF0_BASE*      = 0400ED000H;
    RTC0_BASE*      = 0400EE000H;
    HSADC2_BASE*    = 0400F0000H;
    HSADC3_BASE*    = 0400F1000H;

    (* fast peripherals *)
    CDOG0_BASE*     = 040100000H;
    RGPIO0_BASE*    = 040102000H;
    RGPIO1_BASE*    = 040103000H;
    RGPIO2_BASE*    = 040104000H;
    RGPIO3_BASE*    = 040105000H;
    RGPIO4_BASE*    = 040106000H;
    CDOG1_BASE*     = 040107000H;


(* === peripheral bridge 1 === *)

    (* == SCG system clock generator == *)
    (* ref manual 23.7.1, p912 *)
    SCG_VERID*      = SCG0_BASE;
    SCG_PARAM*      = SCG0_BASE + 0004H;
    SCG_TRIM_LOCK*  = SCG0_BASE + 0008H;
    SCG_CSR*        = SCG0_BASE + 0010H;
    SCG_RCCR*       = SCG0_BASE + 0014H;
    SCG_SOSCCSR*    = SCG0_BASE + 0100H;
    SCG_SOSCCFG*    = SCG0_BASE + 0108H;
    SCG_SIRCCSR*    = SCG0_BASE + 0200H;
    SCG_SIRCTCFG*   = SCG0_BASE + 020CH;
    SCG_SIRCTRIM*   = SCG0_BASE + 0210H;
    SCG_SIRCSTAT*   = SCG0_BASE + 0218H;
    SCG_FIRCCSR*    = SCG0_BASE + 0300H;
    SCG_FIRCCFG*    = SCG0_BASE + 0308H;
    SCG_FIRCTRIM*   = SCG0_BASE + 0310H;
    SCG_ROSCCSR*    = SCG0_BASE + 0400H;
    SCG_SPLLCSR*    = SCG0_BASE + 0600H;
    SCG_SPLLCTRL*   = SCG0_BASE + 0604H;
    SCG_SPLLSTAT*   = SCG0_BASE + 0608H;
    SCG_SPLLNDIV*   = SCG0_BASE + 060CH;
    SCG_SPLLMDIV*   = SCG0_BASE + 0610H;
    SCG_SPLLPDIV*   = SCG0_BASE + 0614H;
    SCG_SPLLLOCK_CNFG*  = SCG0_BASE + 0618H;
    SCG_SPLLSSCG*   = SCG0_BASE + 0620H;
    SCG_SPLLSSCG0*  = SCG0_BASE + 0624H;
    SCG_SPLLSSCG1*  = SCG0_BASE + 0628H;
    SCG_LDOCSR*     = SCG0_BASE + 0800H;

    (* == SPC system power controller == *)
    (* ref manual 26.7.1, p981 *)
    SPC_ACTIVE_CFG* = SPC0_BASE + 0100H;

    (* == SYCON == *)
    (* ref manual 14.5.1, p483 *)
    SYSCON_AHBMATPRIO*  = SYSCON_BASE + 0210H;
    SYSCON_SLOWCLKDIV*  = SYSCON_BASE + 0378H;
    SYSCON_BUSCLKDIV*   = SYSCON_BASE + 037CH;
    SYSCON_AHBCLKDIV*   = SYSCON_BASE + 0380H;
    SYSCON_FROHFDIV*    = SYSCON_BASE + 0388H;
    SYSCON_FROLFDIV*    = SYSCON_BASE + 038CH;
    SYSCON_CLKUNLOCK*   = SYSCON_BASE + 03FCH;
    SYSCON_LPCAC_CTRL*  = SYSCON_BASE + 0824H;

    (* == MRCC == *)
    (* ref manual 14.5.2, p520 *)
    (* device reset control *)
    MRCC_GLB_RST0*     = SYSCON_BASE;
    MRCC_GLB_RST0_SET* = MRCC_GLB_RST0 + ASET;
    MRCC_GLB_RST0_CLR* = MRCC_GLB_RST0 + ACLR;
    MRCC_GLB_RST1*     = SYSCON_BASE + 010H;
    MRCC_GLB_RST1_SET* = MRCC_GLB_RST1 + ASET;
    MRCC_GLB_RST1_CLR* = MRCC_GLB_RST1 + ACLR;
    MRCC_GLB_RST2*     = SYSCON_BASE + 020H;
    MRCC_GLB_RST2_SET* = MRCC_GLB_RST2 + ASET;
    MRCC_GLB_RST2_CLR* = MRCC_GLB_RST2 + ACLR;
      MRCC_GLB_RST_Offset* = 010H;

    (* device AHB bus clock control *)
    MRCC_GLB_CC0*      = SYSCON_BASE + 040H;
    MRCC_GLB_CC0_SET*  = MRCC_GLB_CC0 + ASET;
    MRCC_GLB_CC0_CLR*  = MRCC_GLB_CC0 + ACLR;
    MRCC_GLB_CC1*      = SYSCON_BASE + 050H;
    MRCC_GLB_CC1_SET*  = MRCC_GLB_CC1 + ASET;
    MRCC_GLB_CC1_CLR*  = MRCC_GLB_CC1 + ACLR;
    MRCC_GLB_CC2*      = SYSCON_BASE + 060H;
    MRCC_GLB_CC2_SET*  = MRCC_GLB_CC2 + ASET;
    MRCC_GLB_CC2_CLR*  = MRCC_GLB_CC2 + ACLR;
      MRCC_GLB_CC_Offset* = 010H;

    (* functional clock selection & divider *)
    (* USE CLK_* device numbers to calculate offset *)
    MRCC_CLKSEL* = SYSCON_BASE + 0A0H;
    MRCC_CLKDIV* = SYSCON_BASE + 0A4H;
      MRCC_CLK_Offset* = 8;

    (* device numbers *)
    (* MRCC_GLB_RST0, MRCC_GLB_CC0, MRCC_GLB_ACC0 *)
    DEV_INPUTMUX0*  = 0;
    DEV_CTIMER0*    = 2;
    DEV_CTIMER1*    = 3;
    DEV_CTIMER2*    = 4;
    DEV_CTIMER3*    = 5;
    DEV_CTIMER4*    = 6;
    DEV_UART0*      = 23;
    DEV_UART1*      = 24;
    DEV_UART2*      = 25;
    DEV_UART3*      = 26;
    DEV_UART4*      = 27;
    DEV_QDC1*       = 30;
    DEV_FLEXPWM0*   = 31;

    (* MRCC_GLB_RST1, MRCC_GLB_CC1, MRCC_GLB_ACC1 *)
    DEV_PORT0*      = 32 + 12;
    DEV_PORT1*      = 32 + 13;
    DEV_PORT2*      = 32 + 14;
    DEV_PORT3*      = 32 + 15;
    DEV_PORT4*      = 32 + 16;
    DEV_UART5*      = 32 + 26;

    (* MRCC_GLB_RST2, MRCC_GLB_CC2, MRCC_GLB_ACC2 *)
    DEV_GPIO0*      = 64 + 4;
    DEV_GPIO1*      = 64 + 5;
    DEV_GPIO2*      = 64 + 6;
    DEV_GPIO3*      = 64 + 7;
    DEV_GPIO4*      = 64 + 8;

    (* MRCC_CLKSEL, MRCC_CLKDIV *)
    CLK_CTIMER0*    = 1;
    CLK_CTIMER1*    = 2;
    CLK_CTIMER2*    = 3;
    CLK_CTIMER3*    = 4;
    CLK_CTIMER4*    = 5;
    CLK_FLXIO0*     = 7;
    CLK_I2C0*       = 8;
    CLK_I2C1*       = 9;
    CLK_SPI0*       = 10;
    CLK_SPI1*       = 11;
    CLK_UART0*      = 12;
    CLK_UART1*      = 13;
    CLK_UART2*      = 14;
    CLK_UART3*      = 15;
    CLK_UART4*      = 16;
    CLK_UART5*      = 32;
    CLK_CLKOUT*     = 34;
    CLK_SYSTICK*    = 35;


    (* == FMU flash management unit == *)
    FMU_FCTRL*      = FMU0_BASE + 008H;


    (* == (LP)UART0 .. UART5 == *)
    (* ref manual 39, p1519 *)
    (* UART_Offset valid for UART0 to UART4 *)
    UART_Offset*        = LPUART1_BASE - LPUART0_BASE;
    UART_VERID_Offset*  = 000H;
    UART_PARAM_Offset*  = 004H;
    UART_GLOBAL_Offset* = 008H;
    UART_PINCFG_Offset* = 00CH;
    UART_BAUD_Offset*   = 010H;
    UART_STAT_Offset*   = 014H;
    UART_CTRL_Offset*   = 018H;
    UART_DATA_Offset*   = 01CH;
    UART_MATCH_Offset*  = 020H;
    UART_MODIR_Offset*  = 024H;
    UART_FIFO_Offset*   = 028H;
    UART_WATER_Offset*  = 02CH;
    UART_DATARO_Offset* = 030H;


    (* == PORT0 .. PORT4 == *)
    (* ref manual 11.6.1, p138 *)
    PORT_Offset* = PORT1_BASE - PORT0_BASE;
    PORT_VERID_Offset*  = 000H;
    PORT_GPCLR_Offset*  = 010H;
    PORT_GPCHR_Offset*  = 014H;
    PORT_CONFIG_Offset* = 020H;
    PORT_CALIB0_Offset* = 060H;
    PORT_CALIB1_Offset* = 064H;
    PORT_PCR_Offset*    = 080H;

    (* supported/implemented pins *)
    PORT0_pins* = {0 .. 7,          12 .. 19, 20 .. 26, 27,     29 .. 31};
    PORT1_pins* = {0 .. 7, 8 .. 11, 12 .. 19};
    PORT2_pins* = {0 .. 7, 8 .. 11, 12 .. 19, 20 .. 26 };
    PORT3_pins* = {0 .. 7, 8 .. 11, 12 .. 19, 20 .. 26, 27, 28, 29 .. 31};
    PORT4_pins* = {0 .. 7};

    (* PCR non-zero resets *)
    P0_PCR0reset*  = 000001143H; (* ibe, mux = 1, dse, pe, ps = up *)
    P0_PCR1reset*  = 000001102H; (* ibe, mux = 1, pe, ps = down *)
    P0_PCR2reset*  = 000000140H; (* mux = 1, dse *)
    P0_PCR3reset*  = 000001103H; (* ibe, mux = 1, pe, ps = up *)
    P0_PCR6reset*  = 000001103H; (* ibe, mux = 1, pe, ps = up *)
    P1_PCR29reset* = 000000133H; (* reset button, mux = 1, ode, pfe, pe, ps = up *)
    P3_PCR29reset* = 000000103H; (* mux = 1, pe, ps = up *)

    (* ports with non-zero resets *)
    PORT_reset* = {0, 1, 3};

    PORT0* = 0;
    PORT1* = 1;
    PORT2* = 2;
    PORT3* = 3;
    PORT4* = 4;


(* === fast peripherals === *)

    (* RGPIO *)
    RGPIO_Offset* = RGPIO1_BASE - RGPIO0_BASE;
    RGPIO_PDOR_Offset* = 040H;  (* data output value *)
    RGPIO_PSOR_Offset* = 044H;  (* data output set masked *)
    RGPIO_PCOR_Offset* = 048H;  (* data output clear masked *)
    RGPIO_PTOR_Offset* = 04CH;  (* data output toggle masked *)
    RGPIO_PDIR_Offset* = 050H;  (* data input *)
    RGPIO_PDDR_Offset* = 054H;  (* data direction, reset = input [0] *)
    RGPIO_PIDR_Offset* = 058H;  (* input disable, reset = enabled [0] *)


(* *** *)
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




END MCU2.
