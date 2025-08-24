MODULE Kernel;
(**
  Oberon RTK Framework v2.1
  --
  Multi-threading kernel-v4.
  Interrupt-driven asynchronous tasks and synchronous background tasks.
  General ticker service.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, T := KernelTypes, SysTick, ReadyQueues, MessageQueues,
    ActorQueues, MessagePools, Errors, LED;

  TYPE
    CoreContext = POINTER TO CoreContextDesc;
    CoreContextDesc = RECORD
      loopActQ: T.ActorQ;
      loopRdyQ: T.ReadyQ;
      tickActQ: T.ActorQ
    END;

  VAR
    coreCon: ARRAY MCU.NumCores OF CoreContext;

(*
  PROCEDURE printQ(evQ: T.EventQ);
  (* for testing/debugging *)
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    ActorQueues.PrintQ(evQ.actQ);
    MessageQueues.PrintQ(evQ.msgQ);
    SYSTEM.EMITH(MCU.CPSIE_I)
  END printQ;
*)

  PROCEDURE PutMsg*(evQ: T.EventQ; msg: T.Message);
    VAR act: T.Actor;
  BEGIN
    ActorQueues.Get(evQ.actQ, act);
    IF act # NIL THEN
      act.msg := msg;
      ReadyQueues.Put(act.rdyQ, act)
    ELSE
      MessageQueues.Put(evQ.msgQ, msg)
    END
  END PutMsg;


  PROCEDURE GetMsg*(evQ: T.EventQ; act: T.Actor);
    VAR msg: T.Message;
  BEGIN
    MessageQueues.Get(evQ.msgQ, msg);
    IF msg # NIL THEN
      act.msg := msg;
      ReadyQueues.Put(act.rdyQ, act)
    ELSE
      ActorQueues.Put(evQ.actQ, act)
    END
  END GetMsg;


  PROCEDURE PutMsgAwaited*(evQ: T.EventQ; msg: T.Message);
    VAR act: T.Actor;
  BEGIN
    ActorQueues.Get(evQ.actQ, act);
    IF act # NIL THEN
      act.msg := msg;
      ReadyQueues.Put(act.rdyQ, act)
    ELSE
      MessagePools.Put(msg.pool, msg)
    END
  END PutMsgAwaited;


  PROCEDURE RunQueue*(q: T.ReadyQ);
  (* to be called by run int handler of ready queue or kernel loop *)
    VAR act: T.Actor; msg: T.Message;
  BEGIN
    ReadyQueues.Get(q, act);
    WHILE act # NIL DO
      msg := act.msg;
      act.run(act);
      IF msg # NIL THEN
        MessagePools.Put(msg.pool, msg)
      END;
      ReadyQueues.Get(q, act)
    END
  END RunQueue;


  PROCEDURE tickHandler[0];
    VAR cid: INTEGER; ctx: CoreContext; act: T.Actor;
  BEGIN
    SYSTEM.PUT(LED.LXOR, {LED.Green});
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ActorQueues.Get(ctx.tickActQ, act);
    WHILE act # NIL DO (* run all waiting actors *)
      act.msg := NIL;
      ReadyQueues.Put(act.rdyQ, act);
      ActorQueues.Get(ctx.tickActQ, act)
    END
  END tickHandler;


  PROCEDURE GetTick*(act: T.Actor);
  (* get next tick from kernel ticker *)
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    act.msg := NIL;
    ActorQueues.Put(ctx.tickActQ, act)
  END GetTick;


  PROCEDURE Submit*(act: T.Actor; ticks: INTEGER);
  (* submit to loop *)
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    act.ticker := ticks;
    act.msg := NIL;
    ActorQueues.Put(ctx.loopActQ, act)
  END Submit;


  PROCEDURE loop;
    VAR cid: INTEGER; act, tail: T.Actor; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    REPEAT
      SYSTEM.EMITH(MCU.WFE);
      IF SysTick.Tick() THEN
        ActorQueues.Get(ctx.loopActQ, act);
        ActorQueues.GetTail(ctx.loopActQ, tail);
        WHILE act # NIL DO
          DEC(act.ticker);
          IF act.ticker <= 0 THEN
            act.msg := NIL;
            ReadyQueues.Put(ctx.loopRdyQ, act)
          ELSE
            ActorQueues.Put(ctx.loopActQ, act)
          END;
          IF act # tail THEN
            ActorQueues.Get(ctx.loopActQ, act)
          ELSE
            act := NIL
          END
        END;
        RunQueue(ctx.loopRdyQ)
      END
    UNTIL FALSE
  END loop;


  PROCEDURE Run*;
  BEGIN
    SysTick.Enable;
    loop
  END Run;


  PROCEDURE Install*(millisecsPerTick, tickPrio: INTEGER);
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    NEW(coreCon[cid]); ASSERT(coreCon[cid] # NIL, Errors.HeapOverflow);
    ctx := coreCon[cid];
    (* loop *)
    NEW(ctx.loopActQ); ASSERT(ctx.loopActQ # NIL, Errors.HeapOverflow);
    ActorQueues.Init(ctx.loopActQ);
    NEW(ctx.loopRdyQ); ASSERT(ctx.loopRdyQ # NIL, Errors.HeapOverflow);
    ReadyQueues.Init(ctx.loopRdyQ, cid, 0);
    (* tick *)
    NEW(ctx.tickActQ); ASSERT(ctx.tickActQ # NIL, Errors.HeapOverflow);
    ActorQueues.Init(ctx.tickActQ);
    SysTick.Init(millisecsPerTick, tickPrio, tickHandler)
  END Install;

END Kernel.
