MODULE TestExc1;
(**
  Oberon RTK Framework v2
  --
  Example/test program
  https://oberon-rtk.org/examples/v2/stacktrace
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Out, Exceptions;

  CONST
    IntNo0 = MCU.PPB_SPAREIRQ_IRQ0;
    IntNo1 = MCU.PPB_SPAREIRQ_IRQ1;

    TestCase = 1;

  PROCEDURE fault;
  (* trigger MCU fault *)
    VAR x: INTEGER;
  BEGIN
    x := MCU.PPB_NVIC_ISER0 + 1;
    SYSTEM.PUT(x, x)
  END fault;

  PROCEDURE error;
  (* trigger runtime error *)
    VAR x: INTEGER;
  BEGIN
    x := 0; x := x DIV x
  END error;

  PROCEDURE i2;
  BEGIN
    IF TestCase = 1 THEN
      fault
    ELSIF TestCase = 2 THEN
      error
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

  PROCEDURE h2a;
  END h2a;

  PROCEDURE h2;
    VAR x: INTEGER;
  BEGIN
    x := 0;
    h2a;
    (* set int pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
    x := 0;
  END h2;

  PROCEDURE h1;
  (* FPU operation to test correct stack trace on RP2350 *)
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
  END p1a;

  PROCEDURE p1b;
  END p1b;

  PROCEDURE p1;
    VAR x: INTEGER;
  BEGIN
    x := 0;
    p1a;
    (* set int pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
    x := 0;
    p1b
  END p1;

  PROCEDURE p0;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH);
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    Out.Ln; Out.String("TestCase = "); Out.Int(TestCase, 0); Out.Ln;
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, MCU.PPB_ExcPrio4);
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, MCU.PPB_ExcPrio2);
    Exceptions.EnableInt(IntNo1);
    p0
  END run;

BEGIN
  run
END TestExc1.
