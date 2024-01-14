MODULE Exceptions;
(**
  Oberon RTK Framework
  Exception management
  --
  Interrupts (IRQ):
  * IRQ 0 .. 26 are wired on the NVIC
  * IRQ 27 .. 31 can be used for SW-triggered interrupts
  * configure via NVIC
  * IRQ0 = exception 16
  --
  System exceptions:
  * SysTick: exception 15
  * PendSV: exception 14
  * SVC: exception 11
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2023 Gray, gray@grayraven.org
**)

  IMPORT SYSTEM, MCU := MCU2, Error;

  CONST
    (* IRQ numbers *)
    TIMER_IRQ_0*    = 0;
    TIMER_IRQ_1*    = 1;
    TIMER_IRQ_2*    = 2;
    TIMER_IRQ_3*    = 3;
    PWM_IRQ_WRAP*   = 4;
    USBCTRL_IRQ*    = 5;
    XIP_IRQ*        = 6;
    PIO0_IRQ_0*     = 7;
    PIO0_IRQ_1*     = 8;
    PIO1_IRQ_0*     = 9;
    PIO1_IRQ_1*     = 10;
    DMA_IRQ_0*      = 11; (* config via MCU.DMA_INTE0 *)
    DMA_IRQ_1*      = 12; (* config via MCU.DMA_INTE1 *)
    IO_IRQ_BANK0*   = 13;
    IO_IRQ_QSPI*    = 14;
    SIO_IRQ_PROC0*  = 15;
    SIO_IRQ_PROC1*  = 16;
    CLOCKS_IRQ*     = 17;
    SPI0_IRQ*       = 18;
    SPI1_IRQ*       = 19;
    UART0_IRQ*      = 20;
    UART1_IRQ*      = 21;
    ADC_IRQ_FIFO*   = 22;
    I2C0_IRQ*       = 23;
    I2C1_IRQ*       = 24;
    RTC_IRQ*        = 25;

    WiredIrq* = {0 .. 25};
    UnwiredIrq*= {26 .. 31};
    AllIrq* = {0 .. 31};

    SysExcNo* = {11, 14, 15};
    SysExcSysTickNo* = 15;

  (* IRQs, via NVIC *)

  PROCEDURE EnableInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.NVIC_ISER, irqMask)
  END EnableInt;

  PROCEDURE GetEnabledInt*(VAR en: SET);
  BEGIN
    SYSTEM.GET(MCU.NVIC_ISER, en)
  END GetEnabledInt;

  PROCEDURE DisableInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.NVIC_ICER, irqMask)
  END DisableInt;

  PROCEDURE SetPendingInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.NVIC_ISPR, irqMask)
  END SetPendingInt;

  PROCEDURE GetPendingInt*(VAR pend: SET);
  BEGIN
    SYSTEM.GET(MCU.NVIC_ISPR, pend)
  END GetPendingInt;

  PROCEDURE ClearPendingInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.NVIC_ICPR, irqMask)
  END ClearPendingInt;

  PROCEDURE SetIntPrio*(irqNo, prio: INTEGER);
  (* prio: 0 to 3, 0 - highest *)
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.NVIC_IPR + ((irqNo DIV 4) * 4);
    SYSTEM.GET(addr, x);
    x := x + LSL(LSL(prio, 6), (irqNo MOD 4) * 8);
    SYSTEM.PUT(addr, x)
  END SetIntPrio;

  PROCEDURE GetIntPrio*(irqNo: INTEGER; VAR prio: INTEGER);
  (* prio: 0 to 3, 0 - highest *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.NVIC_IPR + ((irqNo DIV 4) * 4);
    SYSTEM.GET(addr, prio)
  END GetIntPrio;

  PROCEDURE InstallIntHandler*(irqNo: INTEGER; handler: PROCEDURE);
    VAR vectAddr, vtor: INTEGER; addr: SET;
  BEGIN
    SYSTEM.GET(MCU.SCB_VTOR, vtor);
    vectAddr := vtor + MCU.IrqZeroHandlerOffset + (4 * irqNo);
    SYSTEM.PUT(vectAddr, handler);
    SYSTEM.GET(vectAddr, addr);
    INCL(addr, 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, addr)
  END InstallIntHandler;


  (* system handlers *)

  PROCEDURE SetSysExcPrio*(excNo, prio: INTEGER);
  (* prio: 0 to 3, 0 = highest *)
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(excNo IN SysExcNo, Error.PreCond);
    addr := MCU.SCB_SHPR - 04H + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, x);
    x := x + LSL(LSL(prio, 6), (excNo MOD 4) * 8);
    SYSTEM.PUT(addr, x)
  END SetSysExcPrio;

  PROCEDURE GetSysExcPrio*(excNo: INTEGER; VAR prio: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(excNo IN SysExcNo, Error.PreCond);
    addr := MCU.SCB_SHPR - 04H + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, prio);
  END GetSysExcPrio;

  PROCEDURE InstallExcHandler*(vectOffset: INTEGER; handler: PROCEDURE);
    VAR addr: SET; vtor, vectAddr: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SCB_VTOR, vtor);
    vectAddr := vtor + vectOffset;
    SYSTEM.PUT(vectAddr, handler);
    SYSTEM.GET(vectAddr, addr);
    INCL(addr, 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, addr)
  END InstallExcHandler;


  (* NMI *)

  PROCEDURE SetNMI*(cid: INTEGER; irqMask: SET);
  BEGIN
    ASSERT(cid IN {0 .. 1}, Error.PreCond);
    CASE cid OF
      0: SYSTEM.PUT(MCU.SYSCFG_PROC0_NMI_MASK, irqMask)
    | 1: SYSTEM.PUT(MCU.SYSCFG_PROC1_NMI_MASK, irqMask)
    END
  END SetNMI;

END Exceptions.
