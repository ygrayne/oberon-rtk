MODULE Kernel;
(**
  Oberon RTK Framework v2.1
  --
  Multi-threading kernel-v3.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Types, ReadyQueue, MessageQueue, ActorQueue, MessagePool, Out;


  PROCEDURE printQ(inQ: Types.EventQueue);
  (* for testing/debugging *)
  BEGIN
    ActorQueue.PrintQ(inQ.actQ);
    MessageQueue.PrintQ(inQ.msgQ)
  END printQ;


  PROCEDURE PutMsg*(inQ: Types.EventQueue; msg: Types.Message);
    VAR act: Types.Actor;
  BEGIN
    Out.String("put msg"); Out.Ln;
    SYSTEM.EMIT(MCU.CPSID);
    printQ(inQ);
    act := ActorQueue.Get(inQ.actQ);
    IF act # NIL THEN
      act.msg := msg;
      ReadyQueue.Put(act.rdyQ, act)
    ELSE
      MessageQueue.Put(inQ.msgQ, msg)
    END;
    SYSTEM.EMIT(MCU.CPSIE)
  END PutMsg;


  PROCEDURE GetMsg*(inQ: Types.EventQueue; act: Types.Actor);
    VAR msg: Types.Message;
  BEGIN
    Out.String("get msg"); Out.Ln;
    SYSTEM.EMIT(MCU.CPSID);
    MessagePool.Put(act.msg.pool, act.msg);
    printQ(inQ);
    msg := MessageQueue.Get(inQ.msgQ);
    IF msg # NIL THEN
      act.msg := msg;
      ReadyQueue.Put(act.rdyQ, act)
    ELSE
      ActorQueue.Put(inQ.actQ, act)
    END;
    SYSTEM.EMIT(MCU.CPSIE);
  END GetMsg;

END Kernel.
