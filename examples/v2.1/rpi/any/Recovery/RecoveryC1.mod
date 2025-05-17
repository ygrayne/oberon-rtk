MODULE RecoveryC1;
(**
  Oberon RTK Framework v2.1
  --
  Example program, multi-threaded, multi-core
  Evaluate different run-time error recovery options and conditions.
  Description: https://oberon-rtk.org/examples/v2/recovery/
  --
  Program for core 1
  Core 0 program: RecoveryC0
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico 2
  --
  Copyright (c) 2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Kernel, Recovery, MultiCore, Watchdog, Out, LEDext;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;
    TestCaseScratchReg = 1;
    Count = 3;


  VAR
    hb, t1, t2, t3, t4: Kernel.Thread;
    hbid, tid1, tid2, tid3, tid4: INTEGER;
    TestCnt*: INTEGER;


  PROCEDURE printThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0)
  END printThreadInfo;


  PROCEDURE hbc;
  BEGIN
    Kernel.SetPeriod(50, 0);
    REPEAT
      Kernel.Next;
      Recovery.WatchdogReload
    UNTIL FALSE
  END hbc;


  PROCEDURE t1c;
    VAR
      cid, tid: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    REPEAT
      Kernel.Next;
      printThreadInfo(tid, cid);
      INC(TestCnt);
      Out.Int(TestCnt, 10); Out.Ln
    UNTIL FALSE
  END t1c;


  PROCEDURE t2c;
    CONST TestCase = 3; NextTestCase = 4;
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
          Out.String(" => watchdog c1-t2"); Out.Ln;
          Watchdog.SetScratchReg(TestCaseScratchReg, NextTestCase);
          REPEAT UNTIL FALSE
        END
      END
    UNTIL FALSE
  END t2c;


  PROCEDURE t3c;
    CONST TestCase = 4; NextTestCase = 5;
    VAR
      cid, tid, testCase, cnt: INTEGER;
      a: ARRAY 2 OF INTEGER;
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
          Out.String(" => error c1-t3"); Out.Ln;
          Watchdog.SetScratchReg(TestCaseScratchReg, NextTestCase);
          a[cnt] := cnt
        END
      END
    UNTIL FALSE
  END t3c;


  PROCEDURE t4c;
    CONST TestCase = 7; (* same as on core 0 *)
    VAR cid, tid, testCase, cnt, x, i: INTEGER;
  BEGIN
    Kernel.SetPeriod(100, 0);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0; x := 0;
    REPEAT
      Kernel.Next;
      Watchdog.GetScratchReg(TestCaseScratchReg, testCase);
      IF testCase = TestCase THEN
        INC(cnt);
        IF cnt = Count THEN
          printThreadInfo(tid, cid);
          Out.String(" => error c1-t4"); Out.Ln;
          (* depending on the loop limit, core 0 or core 1 handler will "win" the restart *)
          i := 0; WHILE i < 100000 DO INC(i) END;
          x := x DIV x
        END
      END
    UNTIL FALSE
  END t4c;


  PROCEDURE Run*;
    VAR scratch, res: INTEGER;
  BEGIN
    Watchdog.GetScratchReg(TestCaseScratchReg, scratch);
    IF scratch = 0 THEN (* scratch regs are zeroed by chip reset, incl. flash programming *)
      Out.String("*** start-up reset ***");
      TestCnt := 0
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
    Kernel.Run
    (* we'll not return here *)
  END Run;

END RecoveryC1.
