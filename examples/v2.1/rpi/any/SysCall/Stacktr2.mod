MODULE Stacktr2;
(**
  Oberon RTK Framework v2
  --
  Example/test program
  https://oberon-rtk.org/examples/v2/syscall
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions, MultiCore, InitCoreOne, Main, SysCall;

  CONST
    IntNo0 = MCU.PPB_SPAREIRQ_IRQ0;
    IntNo1 = MCU.PPB_SPAREIRQ_IRQ1;

    SVCinstIRQ0 = MCU.SVC + SysCall.SVCvalIRQ0;
    SVCinstIRQ1 = MCU.SVC + SysCall.SVCvalIRQ1;

  VAR
    p: PROCEDURE;

  PROCEDURE* i0[0];
    VAR x: INTEGER;
  BEGIN
    x := 0; x := x DIV x
  END i0;

  PROCEDURE* h0[0];
  BEGIN
    (* set int for i0 pending *)
    SYSTEM.EMITH(SVCinstIRQ1)
  END h0;

  PROCEDURE* p1;
  BEGIN
    (* set int for h0 pending *)
    SYSTEM.EMITH(SVCinstIRQ0)
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
END Stacktr2.
