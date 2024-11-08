MODULE NoBusyWaitingC1;
(**
  Oberon RTK Framework v2
  --
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/nobusywating/
  --
  See module 'NoBusyWaitingC0'
  Uncomment 'Run' in the module init section to run this program alone on core 0.
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, MultiCore, Out, Timers, Errors;

  CONST
    MillisecsPerTick  = 5;
    ThreadStackSize = 1024;
    TestString0 = " 01234567890123456789";
    TestString1 = " 0123456789012345678901234";
    TestString2 = " 012345678901234567890123456789";
    TestString3 = " 01234567890123456789012345678901234";
    TestString4 = " 0123456789012345678901234567890123456789";

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;
    timer: Timers.Device;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE t0c;
    VAR tid, cid, tk, before, start, timeL, interval, runtime: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    tk := 0;
    interval := 0; runtime := 0;
    Timers.GetTimeL(timer, before);
    REPEAT
      IF tk = 200 THEN (* every second *)
        writeThreadInfo(tid, cid);
        Out.Int(interval, 6); Out.Int(runtime, 6); Out.Ln;
        interval := 0; runtime := 0;
        tk := 0
      END;
      Timers.GetTimeL(timer, timeL);
      IF timeL - start > runtime THEN (* measure max run-time *)
        runtime := timeL - start
      END;
      Kernel.Next;
      Timers.GetTimeL(timer, timeL);
      IF timeL - before > interval THEN (* measure max time between runs *)
        interval := timeL - before
      END;
      before := timeL;
      start := timeL;
      INC(tk)
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR tid, cid, trigger: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    REPEAT
      writeThreadInfo(tid, cid);
      Out.String(TestString1);    (* change output string here *)
      trigger := Kernel.Trigger();
      IF trigger = Kernel.TrigPeriod THEN
        Out.String(" P")
      ELSE
        Out.String(" D")
      END;
      Out.Ln;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE Run*;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t0, 5, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END Run;

  PROCEDURE init;
  BEGIN
    NEW(timer); ASSERT(timer # NIL, Errors.HeapOverflow);
    Timers.Init(timer, Timers.TIMER0);
    Timers.Configure(timer)
  END init;

BEGIN
  init
  (*Run*)
END NoBusyWaitingC1.
