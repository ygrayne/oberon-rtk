MODULE K4sema;
(**
  Oberon RTK Framework v2.1
  --
  Example/test program for kernel-v4: semaphores.
  https://oberon-rtk.org/docs/examples/v2/k4tests/
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, MCU := MCU2, T := KernelTypes, Kernel, Actors, ReadyQueues, Semaphores, Out, Errors;

  CONST
    MillisecsPerTick = 1000;
    RunPrio = MCU.PPB_ExcPrio4;
    RunIntNo = MCU.PPB_SPAREIRQ_IRQ0;
    SysTickPrio = MCU.PPB_ExcPrio2;

    StateClaim = 0;
    StatePrint0 = 1;
    StatePrint1 = 2;


  TYPE
    A0 = POINTER TO A0desc;
    A0desc = RECORD (T.ActorDesc)
      states: ARRAY 4 OF T.ActorRun
    END;

  VAR
    ai0, ai1: A0;
    rdyQ: T.ReadyQ;
    term: Semaphores.Semaphore;


  PROCEDURE rdyRun[0];
  (* ready queue run int handler *)
  BEGIN
    (*
    Out.String("rdyRun"); Out.Ln;
    *)
    Kernel.RunQueue(rdyQ)
  END rdyRun;

  (* actor states *)

  PROCEDURE aiPrint1(act: T.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> print message part 2"); Out.Int(act.id, 2); Out.Ln;
    Out.String("=> release"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.run := a.states[StateClaim];
    Semaphores.Release(term);
    Kernel.GetTick(act)
  END aiPrint1;

  PROCEDURE aiPrint0(act: T.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> print message part 1"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.run := a.states[StatePrint1];
    Kernel.GetTick(act)
  END aiPrint0;

  PROCEDURE aiClaim(act: T.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> claim"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.run := a.states[StatePrint0];
    Semaphores.Claim(term, act)
  END aiClaim;

  PROCEDURE aiInit(act: T.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> init"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.states[StateClaim] := aiClaim;
    a.states[StatePrint0] := aiPrint0;
    a.states[StatePrint1] := aiPrint1;
    a.run := a.states[StateClaim];
    Kernel.GetTick(act)
  END aiInit;


  PROCEDURE run;
  BEGIN
    Out.String("begin init"); Out.Ln;
    Kernel.Install(MillisecsPerTick, SysTickPrio);
    NEW(rdyQ); ASSERT(rdyQ # NIL, Errors.HeapOverflow);
    ReadyQueues.Install(rdyQ, rdyRun, RunIntNo, RunPrio, 0, 0);
    NEW(term); ASSERT(term # NIL, Errors.HeapOverflow);
    Semaphores.Init(term);
    NEW(ai0); ASSERT(ai0 # NIL, Errors.HeapOverflow);
    Actors.Init(ai0, aiInit, 0);
    NEW(ai1); ASSERT(ai1 # NIL, Errors.HeapOverflow);
    Actors.Init(ai1, aiInit, 1);
    Actors.Run(ai0, rdyQ);
    Actors.Run(ai1, rdyQ);
    Out.String("end init => start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END K4sema.
