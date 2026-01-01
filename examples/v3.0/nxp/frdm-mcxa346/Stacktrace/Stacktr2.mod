MODULE Stacktr2;
(**
  Oberon RTK Framework v3.0
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: MCXA346
  Board: FRDM-MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Exceptions, Main;

  CONST
    IntNo0 = MCU.IRQ_SW_0;
    IntNo1 = MCU.IRQ_SW_1;

  VAR
    p: PROCEDURE;

  PROCEDURE* i0[0];
    VAR x: INTEGER;
  BEGIN
    x := 0; x := x DIV x
  END i0;

  PROCEDURE* h0[0];
    VAR x: INTEGER;
  BEGIN
    x := 13;
    (* set int for i0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
    (*SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)*)
  END h0;

  PROCEDURE* p1;
  BEGIN
    (* set int for h0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
    (*SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)*)
  END p1;

  PROCEDURE p0;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, MCU.ExcPrio80);
    (*Exceptions.SetIntPrio(IntNo0, MCU.ExcPrio40) *) (* for tail-chaining *)
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, MCU.ExcPrio40);
    Exceptions.EnableInt(IntNo1);
    p
  END run;

BEGIN
  p := p0;
  run
END Stacktr2.
