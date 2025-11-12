MODULE Stacktr0;
(**
  Oberon RTK Framework v2
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Main, Memory, MultiCore, InitCoreOne, Out;

  VAR p: PROCEDURE;

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

  PROCEDURE p2;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    IF cid = 0 THEN
      error
    ELSE
      fault
    END
  END p2;

  PROCEDURE p1;
    (*VAR cid: INTEGER; tr: RuntimeErrors.Trace;*)
  BEGIN
    (*
    cid := MultiCore.CPUid();
    RuntimeErrors.Stacktrace(tr);
    RuntimeErrorsOut.PrintStacktrace(Out.W[cid], tr, cid);
    *)
    p2
  END p1;

  PROCEDURE p0;
    CONST R12 = 12;
    (* VAR x, y: INTEGER; *)
  BEGIN
    SYSTEM.LDREG(R12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
    VAR x: INTEGER;
  BEGIN
    x := Memory.DataMem[0].stackStart;
    Out.Hex(x, 12); Out.Ln;
    p
  END run;

BEGIN
  p := p0;
  MultiCore.StartCoreOne(run, InitCoreOne.Init);
  run
END Stacktr0.
