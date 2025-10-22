MODULE K4sema;
(**
  Oberon RTK Framework v3.0
  --
  Example/test program for kernel-v4: semaphores.
  https://oberon-rtk.org/docs/examples/v2/k4tests/
  --
  MCU: RP2350
  Board: Pico2
  --
  Kernel-v4
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, MCU := MCU2, Kernel, Semaphores, Out, Errors;

  CONST
    MillisecsPerTick = 1000;
    RunPrio = MCU.ExcPrio4;
    RunIntNo = MCU.IRQ_SW_0;
    SysTickPrio = MCU.ExcPrio2;

    StateClaim = 0;
    StatePrint0 = 1;
    StatePrint1 = 2;


  TYPE
    A0 = POINTER TO A0desc;
    A0desc = RECORD (Kernel.ActorDesc)
      states: ARRAY 4 OF Kernel.ActorRun
    END;

  VAR
    ai0, ai1: A0;
    rdyQ: Kernel.ReadyQ;
    term: Semaphores.Semaphore;


  PROCEDURE rdyRun[0];
  (* ready queue run int handler *)
  BEGIN
    Kernel.RunQueue(rdyQ)
  END rdyRun;

  (* actor states *)

  PROCEDURE aiPrint1(act: Kernel.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> print message part 2"); Out.Int(act.id, 2); Out.Ln;
    Out.String("=> release"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.run := a.states[StateClaim];
    Semaphores.Release(term);
    Kernel.GetTick(act)
  END aiPrint1;

  PROCEDURE aiPrint0(act: Kernel.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> print message part 1"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.run := a.states[StatePrint1];
    Kernel.GetTick(act)
  END aiPrint0;

  PROCEDURE aiClaim(act: Kernel.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> claim"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.run := a.states[StatePrint0];
    Semaphores.Claim(term, act)
  END aiClaim;

  PROCEDURE aiInit(act: Kernel.Actor);
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
    Kernel.NewRdyQ(rdyQ, 0, 0);
    Kernel.InstallRdyQ(rdyQ, rdyRun, RunIntNo, RunPrio);

    NEW(term); ASSERT(term # NIL, Errors.HeapOverflow);
    Semaphores.Init(term);
    NEW(ai0); ASSERT(ai0 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ai0, aiInit, 0);
    NEW(ai1); ASSERT(ai1 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ai1, aiInit, 1);
    Kernel.RunAct(ai0, rdyQ);
    Kernel.RunAct(ai1, rdyQ);
    Out.String("end init => start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END K4sema.
