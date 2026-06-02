MODULE StacktrK2;
(**
  Oberon RTK Framework v3.1
  --
  Example/test program, dual-core, kernel v1
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, PPB, EXC, ASM, Main, Cores, Kernel, Errors, Exceptions;

  CONST
    (* unwired interrupts *)
    IntNo0 = EXC.IRQ_SW_0;
    IntNo1 = EXC.IRQ_SW_1;

    ThreadStackSize = 1024;
    MillisecsPerTick = 10;

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
    SYSTEM.PUT(PPB.NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
  END h0;

  PROCEDURE* p1;
  BEGIN
    (* set int for h0 pending *)
    SYSTEM.PUT(PPB.NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
    SYSTEM.EMIT(ASM.DSB); SYSTEM.EMIT(ASM.ISB)
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

  PROCEDURE t0c;
  BEGIN
    Kernel.SetPeriod(100, 0);
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
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, EXC.ExcPrio80);
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, EXC.ExcPrio40);
    Exceptions.EnableInt(IntNo1);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, x); ASSERT(x = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t0);
    (* threads use their stacks, exceptions use main stack *)
    Kernel.Run (* will reset MSP to top *)
    (* we'll not return here *)
  END run0;

BEGIN
  p := p0;
  Cores.StartCoreOne(run0, Main.ConfigC1);
  run0
END StacktrK2.
