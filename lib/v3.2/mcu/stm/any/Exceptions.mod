MODULE Exceptions;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Exception managements
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, EXC, ASM, Errors;

  CONST
    IRQ0_VectOffset = 040H;
    IntPerRegSet = 32;  (* interrupts per control register for enable/disable *)
    IntPerRegPrio = 4;  (* interrupts per control register for prio *)
    ExcPerRegPrio = 4;  (* sys exceptions per control register for prio *)
    RegOffset = 4;      (* control register offset *)
    PrioBits = 8;       (* width of prio field *)
    PrioMask = 0FFH;    (* mask corresponding to prio field width *)

  (* IPSR *)

  PROCEDURE* GetExcNo*(VAR excNo: INTEGER);
    CONST R = 3;
  BEGIN
    SYSTEM.EMIT(ASM.MRS_R03_IPSR);
    excNo := SYSTEM.REG(R)
  END GetExcNo;

  (* interrupts (IRQs) *)

  PROCEDURE* iset(intNo, ireg: INTEGER);
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.PreCond);
    SYSTEM.PUT(ireg + ((intNo DIV IntPerRegSet) * RegOffset), {intNo MOD IntPerRegSet});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END iset;

  PROCEDURE* iget(intNo, ireg: INTEGER; VAR value: BOOLEAN);
    VAR x: SET;
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.PreCond);
    SYSTEM.GET(ireg + ((intNo DIV IntPerRegSet) * RegOffset), x);
    value := (intNo MOD IntPerRegSet) IN x
  END iget;


  PROCEDURE EnableInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, PPB.NVIC_ISER0)
  END EnableInt;


  PROCEDURE GetEnabledInt*(intNo: INTEGER; VAR en: BOOLEAN);
  BEGIN
    iget(intNo, PPB.NVIC_ISER0, en)
  END GetEnabledInt;


  PROCEDURE DisableInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, PPB.NVIC_ICER0)
  END DisableInt;


  PROCEDURE SetPendingInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, PPB.NVIC_ISPR0)
  END SetPendingInt;


  PROCEDURE GetPendingInt*(intNo: INTEGER; VAR pend: BOOLEAN);
  BEGIN
    iget(intNo, PPB.NVIC_ISPR0, pend)
  END GetPendingInt;


  PROCEDURE ClearPendingInt*(intNo: INTEGER);
  BEGIN
    iset(intNo, PPB.NVIC_ICPR0)
  END ClearPendingInt;

