MODULE ActorQueue;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3t
  Actor event-queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Types, Errors, Out;


  PROCEDURE Init*(q: Types.ActorQueue);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE Put*(q: Types.ActorQueue; act: Types.Actor);
  BEGIN
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL
  END Put;


  PROCEDURE Get*(q: Types.ActorQueue; VAR act: Types.Actor);
  BEGIN
    act := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next;
    ELSE
      q.tail := NIL
    END
  END Get;


  PROCEDURE PrintQ*(q: Types.ActorQueue);
  (* for testing/debugging *)
    VAR act: Types.Actor;
  BEGIN
    act := q.head;
    WHILE act # NIL DO
      Out.String("a "); Out.Hex(SYSTEM.VAL(INTEGER, act), 0); Out.Ln;
      act := act.next
    END
  END PrintQ;

END ActorQueue.
