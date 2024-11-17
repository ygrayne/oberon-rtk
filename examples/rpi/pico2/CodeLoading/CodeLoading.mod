MODULE CodeLoading;
(**
  Oberon RTK Framework
  --
  Example program, single-threaded, one core
  Description & instructions: https://oberon-rtk.org/examples/codeloading/
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, SYSTEM, MCU := MCU2, MemoryExt, Errors, Out, StartUp;

  CONST
    RunFromFlashCached = 0;
    RunFromFlashDirect = 1;
    RunFromRam = 2;
    RunPreCached = 3;

    TestCase = RunFromFlashCached;

    (* timer 0 register for direct access *)
    TIMER_TIMERAWL = MCU.TIMER0_BASE + MCU.TIMER_TIMERAWL_Offset;

    (* BUSCTRL PERFSEL counters *)
    PERFSEL0 = MCU.PERFSEL_XIP_MAIN0_ACC;
    PERFSEL1 = MCU.PERFSEL_XIP_MAIN1_ACC;
    PERFSEL2 = MCU.PERFSEL_SRAM8_ACC;

  TYPE
    Iterator = PROCEDURE(iterations: INTEGER; VAR cntXip0, cntXip1, cntRam, time: INTEGER);
    Incrementor = PROCEDURE(VAR i: INTEGER);

  VAR
    loopRam: Iterator;
    incrRam: Incrementor;


  PROCEDURE incr(VAR i: INTEGER);
  BEGIN
    INC(i)
  END incr;


  PROCEDURE loop(iterations: INTEGER; VAR cntXip0, cntXip1, cntRam, time: INTEGER);
    VAR i, it, go, done: INTEGER;
  BEGIN
    it := iterations DIV 8;
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR0, 0); (* reset counters *)
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR1, 0);
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR2, 0);
    SYSTEM.GET(TIMER_TIMERAWL, go);
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR_EN + MCU.ASET, {0}); (* enable counting *)
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    i := 0;
    WHILE i < it DO
      incr(i)
    END;
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR_EN + MCU.ACLR, {0}); (* disable counting *)
    SYSTEM.GET(TIMER_TIMERAWL, done);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR0, cntXip0); (* read counters *)
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR1, cntXip1);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR2, cntRam);
    time := done - go
  END loop;


  PROCEDURE loopForRam(iterations: INTEGER; VAR cntXip0, cntXip1, cntRam, time: INTEGER);
    VAR i, it, go, done: INTEGER;
  BEGIN
    it := iterations DIV 8;
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR0, 0); (* reset counters *)
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR1, 0);
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR2, 0);
    SYSTEM.GET(TIMER_TIMERAWL, go);
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR_EN + MCU.ASET, {0}); (* enable counting *)
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    i := 0;
    WHILE i < it DO
      incrRam(i)
    END;
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR_EN + MCU.ACLR, {0}); (* disable counting *)
    SYSTEM.GET(TIMER_TIMERAWL, done);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR0, cntXip0); (* read counters *)
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR1, cntXip1);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR2, cntRam);
    time := done - go
  END loopForRam;


  PROCEDURE test(runNo, iterations: INTEGER);
    CONST EN_SECURE = 0; EN_NONSECURE = 1;
    VAR cntXip, cntXip0, cntXip1, cntRam, time: INTEGER;
  BEGIN
    Out.Int(runNo, 4); Out.Int(iterations, 6);
    IF TestCase IN {RunFromFlashCached, RunPreCached} THEN
      loop(iterations, cntXip0, cntXip1, cntRam, time)
    ELSIF TestCase IN {RunFromFlashDirect} THEN
      SYSTEM.PUT(MCU.XIP_CTRL + MCU.ACLR, {EN_SECURE, EN_NONSECURE});
      loop(iterations, cntXip0, cntXip1, cntRam, time)
    ELSIF TestCase IN {RunFromRam} THEN
      loopRam(iterations, cntXip0, cntXip1, cntRam, time)
    ELSE
      ASSERT(FALSE)
    END;
    cntXip := cntXip0 + cntXip1;
    Out.Int(cntXip, 10); Out.Int(cntRam, 10); Out.Int(time, 8);
    IF cntXip > 0 THEN
      Out.Int((time * 1000) DIV cntXip, 12)
    ELSE
      Out.String("         n/a")
    END;
    IF cntRam > 0 THEN
      Out.Int((time * 1000) DIV cntRam, 16)
    ELSE
      Out.String("             n/a")
    END;
    Out.Ln
  END test;


  PROCEDURE run;
    CONST Runs = 4; Iterations = 16;
    VAR i, loopAddr, incrAddr: INTEGER;
  BEGIN
    StartUp.ReleaseReset(MCU.RESETS_BUSCTRL);
    SYSTEM.PUT(MCU.BUSCTRL_PERFSEL0, PERFSEL0);  (* XIP0 measurements *)
    SYSTEM.PUT(MCU.BUSCTRL_PERFSEL1, PERFSEL1);  (* XIP1 measurements *)
    SYSTEM.PUT(MCU.BUSCTRL_PERFSEL2, PERFSEL2);  (* SRAM8 measurements *)
    IF TestCase = RunFromRam THEN
      MemoryExt.CopyProc(SYSTEM.ADR(loopForRam), loopAddr);
      ASSERT(loopAddr # 0, Errors.StorageError);
      loopRam := SYSTEM.VAL(Iterator, loopAddr);
      MemoryExt.CopyProc(SYSTEM.ADR(incr), incrAddr);
      ASSERT(incrAddr # 0, Errors.StorageError);
      incrRam := SYSTEM.VAL(Incrementor, incrAddr)
    ELSIF TestCase = RunPreCached THEN
      MemoryExt.CacheProc(SYSTEM.ADR(loop));
      MemoryExt.CacheProc(SYSTEM.ADR(incr))
    END;
    Out.String(" run"); Out.String("  iter"); Out.String("   xip-acc"); Out.String("   ram-acc");
    Out.String("   t[us]"); Out.String("   t/xpi-acc[ns]"); Out.String("   t/ram-acc[ns]"); Out.Ln;
    i := 0;
    WHILE i < Runs DO
      test(i, Iterations);
      INC(i)
    END
  END run;

BEGIN
  run
END CodeLoading.

