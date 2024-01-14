MODULE BlinkPlusRtkC1;
(**
  Oberon RTK Framework
  Example program, multi-threaded, multi-core
  See module 'BlinkPlusRtkC0'
  Uncomment 'Run' in the module init section to run this program alone on core 0.
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2023, Gray gray@grayraven.org
**)

  IMPORT Main, Kernel, MultiCore, Out, Timers, GPIO, LED;

  CONST
    MillisecsPerTick  = 5;
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


  PROCEDURE t1c;
    CONST Limit0 = 20000; Limit1 = 22000;
    VAR i, tid, cid, cnt, startTime, endTime, runTime0, runTime1: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    REPEAT
      runTime0 := 0; runTime1 := 0;
      Timers.GetTimeL(startTime);
      i := 0;
      WHILE i < Limit0 DO
        INC(i)
      END;
      Timers.GetTimeL(endTime);
      runTime0 := endTime - startTime;
      (* uncomment me *)
      Kernel.Next;

      Timers.GetTimeL(startTime);
      i := 0;
      WHILE i < Limit1 DO
        INC(i)
      END;
      Timers.GetTimeL(endTime);
      runTime1 := endTime - startTime;
      writeThreadInfo(tid, cid);
      Out.Int(runTime0, 8); Out.Int(runTime1, 8); Out.Int(runTime0 + runTime1, 8); Out.Ln;
      Kernel.Next;
      INC(cnt)
    UNTIL FALSE
  END t1c;


  PROCEDURE t0c;
    VAR tid, cid, cnt: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    GPIO.Set({LED.Green});
    REPEAT
      writeThreadInfo(tid, cid); Out.Int(cnt, 8); Out.Ln;
      GPIO.Toggle({LED.Green});
      Kernel.DelayMe(500);
      INC(cnt)
    UNTIL FALSE
  END t0c;


  PROCEDURE Run*;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t0); (* uses a delay, not period *)
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END Run;

BEGIN
  (*Run*)
END BlinkPlusRtkC1.
