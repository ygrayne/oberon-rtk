MODULE EXC;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Exceptions and IRQs.
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumInterrupts*    = 52;
    VectorTableSize*  = 272; (* bytes: 16 sys exceptions + 52 interrupts, one word each *)

    (* -- exception priorities, 3 bits -- *)
    ExcPrio0* = 000H; (* 0000 0000 *)
    ExcPrio1* = 020H; (* 0010 0000 *)
    ExcPrio2* = 040H; (* 0100 0000 *)
    ExcPrio3* = 060H; (* 0110 0000 *)
    ExcPrio4* = 080H; (* 1000 0000 *)
    ExcPrio5* = 0A0H; (* 1010 0000 *)
    ExcPrio6* = 0C0H; (* 1100 0000 *)
    ExcPrio7* = 0E0H; (* 1110 0000 *)

    ExcPrio00* = 000H; (* 0000 0000 *)
    ExcPrio20* = 020H; (* 0010 0000 *)
    ExcPrio40* = 040H; (* 0100 0000 *)
    ExcPrio60* = 060H; (* 0110 0000 *)
    ExcPrio80* = 080H; (* 1000 0000 *)
    ExcPrioA0* = 0A0H; (* 1010 0000 *)
    ExcPrioC0* = 0C0H; (* 1100 0000 *)
    ExcPrioE0* = 0E0H; (* 1110 0000 *)

    NumExcPrio* = 8;

    ExcPrioTop*    = ExcPrio00;
    ExcPrioHigh*   = ExcPrio20;
    ExcPrioMedium* = ExcPrio80;
    ExcPrioLow*    = ExcPrioE0;

    (* IRQ numbers *)
    (* datasheet 3.2, p83 *)
    IRQ_BASE*          = 16; (* exc no = IRQ_BASE + IRQ number *)
    IRQ_TIMER0_0*      = 0;
    IRQ_TIMER0_1*      = 1;
    IRQ_TIMER0_2*      = 2;
    IRQ_TIMER0_3*      = 3;
    IRQ_TIMER1_0*      = 4;
    IRQ_TIMER2_1*      = 5;
    IRQ_TIMER3_2*      = 6;
    IRQ_TIMER4_3*      = 7;
    IRQ_PWM_WRAP_0*    = 8;
    IRQ_PWM_WRAP_1*    = 9;
    IRQ_DMA_0*         = 10;
    IRQ_DMA_1*         = 11;
    IRQ_DMA_2*         = 12;
    IRQ_DMA_3*         = 13;
    IRQ_USBCTRL*       = 14;
    IRQ_PIO0_0*        = 15;
    IRQ_PIO0_1*        = 16;
    IRQ_PIO1_0*        = 17;
    IRQ_PIO1_1*        = 18;
    IRQ_PIO2_0*        = 19;
    IRQ_PIO2_1*        = 20;
    IRQ_IO_BANK0*      = 21; (* core local *)
    IRQ_IO_BANK0_NS*   = 22; (* core local *)
    IRQ_IO_QSPI*       = 23; (* core local *)
    IRQ_IO_QSPI_NS*    = 24; (* core local *)
    IRQ_SIO_FIFO*      = 25; (* core local *)
    IRQ_SIO_BELL*      = 26; (* core local *)
    IRQ_SIO_FIFO_NS*   = 27; (* core local *)
    IRQ_SIO_BELL_NS*   = 28; (* core local *)
    IRQ_SIO_MTIMECMP*  = 29; (* core local *)
    IRQ_CLOCKS*        = 30;
    IRQ_SPI0*          = 31;
    IRQ_SPI1*          = 32;
    IRQ_UART0*         = 33;
    IRQ_UART1*         = 34;
    IRQ_ADC_FIFO*      = 35;
    IRQ_I2C0*          = 36;
    IRQ_I2C1*          = 37;
    IRQ_OTP*           = 38;
    IRQ_TRNG*          = 39;
    IRQ_PROC0_CTI*     = 40;
    IRQ_PROC1_CTI*     = 41;
    IRQ_PLL_SYS*       = 42;
    IRQ_PLL_USB*       = 43;
    IRQ_POWMAN_POW*    = 44;
    IRQ_POWMAN_TIMER*  = 45;
    IRQ_SPAREIRQ_0*    = 46;
    IRQ_SPAREIRQ_1*    = 47;
    IRQ_SPAREIRQ_2*    = 48;
    IRQ_SPAREIRQ_3*    = 49;
    IRQ_SPAREIRQ_4*    = 50;
    IRQ_SPAREIRQ_5*    = 51;

    (* -- IRQ for SW use -- *)
    IRQ_SW_0*   = IRQ_SPAREIRQ_0;
    IRQ_SW_1*   = IRQ_SPAREIRQ_1;
    IRQ_SW_2*   = IRQ_SPAREIRQ_2;
    IRQ_SW_3*   = IRQ_SPAREIRQ_3;
    IRQ_SW_4*   = IRQ_SPAREIRQ_4;
    IRQ_SW_5*   = IRQ_SPAREIRQ_5;

END EXC.
