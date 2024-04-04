MODULE CodeLoading;
(**
  Oberon RTK Framework
  Example program, single-threaded, one core
  Description & instructions: https://oberon-rtk.org/examples/codeloading/
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, SYSTEM, MCU := MCU2, MemoryExt, Errors, Out, StartUp;

  CONST
    RAM = FALSE; (* set TRUE to copy test procedures to RAM *)

  TYPE
    Iterator = PROCEDURE(iterations: INTEGER; VAR cntXpi, cntRam, time: INTEGER);
    Incrementor = PROCEDURE(VAR i: INTEGER);

  VAR
    loopRam: Iterator;
    incrRam: Incrementor;


  PROCEDURE incr(VAR i: INTEGER);
  BEGIN
    INC(i)
  END incr;


  PROCEDURE loop(iterations: INTEGER; VAR cntXpi, cntRam, time: INTEGER);
    VAR i, it, go, done: INTEGER;
  BEGIN
    it := iterations DIV 8;
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR1, 0);
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR0, 0);
    SYSTEM.GET(MCU.TIMER_TIMERAWL, go);
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
    SYSTEM.GET(MCU.TIMER_TIMERAWL, done);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR0, cntXpi);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR1, cntRam);
    time := done - go
  END loop;


  PROCEDURE loopForRam(iterations: INTEGER; VAR cntXpi, cntRam, time: INTEGER);
    VAR i, it, go, done: INTEGER;
  BEGIN
    it := iterations DIV 8;
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR0, 0);
    SYSTEM.PUT(MCU.BUSCTRL_PERFCTR1, 0);
    SYSTEM.GET(MCU.TIMER_TIMERAWL, go);
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
    SYSTEM.GET(MCU.TIMER_TIMERAWL, done);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR1, cntRam);
    SYSTEM.GET(MCU.BUSCTRL_PERFCTR0, cntXpi);
    time := done - go
  END loopForRam;


  PROCEDURE test(runNo, iterations: INTEGER);
    VAR cntXpi, cntRam, time: INTEGER;
  BEGIN
    Out.Int(runNo, 4); Out.Int(iterations, 6);
    IF RAM THEN (* run from RAM *)
      loopRam(iterations, cntXpi, cntRam, time)
    ELSE (* run from Flash *)
      loop(iterations, cntXpi, cntRam, time)
    END;
    Out.Int(cntXpi, 10); Out.Int(cntRam, 10); Out.Int(time, 8);
    IF cntXpi > 0 THEN
      Out.Int((time * 1000) DIV cntXpi, 12)
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
    StartUp.AwaitReleaseDone(MCU.RESETS_BUSCTRL);
    SYSTEM.PUT(MCU.BUSCTRL_PERFSEL0, MCU.BUSCTRL_PERFSEL_XPI);    (* PERFSEL0 for XPI measurements *)
    SYSTEM.PUT(MCU.BUSCTRL_PERFSEL1, MCU.BUSCTRL_PERFSEL_SRAM4);  (* PERFSEL1 for SRAM4 measurements *)
    IF RAM THEN
      MemoryExt.CopyProc(SYSTEM.ADR(loopForRam), loopAddr);
      ASSERT(loopAddr # 0, Errors.StorageError);
      loopRam := SYSTEM.VAL(Iterator, loopAddr);
      MemoryExt.CopyProc(SYSTEM.ADR(incr), incrAddr);
      ASSERT(incrAddr # 0, Errors.StorageError);
      incrRam := SYSTEM.VAL(Incrementor, incrAddr)
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

