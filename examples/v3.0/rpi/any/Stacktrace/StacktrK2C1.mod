MODULE StacktrK2C1;
(**
  Oberon RTK Framework v3.0
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Kernel-v1
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Main, Kernel, Cores, InitCoreOne, Errors, Exceptions;

  CONST
    IntNo0 = MCU.IRQ_SW_0;
    IntNo1 = MCU.IRQ_SW_1;

    ThreadStackSize = 1024;
    MillisecsPerTick = 10;

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
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
    (*SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)*)
  END h2;

  PROCEDURE h1;
  (* FPU operation to test correct stack trace on RP2350 *)
  (* on core 0 only: FPU on core 1 not enabled *)
    VAR r: REAL; cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    r := 1.0; (* avoid false positives on core 1 *)
    IF cid = 0 THEN
      r := r / r
    END;
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
  BEGIN
    (* set int for h0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
    (*SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);*)
    p1a
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
      res, tid0: INTEGER;
  BEGIN
    (* in main stack *)
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, MCU.ExcPrio80);
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, MCU.ExcPrio40);
    Exceptions.EnableInt(IntNo1);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t0);
    (* threads will use in their stacks, exceptions will use main stack *)
    Kernel.Run (* resets MSP to top *)
    (* we'll not return here *)
  END run0;

BEGIN
  p := p0;
  Cores.StartCoreOne(run0, InitCoreOne.Init);
  run0
END StacktrK2C1.
