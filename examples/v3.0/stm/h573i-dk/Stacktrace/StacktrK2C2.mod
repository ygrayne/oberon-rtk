MODULE StacktrK2C2;
(**
  Oberon RTK Framework v3.0
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Kernel-v1
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Main, Kernel, Errors, Exceptions;

  CONST
    IntNo0 = MCU.IRQ_SPI5;
    IntNo1 = MCU.IRQ_SPI6;

    ThreadStackSize = 1024;
    MicrosecsPerTick = 10000;

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
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
    (*x := 17*)
  END h0;

  PROCEDURE* p1;
  BEGIN
    (* set int for h0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
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
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, MCU.ExcPrio80);
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, MCU.ExcPrio40);
    Exceptions.EnableInt(IntNo1);
    Kernel.Install(MicrosecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, x); ASSERT(x = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t0);
    (* threads will use their stacks, exceptions will use main stack *)
    Kernel.Run (* will reset MSP to top *)
    (* we'll not return here *)
  END run0;

BEGIN
  p := p0;
  run0
END StacktrK2C2.
