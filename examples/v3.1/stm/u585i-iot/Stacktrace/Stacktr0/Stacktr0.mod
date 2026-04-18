MODULE Stacktr0;
(**
  Oberon RTK Framework v3.1
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, PPB, Main;

  CONST
    CaseError = 0;
    CaseFault = 1;
    Case = CaseError;

  VAR p: PROCEDURE;

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

  PROCEDURE p2;
  BEGIN
    IF Case = 0 THEN
      error
    ELSE
      fault
    END
  END p2;

  PROCEDURE p1;
    VAR a: ARRAY 512 OF INTEGER; r: REAL;
  BEGIN

    r := 1.0;
    r := r / r;

    p2
  END p1;

  PROCEDURE p0;
    CONST R12 = 12;
    VAR x, y: INTEGER;
  BEGIN
    SYSTEM.LDREG(R12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    p
  END run;

BEGIN
  p := p0;
  run
END Stacktr0.
