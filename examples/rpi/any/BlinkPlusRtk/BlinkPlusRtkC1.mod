MODULE BlinkPlusRtkC1;
(**
  Oberon RTK Framework v2
  --
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/v2/blinkplusrtk/
  --
  See module 'BlinkPlusRtkC0'
  Uncomment 'Run' in the module init section to run this program alone on core 0.
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, MultiCore, Out, Timers, GPIO, LED, LEDext, Errors;

  CONST
    MillisecsPerTick  = 4;
    ThreadStackSize = 1024;
    ThreadOnePeriod = 250 * MillisecsPerTick;
    ThreadZeroDelay = 125 * MillisecsPerTick;

  VAR
    Timer*: Timers.Device;
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
    VAR i: INTEGER;
  BEGIN
    i := -2 * tid; WHILE i < tid DO Out.Char(" "); INC(i) END;
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE t1c;
    CONST Limit0 = 23000; Limit1 = 23000;
    VAR i, tid, cid, cnt, startTime, endTime, runTime0, runTime1: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    REPEAT
      runTime0 := 0; runTime1 := 0;
      Timers.GetTimeL(Timer, startTime);
      i := 0;
      WHILE i < Limit0 DO
        INC(i)
      END;
      Timers.GetTimeL(Timer, endTime);
      runTime0 := endTime - startTime;
      Kernel.Next;
      Timers.GetTimeL(Timer, startTime);
      i := 0;
      WHILE i < Limit1 DO
        INC(i)
      END;
      Timers.GetTimeL(Timer, endTime);
      runTime1 := endTime - startTime;
      writeThreadInfo(tid, cid);
      Out.Int(runTime0, 8); Out.Int(runTime1, 8); Out.Int(runTime0 + runTime1, 8); Out.Ln;
      Kernel.Next;
      INC(cnt)
    UNTIL FALSE
  END t1c;


  PROCEDURE t0c;
    VAR tid, cid, cnt, before, timeL: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    GPIO.Set({LED.Pico});
    Timers.GetTimeL(Timer, before);
    REPEAT
      Timers.GetTimeL(Timer, timeL);
      LEDext.SetValue(cnt);
      writeThreadInfo(tid, cid);
      Out.Int(cnt, 8); Out.Int(timeL - before, 8); Out.Ln;
      before := timeL;
      GPIO.Toggle({LED.Pico});
      Kernel.DelayMe(ThreadZeroDelay);
      INC(cnt)
    UNTIL FALSE
  END t0c;


  PROCEDURE Run*;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t1, ThreadOnePeriod, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END Run;


  PROCEDURE init;
  BEGIN
    NEW(Timer); ASSERT(Timer # NIL, Errors.HeapOverflow);
    Timers.Init(Timer, Timers.TIMER0)
  END init;

BEGIN
  init (* runs on core 0 *)
  (*Run*)
END BlinkPlusRtkC1.
