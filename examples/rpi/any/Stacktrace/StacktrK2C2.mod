MODULE StacktrK2C2;
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

  IMPORT SYSTEM, MCU := MCU2, Main, Kernel, MultiCore, Errors, Exceptions, Memory, Out;

  CONST
    IntNo0 = MCU.PPB_SPAREIRQ_IRQ0;
    IntNo1 = MCU.PPB_SPAREIRQ_IRQ1;

    ThreadStackSize = 1024;
    MillisecsPerTick = 10;
    Core1 = 1;

  VAR
    p: PROCEDURE;


  PROCEDURE* i0[0];
    VAR x: INTEGER;
  BEGIN
    x := 0; x := x DIV x
  END i0;

  PROCEDURE* h0[0];
    VAR x: INTEGER;
  BEGIN
    x := 13;
    (* set int for i0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
    (*x := 17*)
  END h0;

  PROCEDURE p1;
  BEGIN
    (* set int for h0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
  END p1;

  PROCEDURE p0;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH); (* marker *)
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
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, MCU.PPB_ExcPrio4);
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, MCU.PPB_ExcPrio2);
    Exceptions.EnableInt(IntNo1);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, x); ASSERT(x = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t0, 1000, 0); Kernel.Enable(t0);
    (* threads will use their stacks, exceptions will use main stack *)
    Kernel.Run (* will reset MSP to top *)
    (* we'll not return here *)
  END run0;

BEGIN
  p := p0;
  MultiCore.InitCoreOne(run0, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);
  run0
END StacktrK2C2.
