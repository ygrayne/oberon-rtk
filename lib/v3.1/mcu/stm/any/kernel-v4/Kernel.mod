MODULE Kernel;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Multi-threading kernel-v4.
  Interrupt-driven asynchronous tasks and synchronous background tasks.
  General ticker service.
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, PPB, EXC, MemCfg, Cores, Exceptions, SysTick, Errors, LED;

  CONST
    NumCores = MemCfg.NumCoresUsed;
    ExcPrioBlock = EXC.ExcPrioHigh;

  TYPE
    Actor* = POINTER TO ActorDesc;
    Message* = POINTER TO MessageDesc;
    ReadyQ* = POINTER TO ReadyQueueDesc;
    MessageQ* = POINTER TO MessageQueueDesc;
    ActorQ* = POINTER TO ActorQueueDesc;
    EventQ* = POINTER TO EventQueueDesc;
    MessagePool* = POINTER TO MessagePoolDesc;

    ActorRun* = PROCEDURE(actor: Actor);
    ActorDesc* = RECORD
      (* kernel data *)
      ticker: INTEGER;
      next: Actor;
      (* kernel data, can be used by user code *)
      id*: INTEGER;
      msg*: Message;
      run*: ActorRun;
      rdyQ*: ReadyQ;
      (* user data, not used by kernel *)
      state*: INTEGER;
      time*: INTEGER
    END;

    MessageDesc* = RECORD
      (* kernel data *)
      next: Message;
      pool: MessagePool;
      (* user data, not used by kernel *)
      data*: INTEGER
    END;

    RunHandler* = PROCEDURE;
    ReadyQueueDesc* = RECORD
      head, tail: Actor;
      intNo: INTEGER;
      cid, id: INTEGER
    END;

    MessageQueueDesc* = RECORD
      head, tail: Message
    END;

    ActorQueueDesc* = RECORD
      head, tail: Actor
    END;

    EventQueueDesc* = RECORD
      msgQ: MessageQ;
      actQ: ActorQ
    END;

    NewMsg* = PROCEDURE(): Message;
    MessagePoolDesc* = RECORD
      head: Message;
      cnt: INTEGER
    END;

    CoreContext = POINTER TO CoreContextDesc;
    CoreContextDesc = RECORD
      loopActQ: ActorQ;
      loopRdyQ: ReadyQ;
      tickActQ: ActorQ
    END;

  VAR
    coreCon: ARRAY NumCores OF CoreContext;
    putToRdyQ: PROCEDURE(rq: ReadyQ; act: Actor);

  (* actors *)

  PROCEDURE* InitAct*(act: Actor; run: ActorRun; id: INTEGER);
  BEGIN
    ASSERT(act # NIL, Errors.PreCond);
    act.id := id;
    act.run := run;
    act.rdyQ := NIL;
    act.msg := NIL;
    act.ticker := 0;
    act.next := NIL;
    act.time := 0;
    act.state := 0
  END InitAct;

  PROCEDURE RunAct*(act: Actor; rdyQ: ReadyQ);
  BEGIN
    act.rdyQ := rdyQ;
    putToRdyQ(rdyQ, act)
    (*
    act.run(act)
    *)
  END RunAct;


  (* messages *)

  PROCEDURE InitMsg*(msg: Message);
  BEGIN
    ASSERT(msg # NIL, Errors.PreCond);
    msg.pool := NIL;
    msg.next := NIL
  END InitMsg;


  (* ready queues *)

  PROCEDURE NewRdyQ*(VAR rq: ReadyQ; cid, id: INTEGER);
  BEGIN
    NEW(rq); ASSERT(rq # NIL, Errors.HeapOverflow);
    rq.head := NIL;
    rq.tail := NIL;
    rq.intNo := 0;
    rq.cid := cid;
    rq.id := id
  END NewRdyQ;

  PROCEDURE InstallRdyQ*(rq: ReadyQ; rh: RunHandler; intNo, prio: INTEGER);
  BEGIN
    rq.intNo := intNo;
    Exceptions.InstallIntHandler(intNo, rh);
    Exceptions.SetIntPrio(intNo, prio);
    Exceptions.EnableInt(intNo)
  END InstallRdyQ;

  PROCEDURE* PutToRdyQ*(rq: ReadyQ; act: Actor);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)

    (* asm
      mrs r6, BASEPRI
      ExcPrioBlock -> msr BASEPRI, r3
    end asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8611H);  (* mrs r6, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)

    IF rq.head = NIL THEN
      rq.head := act
    ELSE
      rq.tail.next := act
    END;
    rq.tail := act;
    act.next := NIL;
    IF rq.intNo # 0 THEN
      SYSTEM.PUT(PPB.STIR, rq.intNo); (* trigger the readyQ's interrupt *)
    END;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END PutToRdyQ;

  PROCEDURE* GetFromRdyQ*(rq: ReadyQ; VAR act: Actor);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    act := rq.head;
    IF rq.head # NIL THEN
      rq.head := rq.head.next
    END;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END GetFromRdyQ;


  (* actor queues *)

  PROCEDURE NewActQ(VAR aq: ActorQ);
  BEGIN
    NEW(aq); ASSERT(aq # NIL, Errors.HeapOverflow);
    aq.head := NIL;
    aq.tail := NIL
  END NewActQ;

  PROCEDURE* PutToActQ*(aq: ActorQ; act: Actor);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    IF aq.head = NIL THEN
      aq.head := act
    ELSE
      aq.tail.next := act
    END;
    aq.tail := act;
    act.next := NIL;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END PutToActQ;

  PROCEDURE* GetFromActQ*(aq: ActorQ; VAR act: Actor);

  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    act := aq.head;
    IF aq.head # NIL THEN
      aq.head := aq.head.next
    END;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END GetFromActQ;

  PROCEDURE* GetTailFromActQ*(aq: ActorQ; VAR tail: Actor);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    tail := aq.tail;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END GetTailFromActQ;


  (* message queues *)

  PROCEDURE NewMsgQ*(VAR mq: MessageQ);
  BEGIN
    NEW(mq); ASSERT(mq # NIL, Errors.PreCond);
    mq.head := NIL;
    mq.tail := NIL
  END NewMsgQ;

  PROCEDURE* PutToMsgQ*(mq: MessageQ; msg: Message);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    IF mq.head = NIL THEN
      mq.head := msg
    ELSE
      mq.tail.next := msg
    END;
    mq.tail := msg;
    msg.next := NIL;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END PutToMsgQ;

  PROCEDURE* GetFromMsgQ*(mq: MessageQ; VAR msg: Message);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    msg := mq.head;
    IF mq.head # NIL THEN
      mq.head := mq.head.next
    END;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END GetFromMsgQ;


  (* event queues *)

  PROCEDURE NewEvQ*(VAR eq: EventQ);
  BEGIN
    NEW(eq); ASSERT(eq # NIL, Errors.HeapOverflow);
    NewActQ(eq.actQ);
    NewMsgQ(eq.msgQ)
  END NewEvQ;


  (* message pools *)

  PROCEDURE newMsg(): Message;
    VAR m: Message;
  BEGIN
    NEW(m); ASSERT(m # NIL, Errors.HeapOverflow);
    RETURN m
  END newMsg;

  PROCEDURE NewMsgPool*(VAR mp: MessagePool; makeMsg: NewMsg; numMsg: INTEGER);
    VAR m: Message; i: INTEGER;
  BEGIN
    ASSERT(numMsg > 0, Errors.PreCond);
    NEW(mp); ASSERT(mp # NIL, Errors.HeapOverflow);
    IF makeMsg = NIL THEN
      makeMsg := newMsg
    END;
    i := 0;
    REPEAT
      m := makeMsg(); (* NIL check in makeMsg() *)
      m.next := mp.head;
      mp.head := m;
      m.pool := mp;
      INC(i)
    UNTIL i = numMsg;
    mp.cnt := numMsg
  END NewMsgPool;


  PROCEDURE* PutToMsgPool*(mp: MessagePool; msg: Message);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    IF msg.pool # NIL THEN
      msg.next := mp.head;
      mp.head := msg;
      INC(mp.cnt)
    END;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END PutToMsgPool;


  PROCEDURE* GetFromMsgPool*(mp: MessagePool; VAR msg: Message);
  BEGIN
    (*
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    *)
    (* ASM
      mrs r7, BASEPRI
      ExcPrioBlock -> MSR BASEPRI, r3
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8711H);  (* mrs r7, BASEPRI *)
    SYSTEM.LDREG(3, ExcPrioBlock);  (* ExcPrioBlock -> r3 *)
    SYSTEM.EMIT(0F3838811H);  (* msr BASEPRI, r3 *)
    (* -asm *)
    msg := mp.head;
    IF msg # NIL THEN
      IF mp.head.next # NIL THEN
        mp.head := mp.head.next
      ELSE
        mp.head := NIL
      END;
      DEC(mp.cnt)
    END;
    (*
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
    *)
    (* ASM
      msr BASEPRI, r7
    END ASM *)
    (* +asm *)
    SYSTEM.EMIT(0F3878811H);  (* msr BASEPRI, r7 *)
    (* -asm *)
  END GetFromMsgPool;


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

  (* kernel *)

  PROCEDURE PutMsg*(evQ: EventQ; msg: Message);
    VAR act: Actor;
  BEGIN
    GetFromActQ(evQ.actQ, act);
    IF act # NIL THEN
      act.msg := msg;
      PutToRdyQ(act.rdyQ, act)
    ELSE
      PutToMsgQ(evQ.msgQ, msg)
    END
  END PutMsg;


  PROCEDURE GetMsg*(evQ: EventQ; act: Actor);
    VAR msg: Message;
  BEGIN
    GetFromMsgQ(evQ.msgQ, msg);
    IF msg # NIL THEN
      act.msg := msg;
      PutToRdyQ(act.rdyQ, act)
    ELSE
      PutToActQ(evQ.actQ, act)
    END
  END GetMsg;


  PROCEDURE PutMsgAwaited*(evQ: EventQ; msg: Message);
    VAR act: Actor;
  BEGIN
    GetFromActQ(evQ.actQ, act);
    IF act # NIL THEN
      act.msg := msg;
      PutToRdyQ(act.rdyQ, act)
    ELSE
      PutToMsgPool(msg.pool, msg)
    END
  END PutMsgAwaited;


  PROCEDURE RunQueue*(rq: ReadyQ);
  (* to be called by run int handler of ready queue or kernel loop *)
    VAR act: Actor; msg: Message;
  BEGIN
    GetFromRdyQ(rq, act);
    WHILE act # NIL DO
      msg := act.msg;
      act.run(act);
      IF msg # NIL THEN
        PutToMsgPool(msg.pool, msg)
      END;
      GetFromRdyQ(rq, act)
    END
  END RunQueue;

  (* tickd and loop *)

  PROCEDURE GetTick*(act: Actor);
  (* get next tick from kernel ticker *)
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    act.msg := NIL;
    PutToActQ(ctx.tickActQ, act)
  END GetTick;


  PROCEDURE Submit*(act: Actor; ticks: INTEGER);
  (* submit to loop *)
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    act.ticker := ticks;
    act.msg := NIL;
    PutToActQ(ctx.loopActQ, act)
  END Submit;


  PROCEDURE tickHandler[0];
    VAR cid: INTEGER; ctx: CoreContext; act: Actor;
  BEGIN
    LED.Toggle({LED.Green});
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    GetFromActQ(ctx.tickActQ, act);
    WHILE act # NIL DO (* run all waiting actors *)
      act.msg := NIL;
      PutToRdyQ(act.rdyQ, act);
      GetFromActQ(ctx.tickActQ, act)
    END
  END tickHandler;


  PROCEDURE loop;
  (* runs in thread mode *)
    VAR cid: INTEGER; act, tail: Actor; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    REPEAT
      (*
      SYSTEM.EMITH(MCU.WFI);
      *)
      (* ASM
        wfi
      END ASM *)
      (* +asm *)
      SYSTEM.EMITH(0BF30H);  (* wfi *)
      (* -asm *)
      IF SysTick.Tick() THEN
        GetFromActQ(ctx.loopActQ, act);
        GetTailFromActQ(ctx.loopActQ, tail);
        WHILE act # NIL DO
          DEC(act.ticker);
          IF act.ticker <= 0 THEN
            act.msg := NIL;
            PutToRdyQ(ctx.loopRdyQ, act)
          ELSE
            PutToActQ(ctx.loopActQ, act)
          END;
          IF act # tail THEN
            GetFromActQ(ctx.loopActQ, act)
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


  PROCEDURE Install*(msPerTick, tickPrio: INTEGER);
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    NEW(coreCon[cid]); ASSERT(coreCon[cid] # NIL, Errors.HeapOverflow);
    ctx := coreCon[cid];
    (* loop *)
    NewActQ(ctx.loopActQ);
    NewRdyQ(ctx.loopRdyQ, cid, 0);
    (* tick *)
    NewActQ(ctx.tickActQ);
    SysTick.Config(msPerTick, tickHandler, tickPrio)
  END Install;

BEGIN
  putToRdyQ := PutToRdyQ
END Kernel.