(*
  PROCEDURE* SetIntPrio2*(intNo, prio: INTEGER);
  (* 0 <= prio <= 0FFH *)
  (* prio's three most significant bits (of eight) used => eight levels *)
    VAR addr, val, shift: INTEGER; clrMask: SET;
  BEGIN
    (*ASSERT(intNo < PPB.NumInterrupts, Errors.PreCond);*)
    prio := ORD(BITS(prio) * BITS(PrioMask));
    addr := PPB.NVIC_IPR0 + ((intNo DIV IntPerRegPrio) * RegOffset);
    shift := (intNo MOD IntPerRegPrio) * PrioBits;
    clrMask := -BITS(LSL(PrioMask, shift));
    SYSTEM.GET(addr, val);
    val := ORD(BITS(val) * clrMask);  (* clear existing setting *)
    val := val + LSL(prio, shift);    (* add new setting *)
    SYSTEM.PUT(addr, val);
    SYSTEM.EMIT(PPB.DSB); SYSTEM.EMIT(PPB.ISB)
  END SetIntPrio2;
*)

  PROCEDURE* SetIntPrio*(intNo, prio: INTEGER);
  (* 0 <= prio <= 0FFH *)
    VAR addr, shift: INTEGER; val, clrMask: SET;
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.PreCond);
    prio := ORD(BITS(prio) * BITS(PrioMask));
    addr := PPB.NVIC_IPR0 + ((intNo DIV IntPerRegPrio) * RegOffset);
    shift := (intNo MOD IntPerRegPrio) * PrioBits;
    clrMask := BITS(LSL(PrioMask, shift));
    SYSTEM.GET(addr, val);
    val := val - clrMask + BITS(LSL(prio, shift));
    SYSTEM.PUT(addr, val);
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END SetIntPrio;


  PROCEDURE* GetIntPrio*(intNo: INTEGER; VAR prio: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.PreCond);
    addr := PPB.NVIC_IPR0 + ((intNo DIV IntPerRegPrio) * RegOffset);
    SYSTEM.GET(addr, prio);
    prio := LSR(prio, (intNo MOD IntPerRegPrio) * PrioBits);
    prio := ORD(BITS(prio) * BITS(PrioMask));
  END GetIntPrio;


  PROCEDURE* InstallIntHandler*(intNo: INTEGER; handler: PROCEDURE);
    VAR vectAddr, vtor: INTEGER;
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.PreCond);
    ASSERT(handler # NIL, Errors.PreCond);
    SYSTEM.GET(PPB.VTOR, vtor);
    vectAddr := vtor + IRQ0_VectOffset + (intNo * 4);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallIntHandler;


  (* system exceptions *)
(*
  PROCEDURE* SetSysExcPrio2*(excNo, prio: INTEGER);
    CONST SHPR0 = PPB.SHPR1 - 04H;
    VAR addr, val, shift: INTEGER; clrMask: SET;
  BEGIN
    (*ASSERT(excNo IN PPB.SysExc, Errors.PreCond);*)
    prio := ORD(BITS(prio) * BITS(PrioMask));
    addr := SHPR0 + ((excNo DIV ExcPerRegPrio) * RegOffset);
    shift := (excNo MOD ExcPerRegPrio) * PrioBits;
    clrMask := -BITS(LSL(PrioMask, shift));
    SYSTEM.GET(addr, val);
    val := ORD(BITS(val) * clrMask);
    val := val + LSL(prio, shift);
    SYSTEM.PUT(addr, val);
    SYSTEM.EMIT(PPB.DSB); SYSTEM.EMIT(PPB.ISB)
  END SetSysExcPrio2;
*)

  PROCEDURE* SetSysExcPrio*(excNo, prio: INTEGER);
    CONST SHPR0 = PPB.SHPR1 - 04H;
    VAR addr, shift: INTEGER; val, clrMask: SET;
  BEGIN
    ASSERT(excNo IN PPB.SysExc, Errors.PreCond);
    prio := ORD(BITS(prio) * BITS(PrioMask));
    addr := SHPR0 + ((excNo DIV ExcPerRegPrio) * RegOffset);
    shift := (excNo MOD ExcPerRegPrio) * PrioBits;
    clrMask := BITS(LSL(PrioMask, shift));
    SYSTEM.GET(addr, val);
    val := val - clrMask + BITS(LSL(prio, shift));
    SYSTEM.PUT(addr, val);
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END SetSysExcPrio;


  PROCEDURE* GetSysExcPrio*(excNo: INTEGER; VAR prio: INTEGER);
    CONST SHPR0 = PPB.SHPR1 - 04H;
    VAR addr: INTEGER;
  BEGIN
    ASSERT(excNo IN PPB.SysExc, Errors.PreCond);
    addr := SHPR0 + (excNo DIV ExcPerRegPrio) * RegOffset;
    SYSTEM.GET(addr, prio);
    prio := LSR(prio, (excNo MOD ExcPerRegPrio) * PrioBits);
    prio := ORD(BITS(prio) * BITS(PrioMask))
  END GetSysExcPrio;


  PROCEDURE* InstallSysExcHandler*(excNo: INTEGER; handler: PROCEDURE);
    VAR vtor, vectAddr: INTEGER;
  BEGIN
    ASSERT(excNo IN PPB.SysExc, Errors.PreCond);
    ASSERT(handler # NIL, Errors.PreCond);
    SYSTEM.GET(PPB.VTOR, vtor);
    vectAddr := vtor + (excNo * 4);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler)
  END InstallSysExcHandler;

END Exceptions.
