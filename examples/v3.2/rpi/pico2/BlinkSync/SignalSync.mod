MODULE SignalSync;
(**
  Oberon RTK Framework v3.1
  --
  Example/test program, multi-threaded, dual-core, kernel-v1
  --
  Core 1 program: test program SignalSync adapted to run on core 1:
  - no Main import
  - no heartbeat
  - Run* exported to be started by core 0
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2024-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Kernel, Out, Cores, Signals, Errors;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    SenderPeriod = 1000 DIV MillisecsPerTick; (* 1000 ms *)

  VAR
    t1, t2, t3: Kernel.Thread;
    tid1, tid2, tid3: INTEGER;
    sig: Signals.Signal;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0)
  END writeThreadInfo;


  PROCEDURE receiver;
    VAR tid, cid: INTEGER;
  BEGIN
    cid := Cores.CoreId();
    tid := Kernel.Tid();
    REPEAT
      writeThreadInfo(tid, cid);
      Out.String(" await sig"); Out.Ln;
      Signals.Await(sig);
      writeThreadInfo(tid, cid);
      Out.String("   --> rec"); Out.Ln
    UNTIL FALSE
  END receiver;


  PROCEDURE sender;
    VAR tid, cid, cnt: INTEGER;
  BEGIN
    Kernel.SetPeriod(SenderPeriod, SenderPeriod);
    cid := Cores.CoreId();
    tid := Kernel.Tid();
    cnt := 0;
    REPEAT
      writeThreadInfo(tid, cid);
      Signals.Send(sig);
      INC(cnt);
      Out.String(" <== send "); Out.Int(cnt, 0); Out.Ln;
      Kernel.Next
    UNTIL FALSE
  END sender;


  PROCEDURE Run*;
    VAR res: INTEGER;
  BEGIN
    NEW(sig); ASSERT(sig # NIL, Errors.HeapOverflow);
    Signals.Init(sig);
    Kernel.Install(MillisecsPerTick);
    (* two receivers, running the same code *)
    Kernel.Allocate(receiver, ThreadStackSize, t1, tid1, res);
    ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t1);
    Kernel.Allocate(receiver, ThreadStackSize, t2, tid2, res);
    ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t2);
    (* one sender *)
    Kernel.Allocate(sender, ThreadStackSize, t3, tid3, res);
    ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t3);
    Out.String("start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END Run;

END SignalSync.
