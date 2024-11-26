MODULE WatchdogC0;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, dual-core
  Simple dual-core watchdog
  See https://oberon-rtk.org/examples/v2/watchdog
  --
  Core 1 program: WatchdogC1
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, Kernel, Out, MultiCore, StartUp, Memory, Errors, GPIO, LED, Watchdog, MCU := MCU2, CoreOne := WatchdogC1;

  CONST
    Core1 = 1;
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    Core0FailCnt = 3;
    Core1FailCnt = 7;
    Core1OkFlag = 0;
    Core1FailFlag = 1;

    REASON = MCU.WATCHDOG_REASON;
    PSM_WDSEL = MCU.PSM_WDSEL;
    RESETS_WDSEL = MCU.RESETS_WDSEL;
    SCRATCH0 = MCU.WATCHDOG_SCRATCH0;


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


  PROCEDURE writeWatchdogStatus;
    VAR psmSel, resetsSel, reason, scratch: INTEGER;
  BEGIN
    SYSTEM.GET(REASON, reason);
    IF Watchdog.REASON_FORCE IN BITS(reason) THEN
      Out.String("reason:         FORCE (core 1, via core 0)")
    ELSIF Watchdog.REASON_TIMER IN BITS(reason) THEN
      Out.String("reason:         TIMER (core 0)")
    ELSE
      Out.String("reason:         HW reset")
    END;
    Out.Ln;
    SYSTEM.GET(PSM_WDSEL, psmSel);
    SYSTEM.GET(RESETS_WDSEL, resetsSel);
    Out.String("PSM_WDSEL:     "); Out.Hex(psmSel, 10); Out.Bin(psmSel, 40); Out.Ln;
    Out.String("RELEASE_WDSEL: "); Out.Hex(resetsSel, 10); Out.Bin(resetsSel, 40); Out.Ln;
    SYSTEM.GET(SCRATCH0, scratch);
    Out.String("SCRATCH0:      "); Out.Hex(scratch, 10); Out.Ln
  END writeWatchdogStatus;


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
    GPIO.Set({LED.Pico});
    REPEAT
      GPIO.Toggle({LED.Pico});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR tid, cid: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    configTestCase;
    Out.Ln; Out.String("*** reset ***"); Out.Ln;
    writeWatchdogStatus;
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
    MultiCore.InitCoreOne(CoreOne.Run, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.SetPeriod(t0, 500, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Allocate(t2c, ThreadStackSize, t2, tid2, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.SetPeriod(t2, 20, 0); Kernel.Enable(t2);

    Watchdog.SetLoadTime(100);
    StartUp.SetWatchdogPowerOnResets(MCU.PSM_RESET);
    Watchdog.Enable;

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END WatchdogC0.
