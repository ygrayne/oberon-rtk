MODULE StackUsage;
(**
  Oberon RTK Framework
  Example program, multi-threaded, single-core
  Description: https://oberon-rtk.org/examples/stackusage/
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, Memory, Out, Errors, GPIO, LED := LEDext, Random, Timers;

  CONST
    MillisecsPerTick  = 5;
    ThreadStackSize = 1024;
    NumThreads = 12;

  VAR
    tb, t4: Kernel.Thread;
    tidb, tid4: INTEGER;
    t: ARRAY 12 OF Kernel.Thread;
    id: ARRAY 12 OF INTEGER;
    limits: ARRAY 12 OF INTEGER;


  PROCEDURE tbc;
  BEGIN
    GPIO.Set({LED.LEDpico});
    REPEAT
      GPIO.Toggle({LED.LEDpico});
      Kernel.Next
    UNTIL FALSE
  END tbc;


  PROCEDURE do2(VAR cnt: INTEGER; lim: INTEGER);
    CONST Asize = 32;
    VAR i: INTEGER; a: ARRAY Asize OF INTEGER;
  BEGIN
    i := 0;
    WHILE i < Asize DO a[i] := 0; INC(i) END;
    WHILE cnt < lim DO
      INC(cnt)
    END;
  END do2;


  PROCEDURE do1(VAR cnt: INTEGER; lim: INTEGER);
    CONST Asize = 32;
    VAR i: INTEGER; a: ARRAY Asize OF INTEGER;
  BEGIN
    i := 0;
    WHILE i < Asize DO a[i] := 0; INC(i) END;
    WHILE cnt < lim DO
      IF cnt >= 75 THEN
        do2(cnt, lim)
      END;
      INC(cnt)
    END;
  END do1;


  PROCEDURE do0(VAR cnt: INTEGER; lim: INTEGER);
    CONST Asize = 32;
    VAR i: INTEGER; a: ARRAY Asize OF INTEGER;
  BEGIN
    i := 0;
    WHILE i < Asize DO a[i] := 0; INC(i) END;
    WHILE cnt < lim DO
      IF cnt >= 50 THEN
        do1(cnt, lim)
      END;
      INC(cnt)
    END;
  END do0;


  PROCEDURE t0c;
    VAR tid, cnt: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    REPEAT
      cnt := 0;
      WHILE cnt < limits[tid] DO
        IF cnt = 25 THEN
          do0(cnt, limits[tid])
        END;
        INC(cnt)
      END;
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t4c;
    VAR i, stackSize, stackUsed: INTEGER;
  BEGIN
    REPEAT
      Out.String("stack usage:"); Out.Ln;
      Memory.CheckLoopStackUsage(stackSize, stackUsed);
      Out.Int(-1, 4); Out.Int(MillisecsPerTick, 6);
      Out.Int(stackSize, 6); Out.Int(stackUsed, 6);
      Out.Ln;
      i := 0;
      WHILE i < NumThreads DO
        Memory.CheckThreadStackUsage(id[i], stackSize, stackUsed);
        Out.Int(i, 4); Out.Int(limits[i], 6);
        Out.Int(stackSize, 6); Out.Int(stackUsed, 6);
        Out.Ln;
        INC(i)
      END;
      Memory.CheckThreadStackUsage(NumThreads, stackSize, stackUsed);
      Out.Int(NumThreads, 4); Out.Int(1000, 6);
      Out.Int(stackSize, 6); Out.Int(stackUsed, 6);
      Out.Ln;
      Kernel.Next
    UNTIL FALSE
  END t4c;


  PROCEDURE run;
    VAR i, seed, res: INTEGER;
  BEGIN
    Timers.GetTimeL(seed);
    Random.Seed(seed);
    i := 0;
    WHILE i < NumThreads DO
      limits[i] := Random.Next(100);
      INC(i)
    END;
    Memory.EnableStackCheck(TRUE); (* <== enable *)
    Kernel.Install(MillisecsPerTick);
    (* load *)
    i := 0;
    WHILE i < NumThreads DO
      Kernel.Allocate(t0c, ThreadStackSize, t[i], id[i], res); ASSERT(res = Kernel.OK, Errors.ProgError);
      Kernel.SetPeriod(t[i], 50, 0); Kernel.Enable(t[i]);
      INC(i)
    END;
    (* checker *)
    Kernel.Allocate(t4c, ThreadStackSize, t4, tid4, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t4, 1000, 0); Kernel.Enable(t4);
    (* heartbeat *)
    Kernel.Allocate(tbc, ThreadStackSize, tb, tidb, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(tb, 500, 0); Kernel.Enable(tb);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END StackUsage.
