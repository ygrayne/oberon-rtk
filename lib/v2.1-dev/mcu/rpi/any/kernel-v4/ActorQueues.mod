MODULE ActorQueues;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  Actor event-queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, T := KernelTypes, Errors, Out;


  PROCEDURE* Init*(q: T.ActorQ);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE* Put*(q: T.ActorQ; act: T.Actor);
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


  PROCEDURE* Get*(q: T.ActorQ; VAR act: T.Actor);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    act := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Get;


  PROCEDURE* GetTail*(q: T.ActorQ; VAR tail: T.Actor);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    tail := q.tail;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END GetTail;

(*
  PROCEDURE PrintQ*(q: T.ActorQ);
  (* for testing/debugging *)
  (* caller protects queue access *)
    VAR act: T.Actor;
  BEGIN
    act := q.head;
    WHILE act # NIL DO
      Out.String("a "); Out.Hex(SYSTEM.VAL(INTEGER, act), 0); Out.Ln;
      act := act.next
    END
  END PrintQ;
*)

END ActorQueues.
