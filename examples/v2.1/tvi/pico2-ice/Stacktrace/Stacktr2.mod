MODULE Stacktr2;
(**
  Oberon RTK Framework v2
  --
  Example/test program
  https://oberon-rtk.org/docs/examples/v2/stacktrace
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Exceptions, Memory, MultiCore, InitCoreOne, Out, Main;

  CONST
    IntNo0 = MCU.PPB_SPAREIRQ_IRQ0;
    IntNo1 = MCU.PPB_SPAREIRQ_IRQ1;
    (* debug/test
    Pin0 = 16;
    Pin1 = 17;
    Pin2 = 18;
    *)

  VAR
    p: PROCEDURE;

  PROCEDURE* i0[0];
    VAR x: INTEGER;
  BEGIN
    (* debug/test
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin2}); (* debug *)
    *)
    x := 0; x := x DIV x
  END i0;

  PROCEDURE* h0[0];
    VAR x: INTEGER;
  BEGIN
    (* debug/test
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin1}); (* debug *)
    *)
    x := 13;
    (* set int for i0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
    (*SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)*)
  END h0;

  PROCEDURE* p1;
  BEGIN
    (* debug/test
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin0}); (* debug *)
    *)
    (* set int for h0 pending *)
    SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
    (*SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)*)
  END p1;

  PROCEDURE p0;
  BEGIN
    SYSTEM.LDREG(12, 0A0B0C0DH); (* marker *)
    p1
  END p0;

  PROCEDURE run;
    VAR x: INTEGER;
  BEGIN
    x := Memory.DataMem[0].stackStart;
    Out.Hex(x, 12); Out.Ln;
    Exceptions.InstallIntHandler(IntNo0, h0);
    Exceptions.SetIntPrio(IntNo0, MCU.PPB_ExcPrio4);
    (*Exceptions.SetIntPrio(IntNo0, MCU.PPB_ExcPrio2) *) (* for tail-chaining *)
    Exceptions.EnableInt(IntNo0);
    Exceptions.InstallIntHandler(IntNo1, i0);
    Exceptions.SetIntPrio(IntNo1, MCU.PPB_ExcPrio2);
    Exceptions.EnableInt(IntNo1);
    p
  END run;

BEGIN
  p := p0;
  (* debug/test
  GPIO.SetFunction(Pin0, MCU.IO_BANK0_Fsio);
  GPIO.SetFunction(Pin1, MCU.IO_BANK0_Fsio);
  GPIO.SetFunction(Pin2, MCU.IO_BANK0_Fsio);
  GPIO.OutputEnable({Pin0, Pin1, Pin2});
  GPIO.Clear({Pin0, Pin1, Pin2});
  *)
  (* test
  MemoryExt.CacheProc(SYSTEM.ADR(i0));
  MemoryExt.CacheProc(SYSTEM.ADR(h0));
  *)
  MultiCore.StartCoreOne(run, InitCoreOne.Init);
  run
END Stacktr2.
