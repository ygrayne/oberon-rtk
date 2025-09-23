MODULE Kernel;
(**
  Oberon RTK Framework v2.1
  --
  Multi-threading kernel-v3t.
  Use a trap for shared data protection.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Types, SysCall, MessageQueue, ActorQueue, Out;

  PROCEDURE printQ(evQ: Types.EventQueue);
  (* for testing/debugging *)
  BEGIN
    SYSTEM.EMIT(MCU.CPSID_I);
    ActorQueue.PrintQ(evQ.actQ);
    MessageQueue.PrintQ(evQ.msgQ);
    SYSTEM.EMIT(MCU.CPSIE_I)
  END printQ;


  PROCEDURE PutMsg*(evQ: Types.EventQueue; msg: Types.Message);
    VAR act: Types.Actor;
  BEGIN
    Out.String("put msg k3t"); Out.Ln;
    printQ(evQ);
    SysCall.AQget(evQ.actQ, act);
    IF act # NIL THEN
      act.msg := msg;
      SysCall.RQput(act.rdyQ, act)
    ELSE
      SysCall.MQput(evQ.msgQ, msg)
    END
  END PutMsg;


  PROCEDURE GetMsg*(evQ: Types.EventQueue; act: Types.Actor);
    VAR msg: Types.Message;
  BEGIN
    Out.String("get msg k3t"); Out.Ln;
    printQ(evQ);
    SysCall.MQget(evQ.msgQ, msg);
    IF msg # NIL THEN
      act.msg := msg;
      SysCall.RQput(act.rdyQ, act)
    ELSE
      SysCall.AQput(evQ.actQ, act)
    END
  END GetMsg;


  PROCEDURE Run*(q: Types.ReadyQueue);
  (* to be called by run int handler of ready queue *)
    VAR act: Types.Actor;
  BEGIN
    Out.String("rdyQ run");
    Out.Hex(SYSTEM.VAL(INTEGER, q), 12);
    Out.Ln;
    SysCall.RQget(q, act);
    WHILE act # NIL DO
      Out.Hex(SYSTEM.VAL(INTEGER, act), 12); Out.Ln;
      act.run(act); (* must re-subscribe to a MessageQueue *)
      SysCall.MPput(act.msg.pool, act.msg);
      SysCall.RQget(q, act)
    END
  END Run;

END Kernel.
