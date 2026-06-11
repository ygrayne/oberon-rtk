MODULE Stacktr0;
(**
  Oberon RTK Framework v3.1
  --
  Example/test program, no kernel
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, PPB, Main, Out;

  CONST
    Error = 0;
    Fault = 1;
    Case = Error;

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
    IF Case = Error THEN
      Out.String("error"); Out.Ln;
      error
    ELSE
      Out.String("fault"); Out.Ln;
      fault
    END
  END p2;

  PROCEDURE p1;
    (* unused large array to check for false trace positives *)
    VAR a: ARRAY 512 OF INTEGER; r: REAL;
  BEGIN
    (* real operation to check FPU stacking *)
    r := 1.0;
    r := r / r;
    p2
  END p1;

  PROCEDURE p0;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH); (* marker/sentinel *)
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
