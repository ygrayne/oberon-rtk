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
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

  CONST
    (* IRQ numbers *)
    TIMER_IRQ_0*    = MCU.NVIC_TIMER_IRQ_0;
    TIMER_IRQ_1*    = MCU.NVIC_TIMER_IRQ_1;
    TIMER_IRQ_2*    = MCU.NVIC_TIMER_IRQ_2;
    TIMER_IRQ_3*    = MCU.NVIC_TIMER_IRQ_3;
    PWM_IRQ_WRAP*   = MCU.NVIC_PWM_IRQ_WRAP;
    USBCTRL_IRQ*    = MCU.NVIC_USBCTRL_IRQ;
    XIP_IRQ*        = MCU.NVIC_XIP_IRQ;
    PIO0_IRQ_0*     = MCU.NVIC_PIO0_IRQ_0;
    PIO0_IRQ_1*     = MCU.NVIC_PIO0_IRQ_1;
    PIO1_IRQ_0*     = MCU.NVIC_PIO1_IRQ_0;
    PIO1_IRQ_1*     = MCU.NVIC_PIO1_IRQ_1;
    DMA_IRQ_0*      = MCU.NVIC_DMA_IRQ_0; (* config via MCU.DMA_INTE0 *)
    DMA_IRQ_1*      = MCU.NVIC_DMA_IRQ_1; (* config via MCU.DMA_INTE1 *)
    IO_IRQ_BANK0*   = MCU.NVIC_IO_IRQ_BANK0;
    IO_IRQ_QSPI*    = MCU.NVIC_IO_IRQ_QSPI;
    SIO_IRQ_PROC0*  = MCU.NVIC_SIO_IRQ_PROC0;
    SIO_IRQ_PROC1*  = MCU.NVIC_SIO_IRQ_PROC1;
    CLOCKS_IRQ*     = MCU.NVIC_CLOCKS_IRQ;
    SPI0_IRQ*       = MCU.NVIC_SPI0_IRQ;
    SPI1_IRQ*       = MCU.NVIC_SPI1_IRQ;
    UART0_IRQ*      = MCU.NVIC_UART0_IRQ;
    UART1_IRQ*      = MCU.NVIC_UART1_IRQ;
    ADC_IRQ_FIFO*   = MCU.NVIC_ADC_IRQ_FIFO;
    I2C0_IRQ*       = MCU.NVIC_I2C0_IRQ;
    I2C1_IRQ*       = MCU.NVIC_I2C1_IRQ;
    RTC_IRQ*        = MCU.NVIC_RTC_IRQ;

    WiredIrq* = {0 .. 25};
    UnwiredIrq*= {26 .. 31};
    AllIrq* = {0 .. 31};

    SysExcNo* = {11, 14, 15};
    SysExcSysTickNo* = 15;

  (* ISPR *)

  PROCEDURE GetIntStatus*(VAR status: INTEGER);
    CONST R0 = 0;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R00_IPSR);
    status := SYSTEM.REG(R0)
  END GetIntStatus;

  (* IRQs, via NVIC *)

  PROCEDURE EnableInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.M0PLUS_NVIC_ISER, irqMask)
  END EnableInt;


  PROCEDURE GetEnabledInt*(VAR en: SET);
  BEGIN
    SYSTEM.GET(MCU.M0PLUS_NVIC_ISER, en)
  END GetEnabledInt;


  PROCEDURE DisableInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.M0PLUS_NVIC_ICER, irqMask)
  END DisableInt;


  PROCEDURE SetPendingInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.M0PLUS_NVIC_ISPR, irqMask)
  END SetPendingInt;


  PROCEDURE GetPendingInt*(VAR pend: SET);
  BEGIN
    SYSTEM.GET(MCU.M0PLUS_NVIC_ISPR, pend)
  END GetPendingInt;


  PROCEDURE ClearPendingInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.M0PLUS_NVIC_ICPR, irqMask)
  END ClearPendingInt;


  PROCEDURE SetIntPrio*(irqNo, prio: INTEGER);
  (* prio: 0 to 3, 0 = highest *)
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.M0PLUS_NVIC_IPR + ((irqNo DIV 4) * 4);
    SYSTEM.GET(addr, x);
    x := x + LSL(LSL(prio, 6), (irqNo MOD 4) * 8);
    SYSTEM.PUT(addr, x)
  END SetIntPrio;


  PROCEDURE GetIntPrio*(irqNo: INTEGER; VAR prio: INTEGER);
  (* prio: 0 to 3, 0 = highest *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.M0PLUS_NVIC_IPR + ((irqNo DIV 4) * 4);
    SYSTEM.GET(addr, prio)
  END GetIntPrio;


  PROCEDURE InstallIntHandler*(irqNo: INTEGER; handler: PROCEDURE);
    VAR vectAddr, vtor: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.M0PLUS_VTOR, vtor);
    vectAddr := vtor + MCU.IrqZeroHandlerOffset + (4 * irqNo);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallIntHandler;

  (* system handlers *)

  PROCEDURE SetSysExcPrio*(excNo, prio: INTEGER);
  (* prio: 0 to 3, 0 = highest *)
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(excNo IN SysExcNo, Errors.PreCond);
    addr := MCU.M0PLUS_SHPR - 04H + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, x);
    x := x + LSL(LSL(prio, 6), (excNo MOD 4) * 8);
    SYSTEM.PUT(addr, x)
  END SetSysExcPrio;


  PROCEDURE GetSysExcPrio*(excNo: INTEGER; VAR prio: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(excNo IN SysExcNo, Errors.PreCond);
    addr := MCU.M0PLUS_SHPR - 04H + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, prio);
  END GetSysExcPrio;


  PROCEDURE InstallExcHandler*(vectOffset: INTEGER; handler: PROCEDURE);
    VAR vtor, vectAddr: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.M0PLUS_VTOR, vtor);
    vectAddr := vtor + vectOffset;
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallExcHandler;


  (* NMI *)

  PROCEDURE SetNMI*(cid: INTEGER; irqMask: SET);
  BEGIN
    ASSERT(cid IN {0 .. 1}, Errors.PreCond);
    CASE cid OF
      0: SYSTEM.PUT(MCU.SYSCFG_PROC0_NMI_MASK, irqMask)
    | 1: SYSTEM.PUT(MCU.SYSCFG_PROC1_NMI_MASK, irqMask)
    END
  END SetNMI;

END Exceptions.
