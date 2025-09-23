MODULE ActorQueue;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Actor event-queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Types, Errors, Out;

  TYPE
    Queue* = Types.ActorQueue;


  PROCEDURE Init*(q: Types.ActorQueue);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE Put*(q: Types.ActorQueue; act: Types.Actor);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Put;


  PROCEDURE Get*(q: Types.ActorQueue; VAR act: Types.Actor);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    act := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next;
    ELSE
      q.tail := NIL
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Get;


  PROCEDURE PrintQ*(q: Types.ActorQueue);
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
