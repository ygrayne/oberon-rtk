MODULE StacktrK2C0;
(**
  Oberon RTK Framework v2
  --
  Example/test program
  https://oberon-rtk.org/examples/v2/stacktrace
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Kernel, MultiCore, Errors, Memory, Out;


  CONST
    ThreadStackSize = 1024;
    MillisecsPerTick = 10;
    Core1 = 1;

  VAR
    p: PROCEDURE;

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

  PROCEDURE p2;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    IF cid = 0 THEN
      fault
    ELSE
      error
    END
  END p2;

  PROCEDURE p1;
  BEGIN
    p2
  END p1;

  PROCEDURE p0;
    CONST R12 = 12;
  BEGIN
    SYSTEM.LDREG(R12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    p
  END run;

  PROCEDURE t0c;
  BEGIN
    REPEAT
      run;
      Kernel.Next
    UNTIL FALSE
  END t0c;

  PROCEDURE run0;
    VAR
      t0: Kernel.Thread;
      x, tid0: INTEGER;
  BEGIN
    (* in main stack *)
    x := MultiCore.CPUid();
    x := Memory.DataMem[x].stackStart;
    Out.Hex(x, 12); Out.Ln;
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, x); ASSERT(x = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t0, 1000, 0); Kernel.Enable(t0);
    (* threads will use in their stacks, exceptions will use main stack *)
    Kernel.Run (* resets MSP to top *)
    (* we'll not return here *)
  END run0;

BEGIN
  p := p0;
  MultiCore.InitCoreOne(run0, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);
  run0
END StacktrK2C0.
