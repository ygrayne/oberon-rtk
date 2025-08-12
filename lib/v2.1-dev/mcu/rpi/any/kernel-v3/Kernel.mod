MODULE Kernel;
(**
  Oberon RTK Framework v2.1
  --
  Multi-threading kernel-v3.
  Use disabling all interrupts for shared data protection.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Types, ReadyQueue, MessageQueue, ActorQueue, MessagePool, Out;


  PROCEDURE printQ(evQ: Types.EventQueue);
  (* for testing/debugging *)
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    ActorQueue.PrintQ(evQ.actQ);
    MessageQueue.PrintQ(evQ.msgQ);
    SYSTEM.EMITH(MCU.CPSIE_I)
  END printQ;


  PROCEDURE PutMsg*(evQ: Types.EventQueue; msg: Types.Message);
    VAR act: Types.Actor;
  BEGIN
    Out.String("put msg k3"); Out.Ln;
    printQ(evQ);
    ActorQueue.Get(evQ.actQ, act);
    IF act # NIL THEN
      act.msg := msg;
      ReadyQueue.Put(act.rdyQ, act)
    ELSE
      MessageQueue.Put(evQ.msgQ, msg)
    END
  END PutMsg;


  PROCEDURE GetMsg*(evQ: Types.EventQueue; act: Types.Actor);
    VAR msg: Types.Message;
  BEGIN
    Out.String("get msg k3"); Out.Ln;
    printQ(evQ);
    MessageQueue.Get(evQ.msgQ, msg);
    IF msg # NIL THEN
      act.msg := msg;
      ReadyQueue.Put(act.rdyQ, act)
    ELSE
      ActorQueue.Put(evQ.actQ, act)
    END
  END GetMsg;


  PROCEDURE Run*(q: Types.ReadyQueue);
  (* to be called by run int handler of ready queue *)
    VAR act: Types.Actor;
  BEGIN
    Out.String("rdyQ run");
    Out.Hex(SYSTEM.VAL(INTEGER, q), 12);
    Out.Ln;
    ReadyQueue.Get(q, act);
    WHILE act # NIL DO
      Out.Hex(SYSTEM.VAL(INTEGER, act), 12); Out.Ln;
      act.run(act); (* must re-subscribe to a MessageQueue *)
      MessagePool.Put(act.msg.pool, act.msg);
      ReadyQueue.Get(q, act)
    END
  END Run;

END Kernel.
