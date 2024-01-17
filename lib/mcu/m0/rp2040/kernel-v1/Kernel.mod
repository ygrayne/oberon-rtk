(**
  Oberon RTK Framework
  Multi-threading kernel, first iteration (Kernel v1)
  --
  Based on coroutines
  Multi-core
  Time-driven scheduler
  Cooperative scheduling
  No support for interrupts yet
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

MODULE Kernel;

  IMPORT SYSTEM, Coroutines, Config, Memory, SysTick, MCU := MCU2, Error;

  CONST
    MaxNumThreads* = Config.MaxNumThreads;
    NumCores = Config.NumCores;

    (* result codes *)
    OK* = 0;
    Failed* = 1;

    DefaultPrio* = 1;

    (* thread states *)
    StateEnabled = 0;    (* triggered: queued at next trigger event; queued at next scheduler run *)
    StateSuspended = 1;  (* must be (re-) enabled before it can run *)

    (* thread trigger causes *)
    TrigNone* = 0;
    TrigPeriod* = 1;
    TrigDelay* = 2;
    TrigDevice* = 3;

    (* loop *)
    LoopStackSize = 1024; (* bytes *)
    LoopCorId = -1;


  TYPE
    (* one thread *)
    PROC* = PROCEDURE; (* Modula-2 vibes *)
    Thread* = POINTER TO ThreadDesc;
    ThreadDesc* = RECORD
      prio*, tid: INTEGER;
      state: INTEGER;
      period, ticker: INTEGER;
      delay: INTEGER;
      deviceAddr: INTEGER;
      deviceFlags: SET;
      cor: Coroutines.Coroutine;
      retCode: INTEGER;
      next: Thread
    END;

    (* core-specific data *)
    CoreContext* = POINTER TO CoreContextDesc;
    CoreContextDesc* = RECORD
      threads: ARRAY MaxNumThreads OF Thread;
      Ct, ct: Thread;
      queued: SET;
      numThreads: INTEGER;
      loopPeriod: INTEGER;
      loop, jump: Coroutines.Coroutine
    END;

  VAR
    coreCon: ARRAY NumCores OF CoreContext;

    Done*: PROCEDURE; (* alias for SuspendMe *)
    Yield*: PROCEDURE; (* alias for Next *)


  (* ready queue *)

  PROCEDURE slotIn(t: Thread; ctx: CoreContext);
  (* put into ready queue, prio sorted *)
    VAR t0, t1: Thread;
  BEGIN
    IF ~(t.tid IN ctx.queued) THEN
      t0 := ctx.ct; t1 := t0;
      WHILE (t0 # NIL) & (t0.prio <= t.prio) DO
        t1 := t0; t0 := t0.next
      END;
      IF t1 = t0 THEN ctx.ct := t ELSE t1.next := t END;
      t.next := t0;
      INCL(ctx.queued, t.tid)
    END
  END slotIn;

  (* manage threads *)

  PROCEDURE Allocate*(proc: PROC; stackSize: INTEGER; VAR t: Thread; VAR tid, res: INTEGER);
    VAR cid, stackAddr: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    res := OK;
    IF ctx.numThreads < MaxNumThreads THEN
      tid := ctx.numThreads;
      t := ctx.threads[tid];
      t.tid := tid;
      INC(ctx.numThreads);
      t.state := StateSuspended;
      t.prio := DefaultPrio;
      t.period := 0; t.delay := 0;
      t.deviceAddr := 0;
      Memory.AllocThreadStack(stackAddr, tid, stackSize);
      IF stackAddr # 0 THEN
        Coroutines.Init(t.cor, stackAddr, stackSize, tid);
        Coroutines.Allocate(t.cor, proc)
      ELSE
        res := Failed
      END
    ELSE
      res := Failed
    END
  END Allocate;


  PROCEDURE Reallocate*(t: Thread; proc: PROC; VAR res: INTEGER);
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    res := OK;
    IF t.state = StateSuspended THEN
      SYSTEM.GET(MCU.SIO_CPUID, cid);
      ctx := coreCon[cid];
      t.prio := 1;
      t.period := 0; t.delay := 0;
      t.deviceAddr := 0;
      Coroutines. Allocate(t.cor, proc)
    ELSE
      res := Failed
    END
  END Reallocate;


  PROCEDURE Enable*(t: Thread);
  BEGIN
    ASSERT(t # NIL, Error.PreCond);
    t.state := StateEnabled
  END Enable;


  PROCEDURE SetPrio*(t: Thread; prio: INTEGER);
  BEGIN
    t.prio := prio
  END SetPrio;


  PROCEDURE SetPeriod*(t: Thread; period, startAfter: INTEGER);
  BEGIN
    t.period := period;
    t.ticker := startAfter
  END SetPeriod;

  (* in-process api *)

  PROCEDURE Next*;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END Next;


  PROCEDURE NextQueued*(): Thread;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    RETURN coreCon[cid].ct
  END NextQueued;


  PROCEDURE DelayMe*(delay: INTEGER);
  (* delay takes precedence over period *)
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    ASSERT(delay > 0, Error.PreCond);
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.delay := delay;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END DelayMe;


  PROCEDURE SuspendMe*;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.state := StateSuspended;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END SuspendMe;


  PROCEDURE AwaitDeviceSet*(addr: INTEGER; flags: SET);
  (* await any of the 'flags' at 'addr' to be set by hardware *)
  (* any resetting of the flags must be done by the thread *)
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.deviceAddr := addr;
    ctx.Ct.deviceFlags := flags;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END AwaitDeviceSet;


  PROCEDURE Trigger*(): INTEGER;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    RETURN coreCon[cid].Ct.retCode
  END Trigger;


  PROCEDURE Ct*(): Thread;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    RETURN coreCon[cid].Ct
  END Ct;


  PROCEDURE Tid*(): INTEGER;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    RETURN coreCon[cid].Ct.tid
  END Tid;


  PROCEDURE Prio*(t: Thread): INTEGER;
    RETURN t.prio
  END Prio;

  (* scheduler coroutine code *)

  PROCEDURE loopc;
    VAR tid, cid: INTEGER; t: Thread; ctx: CoreContext; deviceFlags: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct := NIL;
    REPEAT
      IF SysTick.Tick() THEN
        tid := 0;
        WHILE tid < ctx.numThreads DO
          t := ctx.threads[tid];
          IF t.state = StateEnabled THEN
            t.retCode := TrigNone;
            IF (t.delay <= 0) & (t.period = 0) & (t.deviceAddr = 0) THEN (* no triggers *)
              slotIn(t, ctx)
            ELSE
              IF t.delay > 0 THEN (* thread on delay *)
                DEC(t.delay, ctx.loopPeriod);
                IF t.delay <= 0 THEN
                  slotIn(t, ctx);
                  t.retCode := TrigDelay
                END
              END;
              IF t.deviceAddr > 0 THEN (* waiting for device flags *)
                SYSTEM.GET(t.deviceAddr, deviceFlags);
                IF t.deviceFlags * deviceFlags # {} THEN
                  slotIn(t, ctx);
                  t.deviceAddr := 0;
                  t.retCode := TrigDevice
                END
              END;
              IF t.period > 0 THEN (* thread periodically triggered *)
                DEC(t.ticker, ctx.loopPeriod); (* keep period timing in any case *)
                IF t.ticker <= 0 THEN
                  t.ticker := t.ticker + t.period;
                  IF t.retCode = TrigNone THEN
                    slotIn(t, ctx);
                    t.retCode := TrigPeriod
                  END
                END
              END
            END
          END;
          INC(tid)
        END;
      END;
      WHILE ctx.ct # NIL DO
        t := ctx.ct;
        ctx.ct := ctx.ct.next; EXCL(ctx.queued, t.tid); (* slot out ctx.ct *)
        ctx.Ct := t;
        Coroutines.Transfer(ctx.loop, t.cor);
        ctx.Ct := NIL
      END;
    UNTIL FALSE
  END loopc;


  (* scheduler start *)
  (* set use of PSP *)

  PROCEDURE Run*;
    CONST SP = 13; R11 = 11;
    VAR cid: INTEGER;
  BEGIN
    (* MSP is used here *)
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    (* set PSP to current MSP *)
    SYSTEM.LDREG(R11, SYSTEM.REG(SP));
    SYSTEM.EMIT(MCU.MSR_R11_PSP);
    (* enable PSP use *)
    SYSTEM.LDREG(R11, ORD({MCU.CONTROL_SPSEL}));
    SYSTEM.EMIT(MCU.MSR_R11_CTL);
    SYSTEM.EMIT(MCU.ISB);
    (* from here, we use the PSP *)
    SysTick.Enable;
    Coroutines.Transfer(coreCon[cid].jump, coreCon[cid].loop)
    (* we'll not return here *)
  END Run;

  (* installation *)

  PROCEDURE Install*(millisecsPerTick: INTEGER);
    VAR i, stkAddr: INTEGER; cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct := NIL; ctx.ct := NIL;
    ctx.queued := {};
    ctx.numThreads := 0;
    ctx.loopPeriod := millisecsPerTick;
    NEW(ctx.jump); ASSERT(ctx.jump # NIL, Error.HeapOverflow);
    NEW(ctx.loop); ASSERT(ctx.loop # NIL, Error.HeapOverflow);
    Memory.AllocLoopStack(stkAddr, cid, LoopStackSize); ASSERT(stkAddr # 0, Error.StorageOverflow);
    Coroutines.Init(ctx.loop, stkAddr, LoopStackSize, LoopCorId);
    Coroutines.Allocate(ctx.loop, loopc);

    (* allocate the data structures for all threads and their coroutines *)
    (* don't yet allocate the stacks *)
    i := 0;
    WHILE i < MaxNumThreads DO
      NEW(ctx.threads[i]); ASSERT(ctx.threads[i] # NIL, Error.HeapOverflow);
      ctx.threads[i].state := StateSuspended;
      ctx.threads[i].tid := 0;
      NEW(ctx.threads[i].cor); ASSERT(ctx.threads[i].cor # NIL, Error.HeapOverflow);
      INC(i)
    END;
    (* start sys tick *)
    SysTick.Init(millisecsPerTick)
  END Install;

  (* module init *)

  PROCEDURE init;
  (* allocate core contexts *)
  (* set proc aliases *)
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < NumCores DO
      NEW(coreCon[i]); ASSERT(coreCon[i] # NIL, Error.HeapOverflow);
      INC(i)
    END;
    Done := SuspendMe; Yield := Next
  END init;

BEGIN
  ASSERT(MaxNumThreads <= 32, Error.Config);
  init
END Kernel.
