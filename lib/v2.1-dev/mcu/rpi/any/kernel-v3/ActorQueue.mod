MODULE ActorQueue;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Actor in-queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Types, Errors, Out;

  TYPE
    Queue* = Types.ActorQueue;


  PROCEDURE Init*(q: Queue);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE Put*(q: Queue; act: Types.Actor);
  (* caller protects queue access *)
  BEGIN
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL
  END Put;


  PROCEDURE Get*(q: Queue): Types.Actor;
  (* caller protects queue access *)
    VAR act: Types.Actor;
  BEGIN
    act := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next;
    ELSE
      q.tail := NIL
    END;
    RETURN act
  END Get;


  PROCEDURE PrintQ*(q: Queue);
  (* for testing/debugging *)
  (* caller protects queue access *)
    VAR act: Types.Actor;
  BEGIN
    act := q.head;
    WHILE act # NIL DO
      Out.String("a "); Out.Hex(SYSTEM.VAL(INTEGER, act), 0); Out.Ln;
      act := act.next
    END
  END PrintQ;

END ActorQueue.
