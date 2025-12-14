MODULE SignalSync;
(**
  Oberon RTK Framework v3.0
  --
  Example program, multi-threaded, single-core
  Description: https://oberon-rtk.org/docs/examples/v2/signalsync/
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Kernel-v1
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, Out, Cores, Signals, Errors, LED;

  CONST
    MicrosecondsPerTick  = 10000; (* 10 ms *)
    ThreadStackSize = 1024;

    T0period = 50;
    T3period = 100;

  VAR
    t0, t1, t2, t3: Kernel.Thread;
    tid0, tid1, tid2, tid3: INTEGER;
    sig: Signals.Signal;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0)
  END writeThreadInfo;


  PROCEDURE t0c;
  BEGIN
    LED.Set({LED.Pico});
    Kernel.SetPeriod(T0period, 0);
    REPEAT
      LED.Toggle({LED.Pico});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR tid, cid: INTEGER;
  BEGIN
    cid := Cores.CoreId();
    tid := Kernel.Tid();
    REPEAT
      writeThreadInfo(tid, cid);
      Out.String(" await sig"); Out.Ln;
      Signals.Await(sig);
      writeThreadInfo(tid, cid);
      Out.String(" ==> sig"); Out.Ln
    UNTIL FALSE
  END t1c;


  PROCEDURE t3c;
    VAR tid, cid, cnt: INTEGER;
  BEGIN
    Kernel.SetPeriod(T3period, T3period);
    cid := Cores.CoreId();
    tid := Kernel.Tid();
    cnt := 0;
    REPEAT
      writeThreadInfo(tid, cid);
      Signals.Send(sig);
      INC(cnt);
      Out.String(" <== sig "); Out.Int(cnt, 0); Out.Ln;
      Kernel.Next
    UNTIL FALSE
  END t3c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    NEW(sig); ASSERT(sig # NIL, Errors.HeapOverflow);
    Signals.Init(sig);
    Kernel.Install(MicrosecondsPerTick);
    (* heartbeat blinker *)
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t0);
    (* two receivers, running the same code *)
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t1); (* note: no period as triggered by signal *)
    Kernel.Allocate(t1c, ThreadStackSize, t2, tid2, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t2); (* note: no period as triggered by signal *)
    (* one sender *)
    Kernel.Allocate(t3c, ThreadStackSize, t3, tid3, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t3);
    Out.String("start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END SignalSync.
