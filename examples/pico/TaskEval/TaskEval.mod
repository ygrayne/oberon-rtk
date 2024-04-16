MODULE TaskEval;
(**
  Oberon RTK Framework
  Example program, single-threaded, one core
  Description & instructions: https://oberon-rtk.org/examples/taskeval/
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Tasks, Out, Timers;

  CONST
    NumTasks = 8;

    (* test control *)
    PrintQueue = TRUE;

    TimeBetweenTasks0 = 50; (* micro-seconds *)
    TimeBetweenTasks1 = 10;
    TimeBetweenTasks = TimeBetweenTasks0;

    FirstTaskAfter0 = 1000000 - 100; (* micro-seconds *)
    FirstTaskAfter1 = 500;
    FirstTaskAfter2 = 20;
    FirstTaskAfter3 = 10;
    FirstTaskAfter4 = 15;
    FirstTaskAfter = FirstTaskAfter0;

    TimerStart0 = 0FFFFFFFFH - 1000000 - 100; (* micro-seconds *)
    TimerStart1 = 0FFFFFFFFH - 700;
    TimerStart2 = 0FFFFFFFFH - 570;
    TimerStart3 = 0FFFFFFFFH - 250;
    TimerStart4 = 0FFFFFFFFH - 90;
    TimerStart = TimerStart0;

  VAR
    tasks: ARRAY NumTasks OF Tasks.Task;
    dt: Tasks.Task;
    now: INTEGER;
    taskRunIx: INTEGER;
    taskRun: ARRAY NumTasks OF INTEGER;


  PROCEDURE tc;
  (* procedure for tasks *)
  BEGIN
    taskRun[taskRunIx] := Tasks.Ct.id;
    INC(taskRunIx)
  END tc;


  PROCEDURE dtc;
  (* diagnostics: print results *)
    VAR i: INTEGER; t: Tasks.Task;
  BEGIN
    IF PrintQueue THEN
      Out.String("done"); Out.Ln
    ELSE
      Out.String("task"); Out.String("    sch at"); Out.String("      q at"); Out.String(" q-del");
      Out.String("   sch for"); Out.String(" run");
      Out.String("    int at"); Out.String("    run at"); Out.String(" r-del"); Out.String("    ord");
      Out.Ln;
      i := 0;
      WHILE i < NumTasks DO
        t := tasks[i];
        Out.Int(t.id, 4); Out.Hex(t.scheduleTime, 10); Out.Hex(t.queuedTime, 10); Out.Int(t.queuedTime - t.scheduleTime, 6);
        Out.Hex(t.time, 10); Out.Int(t.runMode, 4);
        IF t.runMode = Tasks.RunModeInt THEN Out.Hex(t.intTime, 10) ELSE Out.String(" --       ")  END;
        Out.Hex(t.runTime, 10); Out.Int(t.runTime - t.time, 6); Out.Int(taskRun[i], 4);
        IF taskRun[i] = i THEN Out.String(" ok") END;
        Out.Ln;
        INC(i)
      END;
      i := 0;
      WHILE i < NumTasks DO
        Out.Int(taskRun[i], 3);
        INC(i)
      END;
      Out.Ln
    END
  END dtc;

  (* testing correct run-queue insertion *)
  PROCEDURE run0;
    VAR i: INTEGER; time: INTEGER; t: Tasks.Task;
  BEGIN
    Tasks.Install(PrintQueue);
    Timers.SetTime(0, TimerStart);
    i := 0;
    WHILE i < NumTasks DO
      NEW(tasks[i]);
      Tasks.Init(tasks[i], tc, i);
      INC(i)
    END;
    NEW(dt);
    Tasks.Init(dt, dtc, 13);
    taskRunIx := 0;
    Timers.GetTimeL(now);
    (* schedule tasks 2 to 6, even numbers only *)
    time := now + FirstTaskAfter + (2 * TimeBetweenTasks);
    i := 2;
    WHILE i < NumTasks DO
      t := tasks[i];
      SYSTEM.GET(MCU.TIMER_TIMERAWL, t.scheduleTime);
      Tasks.Put(t, time);
      SYSTEM.GET(MCU.TIMER_TIMERAWL, t.queuedTime);
      INC(i, 2);
      INC(time, 2 * TimeBetweenTasks)
    END;
    (* schedule tasks 1 to 7, odd numbers only *)
    time := now + FirstTaskAfter + TimeBetweenTasks;
    i := 1;
    WHILE i < NumTasks DO
      t := tasks[i];
      SYSTEM.GET(MCU.TIMER_TIMERAWL, t.scheduleTime);
      Tasks.Put(t, time);
      SYSTEM.GET(MCU.TIMER_TIMERAWL, t.queuedTime);
      INC(i, 2);
      INC(time, 2 * TimeBetweenTasks)
    END;
    (* schedule task 0 *)
    time := now + FirstTaskAfter;
    t := tasks[0];
    SYSTEM.GET(MCU.TIMER_TIMERAWL, t.scheduleTime);
    Tasks.Put(t, time);
    SYSTEM.GET(MCU.TIMER_TIMERAWL, t.queuedTime);
    (* schedule diagnostics task *)
    Tasks.Put(dt, time + 500000)
  END run0;

  (* testing timing *)
  PROCEDURE run1;
    VAR i: INTEGER; time: INTEGER; t: Tasks.Task;
  BEGIN
    Tasks.Install(PrintQueue);
    Timers.SetTime(0, TimerStart);
    i := 0;
    WHILE i < NumTasks DO
      NEW(tasks[i]);
      Tasks.Init(tasks[i], tc, i);
      INC(i)
    END;
    NEW(dt);
    Tasks.Init(dt, dtc, 13);
    taskRunIx := 0;
    Timers.GetTimeL(now);
    time := now + FirstTaskAfter;
    i := 0;
    WHILE i < NumTasks DO
      t := tasks[i];
      SYSTEM.GET(MCU.TIMER_TIMERAWL, t.scheduleTime);
      Tasks.Put(t, time);
      SYSTEM.GET(MCU.TIMER_TIMERAWL, t.queuedTime);
      INC(i);
      INC(time, TimeBetweenTasks)
    END;
    (* schedule diagnostics task *)
    Tasks.Put(dt, time + 500000)
  END run1;

BEGIN
  IF PrintQueue THEN run0 ELSE run1 END
END TaskEval.

