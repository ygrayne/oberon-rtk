MODULE EXC;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Exceptions and IRQs.
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NumInterrupts*    = 32;
    VectorTableSize*  = 192; (* bytes: 16 sys exceptions + 32 interrupts, one word each *)


    (* -- exception priorities, 2 bits -- *)
    ExcPrio0* = 000H;   (* 0000 0000 *)
    ExcPrio2* = 040H;   (* 0100 0000 *)
    ExcPrio4* = 080H;   (* 1000 0000 *)
    ExcPrio6* = 0C0H;   (* 1100 0000 *)

    ExcPrio00* = 000H;  (* 0000 0000 *)
    ExcPrio40* = 040H;  (* 0100 0000 *)
    ExcPrio80* = 080H;  (* 1000 0000 *)
    ExcPrioC0* = 0C0H;  (* 1100 0000 *)

    NumExcPrio* = 4;

    ExcPrioTop*    = ExcPrio00;
    ExcPrioHigh*   = ExcPrio40;
    ExcPrioMedium* = ExcPrio80;
    ExcPrioLow*    = ExcPrioC0;


    (* IRQ numbers *)
    (* datasheet 32.3.2, p60 *)
    IRQ_BASE*       = 16; (* exc no = IRQ_BASE + IRQ number *)
    IRQ_TIMER0_0*   = 0;
    IRQ_TIMER0_1*   = 1;
    IRQ_TIMER0_2*   = 2;
    IRQ_TIMER0_3*   = 3;
    IRQ_PWM_WRAP_0* = 4;
    IRQ_USBCTRL*    = 5;
    IRQ_XIP*        = 6;
    IRQ_PIO0_0*     = 7;
    IRQ_PIO0_1*     = 8;
    IRQ_PIO1_0*     = 9;
    IRQ_PIO1_1*     = 10;
    IRQ_DMA_0*      = 11;
    IRQ_DMA_1*      = 12;
    IRQ_IO_BANK0*   = 13;
    IRQ_IO_QSPI*    = 14;
    IRQ_SIO_PROC0*  = 15;
    IRQ_SIO_PROC1*  = 16;
    IRQ_CLOCKS*     = 17;
    IRQ_SPI0*       = 18;
    IRQ_SPI1*       = 19;
    IRQ_UART0*      = 20;
    IRQ_UART1*      = 21;
    IRQ_ADC_FIFO*   = 22;
    IRQ_I2C0*       = 23;
    IRQ_I2C1*       = 24;
    IRQ_RTC*        = 25;
    IRQ_SPAREIRQ_0* = 26;
    IRQ_SPAREIRQ_1* = 27;
    IRQ_SPAREIRQ_2* = 28;
    IRQ_SPAREIRQ_3* = 29;
    IRQ_SPAREIRQ_4* = 30;
    IRQ_SPAREIRQ_5* = 31;

    (* -- IRQ for SW use -- *)
    IRQ_SW_0*   = IRQ_SPAREIRQ_0;
    IRQ_SW_1*   = IRQ_SPAREIRQ_1;
    IRQ_SW_2*   = IRQ_SPAREIRQ_2;
    IRQ_SW_3*   = IRQ_SPAREIRQ_3;
    IRQ_SW_4*   = IRQ_SPAREIRQ_4;
    IRQ_SW_5*   = IRQ_SPAREIRQ_5;


END EXC.
