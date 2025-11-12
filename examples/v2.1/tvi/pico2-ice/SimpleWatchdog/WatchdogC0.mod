MODULE WatchdogC0;
(**
  Oberon RTK Framework v2.1
  --
  Example program, multi-threaded, dual-core
  Simple dual-core watchdog
  See https://oberon-rtk.org/docs/examples/v2/watchdog
  --
  Core 1 program: WatchdogC1
  --
  Note: does not (yet) use watchdog functionality provided by module Recovery.
  --
  MCU: RP2350B
  Board: Pico2-ICE
  --
  Copyright (c) 2024-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, Main, Kernel, Out, MultiCore, InitCoreOne, StartUp, Memory, Errors,
    GPIO, LED, Watchdog, MCU := MCU2, CoreOne := WatchdogC1;

  CONST
    Core1 = 1;
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    T0period = 50;
    T2period = 2;
    T1period = 100;

    Core0FailCnt = 3;
    Core1FailCnt = 7;
    Core1OkFlag = 0;
    Core1FailFlag = 1;

    HbLed = LED.Green;


  VAR
    t0, t1, t2: Kernel.Thread;
    tid0, tid1, tid2: INTEGER;
    cnt: INTEGER;
    core1Fail: BOOLEAN;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE configTestCase;
  BEGIN
    IF SYSTEM.BIT(MCU.WATCHDOG_SCRATCH0, Core1FailFlag) THEN
      cnt := Core1FailCnt; core1Fail := TRUE;
    ELSE
      cnt := Core0FailCnt; core1Fail := FALSE;
    END
  END configTestCase;


  PROCEDURE switchTestCase;
  BEGIN
    IF core1Fail THEN
      SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0 + MCU.ACLR, {Core1FailFlag})
    ELSE
      SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0 + MCU.ASET, {Core1FailFlag})
    END
  END switchTestCase;


  PROCEDURE t0c;
  BEGIN
    Kernel.SetPeriod(T0period, T0period);
    GPIO.Set({HbLed});
    REPEAT
      GPIO.Toggle({HbLed});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR tid, cid: INTEGER;
  BEGIN
    Kernel.SetPeriod(T1period, T1period);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    configTestCase;
    Out.Ln; Out.String("*** reset ***"); Out.Ln;
    REPEAT
      writeThreadInfo(tid, cid);
      IF core1Fail THEN
        Out.String(" awaiting core 1 watchdog"); Out.Ln
      ELSE
        Out.String(" core 0 watchdog in "); Out.Int(cnt, 0); Out.Ln;
        IF cnt = 0 THEN
          switchTestCase;
          REPEAT UNTIL FALSE
        END
      END;
      DEC(cnt);
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE t2c;
    CONST Core1Failed = 3;
    VAR core1missing: INTEGER;
  BEGIN
    Kernel.SetPeriod(T2period, 0);
    core1missing := 0;
    REPEAT
      IF SYSTEM.BIT(MCU.WATCHDOG_SCRATCH0, Core1OkFlag) THEN
        core1missing := 0;
        SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0 + MCU.ACLR, {Core1OkFlag})
      ELSE
        INC(core1missing)
      END;
      IF core1missing = Core1Failed THEN
        switchTestCase;
        Watchdog.Trigger
      END;
      Watchdog.Reload;
      Kernel.Next
    UNTIL FALSE
  END t2c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    MultiCore.StartCoreOne(CoreOne.Run, InitCoreOne.Init);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t1);
    Kernel.Allocate(t2c, ThreadStackSize, t2, tid2, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t2);

    Watchdog.SetLoadTime(100);
    StartUp.SetPowerOnWatchdogResets(MCU.PSM_RESET);
    Watchdog.Enable;

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END WatchdogC0.
