MODULE BlinkPlusRtkC0;
(**
  Oberon RTK Framework
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/blinkplusrtk/
  --
  Program for core 1: 'BlinkPlusRtkC1'
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, Out, MultiCore, Memory, Timers, CoreOne := BlinkPlusRtkC1;

  CONST
    Core1 = 1;
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;


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
    Timers.GetTimeL(before);
    REPEAT
      Kernel.Next;
      Timers.GetTimeL(timeL);
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
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t0, 980, 0); Kernel.Enable(t0);
    Kernel.Allocate(t0c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t1, 740, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END BlinkPlusRtkC0.
