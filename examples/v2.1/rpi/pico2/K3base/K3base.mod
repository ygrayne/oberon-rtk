MODULE K3base;
(**
  Oberon RTK Framework v2.1
  --
  Base test program for kernel-v3 prototype.
  https://oberon-rtk.org/docs/examples/v2/k3base/
  --
  MCU: RP2350
  Board: Pico2, Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, Main, MCU := MCU2, Types, Kernel, Actor, Ticker, ReadyQueue, Out, Errors;

  CONST
    MilliSecsPerTick = 1000;
    RunPrio = MCU.PPB_ExcPrio4;
    RunIntNo = MCU.PPB_SPAREIRQ_IRQ0;
    TIMER_RAWL = MCU.TIMER0_BASE + MCU.TIMER_TIMERAWL_Offset;

  TYPE
    Actor0 = POINTER TO Actor0Desc;
    Actor0Desc = RECORD (Types.ActorDesc)
      cnt: INTEGER;
      time: INTEGER;
    END;

  VAR
    a0, a1: Actor0;
    rdyQ: ReadyQueue.Queue;


  PROCEDURE rdyRun[0];
  (* ready queue run int handler *)
  BEGIN
    Out.String("run int"); Out.Ln;
    ReadyQueue.Run(rdyQ)
  END rdyRun;


  PROCEDURE a0Run(act: Types.Actor);
  (* actor run procedure *)
    VAR a: Actor0; m: Ticker.Message; timeL: INTEGER;
  BEGIN
    SYSTEM.GET(TIMER_RAWL, timeL);
    a := act(Actor0);
    m := act.msg(Ticker.Message);
    Out.String("c0"); Out.Int(a.id, 2); Out.Int(a.cnt, 12); Out.Int(m.cnt, 12);
    Out.Int(timeL - a.time, 12); Out.Ln;
    INC(a.cnt);
    a.time := timeL;
    Kernel.GetMsg(Ticker.EvQ, a)
  END a0Run;


  PROCEDURE actInit(act: Actor0);
  BEGIN
    act.cnt := 0;
    act.time := 0;
  END actInit;


  PROCEDURE run;
  BEGIN
    Out.String("begin init"); Out.Ln;
    NEW(rdyQ); ASSERT(rdyQ # NIL, Errors.HeapOverflow);
    ReadyQueue.Install(rdyQ, rdyRun, RunIntNo, RunPrio, 0, 0);
    Ticker.Init(MilliSecsPerTick);
    NEW(a0); ASSERT(a0 # NIL, Errors.HeapOverflow);
    Actor.Init(a0, a0Run, 0); actInit(a0);
    NEW(a1); ASSERT(a1 # NIL, Errors.HeapOverflow);
    Actor.Init(a1, a0Run, 1); actInit(a1);
    Actor.Start(a0, Ticker.EvQ, rdyQ);
    Actor.Start(a1, Ticker.EvQ, rdyQ);
    Ticker.Start;
    Out.String("end init => start"); Out.Ln;
    REPEAT UNTIL FALSE
  END run;

BEGIN
  run
END K3base.
