MODULE AlarmEval;
(**
  Oberon RTK Framework
  Example program, single-threaded, one core
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Alarms, Out, Timers, MemoryExt;

  CONST
    RollOver = 0FFFFFFFFH;
    StartTime = RollOver - 100;

    FirstRunAfter = 50;
    TimeBetweenRuns = 25;

    Runs0 = 4;
    Runs1 = Runs0 + 4;
    NumRuns = Runs1 + 1;

    PreCacheProcs = FALSE;

    RecoveryNone = 0;
    RecoveryRetime = 1;
    RecoveryDirect = 2;
    Recovery = RecoveryRetime;

  TYPE
    Run = POINTER TO RunDesc;
    RunDesc = RECORD
      armTime, armedTime: INTEGER;
      alarmTime, alarmTimeRun: INTEGER;
      runBegin, runEnd: INTEGER;
    END;

  VAR
    dev: Alarms.Device;   (* for test handlers *)
    devR: Alarms.Device;  (* for results printing handler *)
    runNo: INTEGER;
    runs: ARRAY NumRuns OF Run;
    cachingBegin, cachingEnd: INTEGER;


  PROCEDURE p1[0];
  (* second handler, activated by 'p0' *)
    VAR now: INTEGER; r: Run;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, {Alarms.A0}); (* de-assert *)
    INC(runNo);
    r := runs[runNo];
    r.alarmTime := dev.time;
    r.alarmTimeRun := dev.timeRun;
    r.runBegin := now;
    IF runNo < Runs1 THEN
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armTime);
      Alarms.Rearm(dev, p1, TimeBetweenRuns);
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armedTime)
    END;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END p1;


  PROCEDURE p0[0];
  (* first handler, activated by 'start' *)
    VAR now: INTEGER; r: Run;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, {Alarms.A0}); (* de-assert *)
    INC(runNo);
    r := runs[runNo];
    r.alarmTime := dev.time;
    r.alarmTimeRun := dev.timeRun;
    r.runBegin := now;
    IF runNo < Runs0 THEN
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armTime);
      Alarms.Rearm(dev, p0, TimeBetweenRuns);
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armedTime)
    ELSE
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armTime);
      Alarms.Rearm(dev, p1, TimeBetweenRuns);
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armedTime)
    END;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END p0;


  PROCEDURE start;
    VAR now: INTEGER; r: Run;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    runNo := 0;
    r := runs[runNo];
    r.runBegin := now;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armTime);
    Alarms.Arm(dev, p0, now + FirstRunAfter);
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.armedTime);
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END start;


  PROCEDURE p3[0];
    VAR i, atm, rtm: INTEGER; r: Run;
  BEGIN
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, {Alarms.A3}); (* de-assert *)
    Out.String("StartTime:       "); Out.Hex(StartTime, 0); Out.String(" = ") ; Out.String("FFFFFFFFH - "); Out.Int(RollOver - StartTime, 0); Out.Ln;
    Out.String("FirstRunAfter:   "); Out.Int(FirstRunAfter, 0); Out.Ln;
    Out.String("TimeBetweenRuns: "); Out.Int(TimeBetweenRuns, 0); Out.Ln;
    Out.String("PreCachedProcs:  ");
    IF PreCacheProcs THEN
      Out.String("Yes"); Out.String("   ("); Out.Int(cachingEnd - cachingBegin, 0); Out.Char(")");
    ELSE
      Out.String("No")
    END;
    Out.Ln;
    Out.String("Recovery:        ");
    IF Recovery = RecoveryNone THEN
      Out.String("None")
    ELSIF Recovery = RecoveryRetime THEN
      Out.String("Retime")
    ELSIF Recovery = RecoveryDirect THEN
      Out.String("Direct")
    ELSE
      ASSERT(FALSE)
    END;
    Out.Ln;
    Out.String(" run");
    Out.String(" rm");
    Out.String("     al-arm");
    Out.String("     al-run");
    Out.String(" rdel");
    Out.String("    run-beg");
    Out.String("        arm");
    Out.String("      armed");
    Out.String("  atm");
    Out.String("    run-end");
    Out.String("  htm");
    Out.String("  rtm");
    Out.Ln;
    i := 0;
    WHILE i <= runNo DO
      r := runs[i];
      Out.Int(i, 4);
      IF i # 0 THEN
        IF r.alarmTime = r.alarmTimeRun THEN
          Out.String("  T")
        ELSE
          Out.String("  R")
        END;
        Out.Hex(r.alarmTime, 11);
        Out.Hex(r.alarmTimeRun, 11);
        Out.Int(r.runBegin - r.alarmTime, 5)
      ELSE
        Out.String("                              ")
      END;
      Out.Hex(r.runBegin, 11);
      IF (i = 0) OR (i # runNo) THEN
        Out.Hex(r.armTime, 11);
        Out.Hex(r.armedTime, 11);
        atm := r.armedTime - r.armTime;
        Out.Int(atm, 5)
      ELSE
        IF i = runNo THEN atm := 0 END;
        Out.String("                           ")
      END;
      Out.Hex(r.runEnd, 11);
      rtm := r.runEnd - r.runBegin;
      Out.Int(rtm - atm, 5);
      Out.Int(rtm, 5);
      Out.Ln;
      INC(i)
    END;
    Out.Ln
  END p3;


  PROCEDURE initRuns;
    VAR i: INTEGER; r: Run;
  BEGIN
    i := 0;
    WHILE i < NumRuns DO
      NEW(runs[i]);
      r := runs[i];
      CLEAR(r^);
      INC(i)
    END
  END initRuns;


  PROCEDURE preCache;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, cachingBegin);
    MemoryExt.CacheProc(SYSTEM.ADR(p0));
    MemoryExt.CacheProc(SYSTEM.ADR(p1));
    MemoryExt.CacheProc(SYSTEM.ADR(start));
    MemoryExt.CacheProc(SYSTEM.ADR(Alarms.Arm));
    MemoryExt.CacheProc(SYSTEM.ADR(Alarms.Rearm));
    MemoryExt.CacheProc(SYSTEM.ADR(Alarms.ArmRaw));
    MemoryExt.CacheProc(SYSTEM.ADR(Alarms.ArmRetime));
    MemoryExt.CacheProc(SYSTEM.ADR(Alarms.ArmDirect));
    SYSTEM.GET(MCU.TIMER_TIMERAWL, cachingEnd)
  END preCache;


  PROCEDURE run;
    CONST Prio = 1;
    VAR now, time: INTEGER;
  BEGIN
    initRuns;
    IF PreCacheProcs THEN
      preCache
    END;
    NEW(dev);
    IF Recovery = RecoveryNone THEN
      Alarms.Init(dev, Alarms.A0, Alarms.ArmRaw, PreCacheProcs)
    ELSIF Recovery = RecoveryRetime THEN
      Alarms.Init(dev, Alarms.A0, Alarms.ArmRetime, PreCacheProcs)
    ELSIF Recovery = RecoveryDirect THEN
      Alarms.Init(dev, Alarms.A0, Alarms.ArmDirect, PreCacheProcs)
    ELSE
      ASSERT(FALSE)
    END;
    Alarms.Enable(dev, Prio);
    NEW(devR);
    Alarms.Init(devR, Alarms.A3, Alarms.ArmRetime, FALSE);
    Alarms.Enable(devR, Prio);

    Timers.SetTime(0, StartTime);
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    time := now + FirstRunAfter;
    start;
    INC(time, NumRuns * TimeBetweenRuns + 1000000);

    Alarms.Arm(devR, p3, time)

  END run;

BEGIN
  run
END AlarmEval.
