MODULE Exceptions;
(**
  Oberon RTK Framework
  --
  Exception management
  --
  MCU: RP2040, not yet extended/adapted for RP2350
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

  CONST
    NumCores = MCU.NumCores;

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
    SYSTEM.PUT(MCU.PPB_NVIC_ISER0, irqMask)
  END EnableInt;


  PROCEDURE GetEnabledInt*(VAR en: SET);
  BEGIN
    SYSTEM.GET(MCU.PPB_NVIC_ISER0, en)
  END GetEnabledInt;


  PROCEDURE DisableInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.PPB_NVIC_ICER0, irqMask)
  END DisableInt;


  PROCEDURE SetPendingInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0, irqMask)
  END SetPendingInt;


  PROCEDURE GetPendingInt*(VAR pend: SET);
  BEGIN
    SYSTEM.GET(MCU.PPB_NVIC_ISPR0, pend)
  END GetPendingInt;


  PROCEDURE ClearPendingInt*(irqMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.PPB_NVIC_ICPR0, irqMask)
  END ClearPendingInt;


  PROCEDURE SetIntPrio*(irqNo, prio: INTEGER);
  (* prio: 0 to 3, 0 = highest *)
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.PPB_NVIC_IPR0 + ((irqNo DIV 4) * 4);
    SYSTEM.GET(addr, x);
    x := x + LSL(LSL(prio, 6), (irqNo MOD 4) * 8);
    SYSTEM.PUT(addr, x)
  END SetIntPrio;


  PROCEDURE GetIntPrio*(irqNo: INTEGER; VAR prio: INTEGER);
  (* prio: 0 to 3, 0 = highest *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PPB_NVIC_IPR0 + ((irqNo DIV 4) * 4);
    SYSTEM.GET(addr, prio)
  END GetIntPrio;


  PROCEDURE InstallIntHandler*(irqNo: INTEGER; handler: PROCEDURE);
    VAR vectAddr, vtor: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.PPB_VTOR, vtor);
    vectAddr := vtor + MCU.IrqZeroHandlerOffset + (4 * irqNo);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallIntHandler;

  (* system handlers *)

  PROCEDURE SetSysExcPrio*(excNo, prio: INTEGER);
  (* prio: 0 to 3, 0 = highest *)
    CONST SHPR0 = MCU.PPB_SHPR1 - 04H;
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(excNo IN MCU.PPB_NVIC_SysExc, Errors.PreCond);
    addr := SHPR0 + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, x);
    x := x + LSL(LSL(prio, 6), (excNo MOD 4) * 8);
    SYSTEM.PUT(addr, x)
  END SetSysExcPrio;


  PROCEDURE GetSysExcPrio*(excNo: INTEGER; VAR prio: INTEGER);
    CONST SHPR0 = MCU.PPB_SHPR1 - 04H;
    VAR addr: INTEGER;
  BEGIN
    ASSERT(excNo IN MCU.PPB_NVIC_SysExc, Errors.PreCond);
    addr := SHPR0 + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, prio);
  END GetSysExcPrio;


  PROCEDURE InstallExcHandler*(vectOffset: INTEGER; handler: PROCEDURE);
    VAR vtor, vectAddr: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.PPB_VTOR, vtor);
    vectAddr := vtor + vectOffset;
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallExcHandler;


  (* NMI *)

  PROCEDURE SetNMI*(cid: INTEGER; irqMask: SET);
  BEGIN
    ASSERT(cid IN {0 .. NumCores - 1}, Errors.PreCond);
    CASE cid OF
      0: SYSTEM.PUT(MCU.SYSCFG_PROC0_NMI_MASK, irqMask)
    | 1: SYSTEM.PUT(MCU.SYSCFG_PROC1_NMI_MASK, irqMask)
    END
  END SetNMI;

END Exceptions.
