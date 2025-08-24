MODULE K4base;
(**
  Oberon RTK Framework v2.1
  --
  Base test program for kernel-v4 prototype.
  https://oberon-rtk.org/docs/examples/v2/k4tests/
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, Main, MCU := MCU2, T := KernelTypes, Kernel, Actors, ReadyQueues, Out, Errors;

  CONST
    RunPrio = MCU.PPB_ExcPrio4;
    RunIntNo = MCU.PPB_SPAREIRQ_IRQ0;
    SysTickPrio = MCU.PPB_ExcPrio2;
    TIMER_RAWL = MCU.TIMER0_BASE + MCU.TIMER_TIMERAWL_Offset;

  TYPE
    A0 = POINTER TO A0desc;
    A0desc = RECORD (T.ActorDesc)
      cnt: INTEGER;
      startAt: INTEGER
    END;

  VAR
    ai0, ai1, ab0, ab1: A0;
    rdyQ: T.ReadyQ;


  PROCEDURE rdyRun[0];
  (* ready queue run int handler *)
  BEGIN
    (*
    Out.String("rdyRun"); Out.Ln;
    *)
    Kernel.RunQueue(rdyQ)
  END rdyRun;


  PROCEDURE aiRun(act: T.Actor);
  (* systick-interrupt-driven actor run procedure *)
    VAR a: A0; timeL: INTEGER;
  BEGIN
    SYSTEM.GET(TIMER_RAWL, timeL);
    a := act(A0);
    Out.String("=> int"); Out.Int(a.id, 2); Out.Int(a.cnt, 12);
    Out.Int(timeL - a.startAt, 12); Out.Ln;
    INC(a.cnt);
    a.startAt := timeL;
    Kernel.GetTick(a)
  END aiRun;


  PROCEDURE abRun(act: T.Actor);
  (* background actor run procedure *)
    VAR a: A0; timeL, i: INTEGER;
  BEGIN
    SYSTEM.GET(TIMER_RAWL, timeL);
    a := act(A0);
    Out.String("-> bg"); Out.Int(a.id, 2); Out.String(" begin"); Out.Int(a.cnt, 12);
    Out.Int(timeL - a.startAt, 12); Out.Ln;
    INC(a.cnt);
    a.startAt := timeL;
    i := 0;
    WHILE i < 10000000 DO INC(i) END; (* waste cycles *)
    Out.String("-> bg"); Out.Int(a.id, 2); Out.String(" end"); Out.Ln;
    Kernel.Submit(act, 2)
  END abRun;


  PROCEDURE aiInit(act: T.Actor);
    VAR a: A0;
  BEGIN
    a := act(A0);
    a.cnt := 0;
    a.startAt := 0;
    a.run := aiRun;
    Kernel.GetTick(a)
  END aiInit;


  PROCEDURE abInit(act: T.Actor);
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
    Kernel.Install(1000, SysTickPrio);
    NEW(rdyQ); ASSERT(rdyQ # NIL, Errors.HeapOverflow);
    ReadyQueues.Install(rdyQ, rdyRun, RunIntNo, RunPrio, 0, 0);
    NEW(ai0); ASSERT(ai0 # NIL, Errors.HeapOverflow);
    Actors.Init(ai0, aiInit, 0);
    NEW(ai1); ASSERT(ai1 # NIL, Errors.HeapOverflow);
    Actors.Init(ai1, aiInit, 1);
    NEW(ab0); ASSERT(ab0 # NIL, Errors.HeapOverflow);
    Actors.Init(ab0, abInit, 2);
    NEW(ab1); ASSERT(ab1 # NIL, Errors.HeapOverflow);
    Actors.Init(ab1, abInit, 3);
    Actors.Run(ai0, rdyQ);
    Actors.Run(ai1, rdyQ);
    Kernel.Submit(ab0, 0);
    Kernel.Submit(ab1, 0);
    Out.String("end init => start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END K4base.
