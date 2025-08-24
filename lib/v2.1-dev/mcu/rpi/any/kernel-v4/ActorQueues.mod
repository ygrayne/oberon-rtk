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

  IMPORT SYSTEM, MCU := MCU2, T := KernelTypes, Errors;

  CONST
    ExcPrioBlock = MCU.PPB_ExcPrioHigh;


  PROCEDURE* Init*(q: T.ActorQ);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE* Put*(q: T.ActorQ; act: T.Actor);
    CONST R03 = 3;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL;
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
  END Put;


  PROCEDURE* Get*(q: T.ActorQ; VAR act: T.Actor);
    CONST R03 = 3;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    act := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next
    END;
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
  END Get;


  PROCEDURE* GetTail*(q: T.ActorQ; VAR tail: T.Actor);
    CONST R03 = 3;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    tail := q.tail;
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
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
