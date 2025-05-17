MODULE RecoveryC0;
(**
  Oberon RTK Framework v2.1
  --
  Example program, multi-threaded, multi-core
  Evaluate different run-time error recovery options and conditions.
  Description: https://oberon-rtk.org/examples/v2/recovery/
  --
  Core 1 program: RecoveryC1
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Copyright (c) 2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Main, Kernel, Recovery, Watchdog, StartUp, MultiCore,
    GPIO, Out, LEDext, InitCoreOne, Core1 := RecoveryC1;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;
    TestCaseScratchReg = 1;
    Count = 3;

  VAR
    hb, t1, t2, t3, t4, t5, t6: Kernel.Thread;
    hbid, tid1, tid2, tid3, tid4, tid5, tid6: INTEGER;
    cnt5: INTEGER;
    p: PROCEDURE;


  PROCEDURE printThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END printThreadInfo;


  PROCEDURE printRestartMode(rstRec: Recovery.RestartDesc);
  BEGIN
    Out.String("rstCnt  "); Out.Int(rstRec.rstCnt, 0); Out.Ln;
    Out.String("rstCode "); Out.Int(rstRec.rstCode, 0);
    IF rstRec.rstCode = Recovery.RstCold THEN
      Out.String(" cold")
    ELSIF rstRec.rstCode = Recovery.RstWatchdogTimer THEN
      Out.String(" watchdog")
    ELSIF rstRec.rstCode = Recovery.RstRuntimeError THEN
      Out.String(" run-time error")
    ELSE
      Out.String(" unknown restart mode")
    END;
    Out.Ln;
    Out.String("rstCid  "); Out.Int(rstRec.rstCid, 0); Out.Ln;
    Out.Ln;
    IF rstRec.rstCode = Recovery.RstRuntimeError THEN
      Out.String("errCode "); Out.Int(rstRec.errCode, 0); Out.Ln;
      Out.String("errType "); Out.Int(rstRec.errType, 0); Out.Ln;
      Out.String("errTid  "); Out.Int(rstRec.errTid, 0); Out.Ln;
      Out.Ln
    END
  END printRestartMode;


  PROCEDURE printTestCase(testCase: INTEGER);
  BEGIN
    Out.String("test case: "); Out.Int(testCase, 0); Out.Ln
  END printTestCase;


  PROCEDURE hbc;
    VAR wdFail: BOOLEAN;
  BEGIN
    Kernel.SetPeriod(50, 0);
    GPIO.Set({LEDext.LEDpico});
    REPEAT
      Kernel.Next;
      GPIO.Toggle({LEDext.LEDpico});
      Recovery.CheckWatchdogReload(wdFail);
      IF wdFail THEN
        Recovery.WatchdogFail
      ELSE
        Watchdog.Reload
      END
    UNTIL FALSE
  END hbc;


  PROCEDURE t1c;
    VAR cid, tid, testCase: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    printRestartMode(Recovery.RestartRec);
    Watchdog.GetScratchReg(TestCaseScratchReg, testCase);
    printTestCase(testCase);
    REPEAT
      Kernel.Next;
      printThreadInfo(tid, cid);
      Out.Int(Core1.TestCnt, 10);
      Out.Ln
    UNTIL FALSE
  END t1c;


  PROCEDURE t2c;
    CONST TestCase = 1; NextTestCase = 2;
    VAR cid, tid, testCase, cnt: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    REPEAT
      Kernel.Next;
      Watchdog.GetScratchReg(TestCaseScratchReg, testCase);
      IF testCase = TestCase THEN
        LEDext.SetLedBits(TestCase, 5, 0);
        INC(cnt);
        IF cnt = Count THEN
          printThreadInfo(tid, cid);
          Out.String(" => watchdog c0-t2"); Out.Ln;
          Watchdog.SetScratchReg(TestCaseScratchReg, NextTestCase);
          REPEAT UNTIL FALSE
        END
      END
    UNTIL FALSE
  END t2c;


  PROCEDURE t3c;
    CONST TestCase = 2; NextTestCase = 3;
    VAR cid, tid, testCase, cnt, x: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0; x := 0;
    REPEAT
      Kernel.Next;
      Watchdog.GetScratchReg(TestCaseScratchReg, testCase);
      IF testCase = TestCase THEN
        LEDext.SetLedBits(TestCase, 5, 0);
        INC(cnt);
        IF cnt = Count THEN
          printThreadInfo(tid, cid);
          Out.String(" => error c0-t3"); Out.Ln;
          Watchdog.SetScratchReg(TestCaseScratchReg, NextTestCase);
          x := x DIV x
        END
      END
    UNTIL FALSE
  END t3c;


  PROCEDURE t4c;
    CONST TestCase = 5; NextTestCase = 6;
    VAR cid, tid, testCase, cnt, x: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0; x := MCU.PPB_NVIC_ISER0 + 1;
    REPEAT
      Kernel.Next;
      Watchdog.GetScratchReg(TestCaseScratchReg, testCase);
      IF testCase = TestCase THEN
        LEDext.SetLedBits(TestCase, 5, 0);
        INC(cnt);
        IF cnt = Count THEN
          printThreadInfo(tid, cid);
          Out.String(" => fault c0-t4"); Out.Ln;
          Watchdog.SetScratchReg(TestCaseScratchReg, NextTestCase);
          SYSTEM.PUT(x, x)
        END
      END
    UNTIL FALSE
  END t4c;


  PROCEDURE storeState(val: INTEGER);
  BEGIN
    cnt5 := val
  END storeState;


  PROCEDURE loadState(VAR val: INTEGER);
  BEGIN
    val := cnt5
  END loadState;


  PROCEDURE t5c;
    CONST TestCase = 6; NextTestCase = 7;
    VAR cid, tid, testCase, cnt, x: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    IF Recovery.RestartRec.rstCode = Recovery.RstCold THEN
      storeState(0); loadState(cnt)
    ELSIF Recovery.RestartRec.rstCode = Recovery.RstRuntimeError THEN
      IF (Recovery.RestartRec.rstCid = cid) & (Recovery.RestartRec.errTid = tid) THEN (* if this thread caused the error *)
        storeState(0)
      END;
      loadState(cnt)
    ELSE
      loadState(cnt)
    END;
    x := 0;
    REPEAT
      Kernel.Next;
      printThreadInfo(tid, cid); Out.Int(cnt, 6);
      INC(cnt);
      storeState(cnt);
      Watchdog.GetScratchReg(TestCaseScratchReg, testCase);
      IF testCase = TestCase THEN
        LEDext.SetLedBits(TestCase, 5, 0);
        IF cnt > 15 THEN
          Out.String(" => error c0-t5"); Out.Ln;
          Watchdog.SetScratchReg(TestCaseScratchReg, NextTestCase);
          x := x DIV x
        END
      END;
      Out.Ln
    UNTIL FALSE
  END t5c;


  PROCEDURE t6c;
    CONST TestCase = 7; NextTestCase = 1;
    VAR cid, tid, testCase, cnt: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    REPEAT
      Kernel.Next;
      Watchdog.GetScratchReg(TestCaseScratchReg, testCase);
      INC(cnt);
      IF testCase = TestCase THEN
        LEDext.SetLedBits(TestCase, 5, 0);
        IF cnt = Count THEN
          printThreadInfo(tid, cid); Out.Int(cnt, 6);
          Out.String(" => error c0-t6"); Out.Ln;
          Watchdog.SetScratchReg(TestCaseScratchReg, NextTestCase);
          p
        END
      END;
      Out.Ln
    UNTIL FALSE
  END t6c;


  PROCEDURE run;
    VAR scratch, res: INTEGER;
  BEGIN
    MultiCore.StartCoreOne(Core1.Run, InitCoreOne.Init);
    Watchdog.GetScratchReg(TestCaseScratchReg, scratch);
    Out.Ln;
    IF scratch = 0 THEN (* scratch regs are zeroed by chip reset, incl. flash programming *)
      Out.String("*** start-up reset ***");
      Watchdog.SetScratchReg(TestCaseScratchReg, 1)
    ELSE
       Out.String("*** reset ***")
    END;
    Out.Ln;
    Recovery.Install;
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(hbc, ThreadStackSize, hb, hbid, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(hb);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t1);
    Kernel.Allocate(t2c, ThreadStackSize, t2, tid2, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t2);
    Kernel.Allocate(t3c, ThreadStackSize, t3, tid3, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t3);
    Kernel.Allocate(t4c, ThreadStackSize, t4, tid4, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t4);
    Kernel.Allocate(t5c, ThreadStackSize, t5, tid5, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t5);
    Kernel.Allocate(t6c, ThreadStackSize, t6, tid6, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t6);

    StartUp.SetResetWatchdogResets(MCU.RESETS_ALL);
    StartUp.SetPowerOnWatchdogResets(MCU.PSM_ALL);
    Watchdog.SetLoadTime(2000); (* heartbeat does reload *)
    Watchdog.Enable;

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  p := NIL;
  run
END RecoveryC0.
