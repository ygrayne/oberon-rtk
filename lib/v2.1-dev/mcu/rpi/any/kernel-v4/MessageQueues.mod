MODULE MessageQueues;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Message event-queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, T := KernelTypes, Errors, Out;


  PROCEDURE* Init*(q: T.MessageQ);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE* Put*(q: T.MessageQ; msg: T.Message);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    IF q.head = NIL THEN
      q.head := msg
    ELSE
      q.tail.next := msg
    END;
    q.tail := msg;
    msg.next := NIL;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Put;


  PROCEDURE* Get*(q: T.MessageQ; VAR msg: T.Message);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    msg := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Get;

(*
  PROCEDURE PrintQ*(q: T.MessageQ);
  (* for testing/debugging *)
  (* caller protects queue access *)
    VAR msg: T.Message;
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    msg := q.head;
    WHILE msg # NIL DO
      Out.String("m "); Out.Hex(SYSTEM.VAL(INTEGER, msg), 0); Out.Ln;
      msg := msg.next
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END PrintQ;
*)
END MessageQueues.
