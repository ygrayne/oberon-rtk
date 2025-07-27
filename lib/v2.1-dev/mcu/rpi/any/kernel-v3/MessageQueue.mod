MODULE MessageQueue;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Message in-queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Types, Errors, Out;

  TYPE
    Queue* = Types.MessageQueue;


  PROCEDURE Init*(q: Queue);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL
  END Init;


  PROCEDURE Put*(q: Queue; msg: Types.Message);
  (* caller protects queue access *)
  BEGIN
    IF q.head = NIL THEN
      q.head := msg
    ELSE
      q.tail.next := msg
    END;
    q.tail := msg;
    msg.next := NIL
  END Put;


  PROCEDURE Get*(q: Queue): Types.Message;
  (* caller protects queue access *)
    VAR msg: Types.Message;
  BEGIN
    msg := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next
    ELSE
      q.tail := NIL
    END;
    RETURN msg
  END Get;


  PROCEDURE PrintQ*(q: Queue);
  (* for testing/debugging *)
  (* caller protects queue access *)
    VAR msg: Types.Message;
  BEGIN
    msg := q.head;
    WHILE msg # NIL DO
      Out.String("m "); Out.Hex(SYSTEM.VAL(INTEGER, msg), 0); Out.Ln;
      msg := msg.next
    END
  END PrintQ;

END MessageQueue.
