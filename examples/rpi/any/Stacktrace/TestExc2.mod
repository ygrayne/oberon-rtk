MODULE TestExc2;
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

  IMPORT SYSTEM, MCU := MCU2, Main;

  PROCEDURE error;
    VAR x: INTEGER;
  BEGIN
    x := 0;
    x := x DIV x
  END error;

  PROCEDURE fault;
    VAR x: INTEGER;
  BEGIN
    x := MCU.PPB_NVIC_ISER0 + 1;
    SYSTEM.PUT(x, x)
  END fault;

  PROCEDURE p0;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH);
    (*error*)
    fault
  END p0;

  PROCEDURE run;
  BEGIN
    p0
  END run;

BEGIN
  run
END TestExc2.
