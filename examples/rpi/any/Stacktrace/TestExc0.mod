MODULE TestExc0;
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

  IMPORT SYSTEM, MCU := MCU2, Main, Out;

  CONST
    TestCase = 0;

  PROCEDURE fault;
  (* trigger MCU fault *)
    VAR x: INTEGER;
  BEGIN
    x := MCU.PPB_NVIC_ISER0 + 1;
    SYSTEM.PUT(x, x)
  END fault;

  PROCEDURE p1;
  BEGIN
    fault
  END p1;

  PROCEDURE p0;
    CONST R12 = 12;
    (* VAR x, y, z: INTEGER; *)
  BEGIN
    SYSTEM.LDREG(R12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    Out.Ln; Out.String("TestCase = "); Out.Int(TestCase, 0); Out.Ln;
    p0
  END run;

BEGIN
  run
END TestExc0.
