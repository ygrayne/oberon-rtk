MODULE StacktrK2C0;
(**
  Oberon RTK Framework v3.1
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: RP2350
  Board: Pico2
   --
  Kernel-v1
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, PPB, Main, Cores, Kernel, Errors, Out;


  CONST
    ThreadStackSize = 1024;
    MillisecsPerTick = 10;

  VAR
    p: PROCEDURE;

  PROCEDURE fault;
  (* trigger MCU fault *)
    VAR x: INTEGER;
  BEGIN
    x := PPB.NVIC_ISER0 + 1;
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
    Cores.GetCoreId(cid);
    IF cid = 0 THEN
      Out.String("error"); Out.Ln;
      error
    ELSE
      Out.String("fault"); Out.Ln;
      fault
    END
  END p2;

  PROCEDURE p1;
  BEGIN
    p2
  END p1;

  PROCEDURE p0;
    CONST R12 = 12;
  BEGIN
    SYSTEM.LDREG(R12, 0A0B0000H + SYSTEM.REG(R12)); (* marker *)
    p1
  END p0;

  PROCEDURE run;
  BEGIN
    p
  END run;

  PROCEDURE t0c;
  BEGIN
    Kernel.SetPeriod(1000, 1000);
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
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, x); ASSERT(x = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t0);
    (* threads will use in their stacks, exceptions will use main stack *)
    Kernel.Run (* resets MSP to top *)
    (* we'll not return here *)
  END run0;

BEGIN
  p := p0;
  Cores.StartCoreOne(run0, Main.ConfigC1);
  run0
END StacktrK2C0.
