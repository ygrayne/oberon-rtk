MODULE Stacktr1;
(**
  Oberon RTK Framework v3.1
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, PPB, EXC, ASM, Main, Cores, Exceptions;

  CONST
    (* otherwise unused interrupts *)
    IntNo0 = EXC.IRQ_SW_0;
    IntNo1 = EXC.IRQ_SW_1;

  VAR
    p: PROCEDURE;

  PROCEDURE* fault;
  (* trigger MCU fault *)
    VAR x: INTEGER;
  BEGIN
    x := PPB.NVIC_ISER0 + 1;
    SYSTEM.PUT(x, x)
  END fault;

  PROCEDURE* error;
  (* trigger runtime error *)
    VAR x: INTEGER;
  BEGIN
    x := 0; x := x DIV x
  END error;

  PROCEDURE i2;
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);;
    IF cid = 0 THEN
      error
    ELSE
      fault
    END
  END i2;

  PROCEDURE i1;
  BEGIN
    i2
  END i1;

  PROCEDURE i0[0];
  BEGIN
    i1
  END i0;

  PROCEDURE h2;
  BEGIN
    (* set int for i0 pending *)
    SYSTEM.PUT(PPB.NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END h2;

  PROCEDURE h1;
  (* FPU operation to test correct stack trace *)
    VAR r: REAL;
  BEGIN
    r := 1.0;
    r := r / r;
    h2
  END h1;

  PROCEDURE h0[0];
  BEGIN
    h1
  END h0;

  PROCEDURE p1a;
    VAR x: INTEGER;
  BEGIN
    x := 42
  END p1a;

  PROCEDURE p1;
    VAR y: INTEGER;
  BEGIN
    (* set int for h0 pending *)
    SYSTEM.PUT(PPB.NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB);
    p1a
  END p1;

  PROCEDURE p0;
    VAR a: ARRAY 1024 OF INTEGER;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, EXC.ExcPrio4);
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, EXC.ExcPrio2);
    Exceptions.EnableInt(IntNo1);
    p
  END run;

BEGIN
  p := p0;
  Cores.StartCoreOne(run, Main.ConfigC1);
  run
END Stacktr1.
