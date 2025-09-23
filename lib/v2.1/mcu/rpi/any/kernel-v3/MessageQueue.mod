MODULE MessageQueue;
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

  IMPORT SYSTEM, MCU := MCU2, Types, Errors, Out;

  TYPE
    Queue* = Types.MessageQueue;


  PROCEDURE Init*(q: Types.MessageQueue);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE Put*(q: Types.MessageQueue; msg: Types.Message);
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


  PROCEDURE Get*(q: Types.MessageQueue; VAR msg: Types.Message);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    msg := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next
    ELSE
      q.tail := NIL
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Get;


  PROCEDURE PrintQ*(q: Types.MessageQueue);
  (* for testing/debugging *)
  (* caller protects queue access *)
    VAR msg: Types.Message;
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    msg := q.head;
    WHILE msg # NIL DO
      Out.String("m "); Out.Hex(SYSTEM.VAL(INTEGER, msg), 0); Out.Ln;
      msg := msg.next
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END PrintQ;

END MessageQueue.
