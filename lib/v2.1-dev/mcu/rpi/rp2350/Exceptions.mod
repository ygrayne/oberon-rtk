MODULE Exceptions;
(**
  Oberon RTK Framework v2
  --
  Exception management
  --
  Note: these procedures must be used on the core whose SCS registers
  and vector table shall be addressed.
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

  CONST
    IRQ0_VectOffset = 040H;

  (* IPSR *)

  PROCEDURE* GetIntStatus*(VAR status: INTEGER);
    CONST R0 = 0;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R00_IPSR);
    status := SYSTEM.REG(R0);
    status := BFX(status, 8, 0)
  END GetIntStatus;

  (* interrupts (IRQs) *)

  PROCEDURE* iset(intNo, ireg: INTEGER);
  BEGIN
    ASSERT(intNo < MCU.NumInterrupts, Errors.ProgError);
    SYSTEM.PUT(ireg + ((intNo DIV 32) * 4), {intNo MOD 32});
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
  END iset;

  PROCEDURE* iget(intNo, ireg: INTEGER; VAR value: BOOLEAN);
    VAR x: SET;
  BEGIN
    ASSERT(intNo < MCU.NumInterrupts, Errors.ProgError);
    SYSTEM.GET(ireg + ((intNo DIV 32) * 4), x);
    value := (intNo MOD 32) IN x
  END iget;


  PROCEDURE EnableInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, MCU.PPB_NVIC_ISER0)
  END EnableInt;


  PROCEDURE GetEnabledInt*(intNo: INTEGER; VAR en: BOOLEAN);
  BEGIN
    iget(intNo, MCU.PPB_NVIC_ISER0, en)
  END GetEnabledInt;


  PROCEDURE DisableInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, MCU.PPB_NVIC_ICER0)
  END DisableInt;


  PROCEDURE SetPendingInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, MCU.PPB_NVIC_ISPR0)
  END SetPendingInt;


  PROCEDURE GetPendingInt*(intNo: INTEGER; VAR pend: BOOLEAN);
  BEGIN
    iget(intNo, MCU.PPB_NVIC_ISPR0, pend)
  END GetPendingInt;


  PROCEDURE ClearPendingInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, MCU.PPB_NVIC_ICPR0)
  END ClearPendingInt;


  PROCEDURE* SetIntPrio*(intNo, prio: INTEGER);
  (* 0 <= prio <= 0FFH *)
  (* prio's three most significant bits (of eight) used => eight levels *)
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(intNo < MCU.NumInterrupts, Errors.ProgError);
    prio := prio MOD 0100H;
    addr := MCU.PPB_NVIC_IPR0 + ((intNo DIV 4) * 4);
    SYSTEM.GET(addr, x);
    x := x + LSL(prio, (intNo MOD 4) * 8);
    SYSTEM.PUT(addr, x);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
  END SetIntPrio;


  PROCEDURE* GetIntPrio*(intNo: INTEGER; VAR prio: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(intNo < MCU.NumInterrupts, Errors.ProgError);
    addr := MCU.PPB_NVIC_IPR0 + ((intNo DIV 4) * 4);
    SYSTEM.GET(addr, prio);
    prio := LSR(prio, (intNo MOD 4) * 8);
    prio := prio MOD 0100H
  END GetIntPrio;


  PROCEDURE* InstallIntHandler*(intNo: INTEGER; handler: PROCEDURE);
    VAR vectAddr, vtor: INTEGER;
  BEGIN
    ASSERT(intNo < MCU.NumInterrupts, Errors.ProgError);
    ASSERT(handler # NIL, Errors.PreCond);
    SYSTEM.GET(MCU.PPB_VTOR, vtor);
    vectAddr := vtor + IRQ0_VectOffset + (intNo * 4);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallIntHandler;

  (* system exceptions *)

  PROCEDURE* SetSysExcPrio*(excNo, prio: INTEGER);
    CONST SHPR0 = MCU.PPB_SHPR1 - 04H;
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(excNo IN MCU.PPB_SysExc, Errors.PreCond);
    prio := prio MOD 0100H;
    addr := SHPR0 + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, x);
    x := x + LSL(prio, (excNo MOD 4) * 8);
    SYSTEM.PUT(addr, x);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
  END SetSysExcPrio;


  PROCEDURE* GetSysExcPrio*(excNo: INTEGER; VAR prio: INTEGER);
    CONST SHPR0 = MCU.PPB_SHPR1 - 04H;
    VAR addr: INTEGER;
  BEGIN
    ASSERT(excNo IN MCU.PPB_SysExc, Errors.PreCond);
    addr := SHPR0 + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, prio);
    prio := LSR(prio, (excNo MOD 4) * 8);
    prio := prio MOD 0100H
  END GetSysExcPrio;


  PROCEDURE* InstallSysExcHandler*(excNo: INTEGER; handler: PROCEDURE);
    VAR vtor, vectAddr: INTEGER;
  BEGIN
    ASSERT(handler # NIL, Errors.PreCond);
    SYSTEM.GET(MCU.PPB_VTOR, vtor);
    vectAddr := vtor + (excNo * 4);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallSysExcHandler;

END Exceptions.
