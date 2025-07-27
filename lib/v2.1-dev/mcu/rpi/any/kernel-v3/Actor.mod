MODULE Actor;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Actor
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Types, Kernel, Errors;

  TYPE
    Actor = Types.Actor;
    ActorRun = Types.ActorRun;
    ReadyQueue = Types.ReadyQueue;
    EventQueue = Types.EventQueue;


  PROCEDURE Init*(act: Actor; run: ActorRun; id: INTEGER);
  BEGIN
    ASSERT(act # NIL, Errors.PreCond);
    act.id := id;
    act.run := run;
    act.rdyQ := NIL;
    act.msg := NIL;
    act.next := NIL
  END Init;


  PROCEDURE Start*(act: Actor; evQ: EventQueue; rdyQ: ReadyQueue);
  BEGIN
    act.rdyQ := rdyQ;
    Kernel.GetMsg(evQ, act)
  END Start;


  PROCEDURE SetReadyQueue*(act: Actor; rdyQ: ReadyQueue);
  BEGIN
    act.rdyQ := rdyQ
  END SetReadyQueue;

END Actor.
