MODULE BlinkPlusRtkC0;
(**
  Oberon RTK Framework v2
  --
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/v2/blinkplusrtk/
  --
  Program for core 1: 'BlinkPlusRtkC1'
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, Out, MultiCore, Memory, Timers, CoreOne := BlinkPlusRtkC1;

  CONST
    Core1 = 1;
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;
    ThreadZeroPeriod = 98 * MillisecsPerTick;
    ThreadOnePeriod = 74 * MillisecsPerTick;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;
    timer: Timers.Device;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
    VAR i: INTEGER;
  BEGIN
    i := -2 * tid; WHILE i < tid DO Out.Char(" "); INC(i) END;
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE t0c;
    VAR tid, cid, cnt, before, timeL: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    Timers.GetTimeL(timer, before);
    REPEAT
      Kernel.Next;
      Timers.GetTimeL(timer, timeL);
      writeThreadInfo(tid, cid);
      Out.Int(cnt, 8); Out.Int(timeL - before, 8); Out.Ln;
      before := timeL;
      INC(cnt)
    UNTIL FALSE
  END t0c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    MultiCore.InitCoreOne(CoreOne.Run, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);
    timer := CoreOne.Timer;
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t0, ThreadZeroPeriod, 0); Kernel.Enable(t0);
    Kernel.Allocate(t0c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t1, ThreadOnePeriod, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END BlinkPlusRtkC0.
