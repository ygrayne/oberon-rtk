MODULE Stacktr1;
(**
  Oberon RTK Framework v2
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/syscall
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Exceptions, MultiCore, InitCoreOne, SysCall;

  CONST
    IntNo0 = MCU.PPB_SPAREIRQ_IRQ0;
    IntNo1 = MCU.PPB_SPAREIRQ_IRQ1;

    SVCinstIRQ0 = MCU.SVC + SysCall.SVCvalIRQ0;
    SVCinstIRQ1 = MCU.SVC + SysCall.SVCvalIRQ1;

  VAR
    p: PROCEDURE;

  PROCEDURE* fault;
  (* trigger MCU fault *)
    VAR x: INTEGER;
  BEGIN
    x := MCU.PPB_NVIC_ISER0 + 1;
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
    SYSTEM.GET(MCU.SIO_CPUID, cid);
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
    SYSTEM.EMITH(SVCinstIRQ1)
  END h2;

  PROCEDURE h1;
  (* FPU operation to test correct stack trace on RP2350 *)
  (* on core 0 only: FPU on core 1 not enabled *)
    VAR r: REAL; cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
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
    y := 13;
    (* set int for h0 pending *)
    SYSTEM.EMITH(SVCinstIRQ0);
    p1a
  END p1;

  PROCEDURE p0;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, MCU.PPB_ExcPrio4);
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, MCU.PPB_ExcPrio2);
    Exceptions.EnableInt(IntNo1);
    SysCall.Init;
    p
  END run;

BEGIN
  p := p0;
  MultiCore.StartCoreOne(run, InitCoreOne.Init);
  run
END Stacktr1.
