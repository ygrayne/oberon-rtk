MODULE Exceptions;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Exception management
  --
  Note: these procedures must be used on the core whose SCS registers
  and vector table shall be addressed.
  --
  MCU: RP2040
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, ASM, EXC, Errors;

  CONST
    IRQ0_VectOffset = 040H;

  (* IPSR *)

  PROCEDURE* GetExcNo*(VAR excNo: INTEGER);
    CONST R = 3;
  BEGIN
    SYSTEM.EMIT(ASM.MRS_R03_IPSR);
    excNo := SYSTEM.REG(R)
  END GetExcNo;

  (* IRQs, via NVIC *)

  PROCEDURE* EnableInt*(intNo: INTEGER);
  BEGIN
    SYSTEM.PUT(PPB.NVIC_ISER0, {intNo});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END EnableInt;


  PROCEDURE* GetEnabledInt*(intNo: INTEGER; VAR en: BOOLEAN);
    VAR x: SET;
  BEGIN
    SYSTEM.GET(PPB.NVIC_ISER0, x);
    en := intNo IN x
  END GetEnabledInt;


  PROCEDURE* DisableInt*(intNo: INTEGER);
  BEGIN
    SYSTEM.PUT(PPB.NVIC_ICER0, {intNo});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END DisableInt;


  PROCEDURE* SetPendingInt*(intNo: INTEGER);
  BEGIN
    SYSTEM.PUT(PPB.NVIC_ISPR0, {intNo});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END SetPendingInt;


  PROCEDURE* GetPendingInt*(intNo: INTEGER; VAR pend: BOOLEAN);
    VAR x: SET;
  BEGIN
    SYSTEM.GET(PPB.NVIC_ISPR0, x);
    pend := intNo IN x
  END GetPendingInt;


  PROCEDURE* ClearPendingInt*(intNo: INTEGER);
  BEGIN
    SYSTEM.PUT(PPB.NVIC_ICPR0, {intNo});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END ClearPendingInt;


  PROCEDURE* SetIntPrio*(intNo, prio: INTEGER);
  (* 0 <= prio <= 0FFH *)
  (* prio's two most significant bits (of eight) used => four levels *)
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.ProgError);
    prio := prio MOD 0100H;
    addr := PPB.NVIC_IPR0 + ((intNo DIV 4) * 4);
    SYSTEM.GET(addr, x);
    x := x + LSL(prio, (intNo MOD 4) * 8);
    SYSTEM.PUT(addr, x);
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END SetIntPrio;


  PROCEDURE* GetIntPrio*(intNo: INTEGER; VAR prio: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.ProgError);
    addr := PPB.NVIC_IPR0 + ((intNo DIV 4) * 4);
    SYSTEM.GET(addr, prio);
    prio := LSR(prio, (intNo MOD 4) * 8);
    prio := prio MOD 0100H
  END GetIntPrio;


  PROCEDURE* InstallIntHandler*(intNo: INTEGER; handler: PROCEDURE);
    VAR vectAddr, vtor: INTEGER;
  BEGIN
    ASSERT(intNo < EXC.NumInterrupts, Errors.ProgError);
    SYSTEM.GET(PPB.VTOR, vtor);
    vectAddr := vtor + IRQ0_VectOffset + (intNo * 4);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler);
    SYSTEM.EMIT(ASM.DSB)
  END InstallIntHandler;

  (* system exception handlers *)

  PROCEDURE* SetSysExcPrio*(excNo, prio: INTEGER);
    CONST SHPR0 = PPB.SHPR1 - 04H;
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(excNo IN PPB.SysExc, Errors.PreCond);
    prio := prio MOD 0100H;
    addr := SHPR0 + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, x);
    x := x + LSL(prio, (excNo MOD 4) * 8);
    SYSTEM.PUT(addr, x);
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END SetSysExcPrio;


  PROCEDURE* GetSysExcPrio*(excNo: INTEGER; VAR prio: INTEGER);
    CONST SHPR0 = PPB.SHPR1 - 04H;
    VAR addr: INTEGER;
  BEGIN
    ASSERT(excNo IN PPB.SysExc, Errors.PreCond);
    addr := SHPR0 + (excNo DIV 4) * 4;
    SYSTEM.GET(addr, prio);
    prio := LSR(prio, (excNo MOD 4) * 8);
    prio := prio MOD 0100H
  END GetSysExcPrio;


  PROCEDURE* InstallSysExcHandler*(excNo: INTEGER; handler: PROCEDURE);
    VAR vtor, vectAddr: INTEGER;
  BEGIN
    SYSTEM.GET(PPB.VTOR, vtor);
    vectAddr := vtor + (excNo * 4);
    INCL(SYSTEM.VAL(SET, handler), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, handler);
    SYSTEM.EMIT(ASM.DSB)
  END InstallSysExcHandler;

END Exceptions.
