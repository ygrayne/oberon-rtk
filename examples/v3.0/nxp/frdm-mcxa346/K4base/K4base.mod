MODULE K4base;
(**
  Oberon RTK Framework v3.0
  --
  Base test program for kernel-v4 prototype.
  https://oberon-rtk.org/docs/examples/v2/k4tests/
  --
  MCU: MCX-A346
  Board: FRDM-MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, MCU := MCU2, Kernel, Out, CounterTimers, ClockCtrl, Errors;

  CONST
    RunPrio = MCU.ExcPrio4;
    RunIntNo = MCU.IRQ_SW_0;
    SysTickPrio = MCU.ExcPrio2;
    (*TIMER_RAWL = MCU.TIMER0_BASE + MCU.TIMER_TIMERAWL_Offset;*)

  TYPE
    A0 = POINTER TO A0desc;
    A0desc = RECORD (Kernel.ActorDesc)
      cnt: INTEGER;
      startAt: INTEGER
    END;

  VAR
    ai0, ai1, ab0, ab1: A0;
    rdyQ: Kernel.ReadyQ;
    ct: CounterTimers.Device;


  PROCEDURE rdyRun[0];
  (* ready queue run int handler *)
  BEGIN
    Kernel.RunQueue(rdyQ)
  END rdyRun;


  PROCEDURE aiRun(act: Kernel.Actor);
  (* systick-interrupt-driven actor run procedure *)
    VAR a: A0; cnt: INTEGER;
  BEGIN
    CounterTimers.GetCount(ct, cnt);
    a := act(A0);
    Out.String("=> int"); Out.Int(a.id, 2); Out.Int(a.cnt, 12);
    Out.Int(cnt - a.startAt, 12); Out.Ln;
    INC(a.cnt);
    a.startAt := cnt;
    Kernel.GetTick(a)
  END aiRun;


  PROCEDURE abRun(act: Kernel.Actor);
  (* background actor run procedure *)
    VAR a: A0; cnt, i: INTEGER;
  BEGIN
    CounterTimers.GetCount(ct, cnt);
    a := act(A0);
    Out.String("-> bg"); Out.Int(a.id, 2); Out.String(" begin"); Out.Int(a.cnt, 12);
    Out.Int(cnt - a.startAt, 12); Out.Ln;
    INC(a.cnt);
    a.startAt := cnt;
    i := 0;
    WHILE i < 10000000 DO INC(i) END; (* waste cycles *)
    Out.String("-> bg"); Out.Int(a.id, 2); Out.String(" end"); Out.Ln;
    Kernel.Submit(act, 2)
  END abRun;


  PROCEDURE aiInit(act: Kernel.Actor);
    VAR a: A0;
  BEGIN
    a := act(A0);
    a.cnt := 0;
    a.startAt := 0;
    a.run := aiRun;
    Kernel.GetTick(a)
  END aiInit;


  PROCEDURE abInit(act: Kernel.Actor);
    VAR a: A0;
  BEGIN
    a := act(A0);
    a.cnt := 0;
    a.startAt := 0;
    a.run := abRun;
    Kernel.Submit(act, 2)
  END abInit;


  PROCEDURE run;
  BEGIN
    Out.String("begin init"); Out.Ln;

    NEW(ct); ASSERT(ct # NIL, Errors.HeapOverflow);
    CounterTimers.Init(ct, CounterTimers.CTIMER0);
    CounterTimers.Configure(ct, ClockCtrl.CLK_CLK_1M, 0, 0);
    CounterTimers.Enable(ct);

    Kernel.Install(1000, SysTickPrio);
    Kernel.NewRdyQ(rdyQ, 0, 0);
    Kernel.InstallRdyQ(rdyQ, rdyRun, RunIntNo, RunPrio);

    NEW(ai0); ASSERT(ai0 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ai0, aiInit, 0);
    NEW(ai1); ASSERT(ai1 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ai1, aiInit, 1);
    NEW(ab0); ASSERT(ab0 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ab0, abInit, 2);
    NEW(ab1); ASSERT(ab1 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ab1, abInit, 3);

    Kernel.RunAct(ai0, rdyQ);
    Kernel.RunAct(ai1, rdyQ);
    Kernel.Submit(ab0, 0);
    Kernel.Submit(ab1, 0);

    Out.String("end init => start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END K4base.
