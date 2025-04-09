MODULE BlinkPlusAlarmC0;
(**
  Oberon RTK Framework
  Example program, multi-threaded, multi-core
  --
  Program for core 1: 'BlinkPlusAlarmC1'
  Requires kernel v2.
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, Out, MultiCore, Memory, Timers, CoreOne := BlinkPlusAlarmC1;

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
    IF tid = tid0 THEN
      Kernel.ChangePeriod(980, 0);
    ELSE
      Kernel.ChangePeriod(740, 0);
    END;
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
    Kernel.Enable(t0);
    Kernel.Allocate(t0c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END BlinkPlusAlarmC0.
