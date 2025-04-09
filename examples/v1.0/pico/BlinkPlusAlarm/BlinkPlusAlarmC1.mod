MODULE BlinkPlusAlarmC1;
(**
  Oberon RTK Framework
  Example program, multi-threaded, multi-core
  --
  See module 'BlinkPlusAlarmC0'
  Uncomment 'Run' in the module init section to run this program alone on core 0.
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, MultiCore, Out, Timers, GPIO, LED, Alarms, Errors;

  CONST
    MillisecsPerTick  = 5;
    ThreadStackSize = 1024;
    AlarmNo = Alarms.A0;
    AlarmPrio = 3;
    BlinkerPeriod = 500000; (* microseconds *)

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;
    alarmDev: Alarms.Device;


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
    Kernel.ChangePeriod(1000, 0);
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
      (*
      Kernel.Next;
      *)
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


  PROCEDURE trigger[0];
  BEGIN
    Alarms.DeassertInt(alarmDev);
    Kernel.Enable(t0);
    Alarms.Rearm(alarmDev, trigger, BlinkerPeriod)
  END trigger;


  PROCEDURE t0c;
    VAR tid, cid, cnt, now, before: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    Kernel.ChangePrio(5);
    GPIO.Set({LED.Green});
    Timers.GetTimeL(before);
    Alarms.Arm(alarmDev, trigger, before + BlinkerPeriod);
    REPEAT
      Timers.GetTimeL(now);
      writeThreadInfo(tid, cid); Out.Int(cnt, 8); Out.Int(now - before, 12); Out.Ln;
      GPIO.Toggle({LED.Green});
      before := now;
      Kernel.SuspendMe;
      INC(cnt)
    UNTIL FALSE
  END t0c;


  PROCEDURE Run*;
    VAR res: INTEGER;
  BEGIN
    NEW(alarmDev); ASSERT(alarmDev # NIL, Errors.HeapOverflow);
    Alarms.Init(alarmDev, AlarmNo, FALSE);
    Alarms.Enable(alarmDev, AlarmPrio);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END Run;

BEGIN
  (*Run*)
END BlinkPlusAlarmC1.
