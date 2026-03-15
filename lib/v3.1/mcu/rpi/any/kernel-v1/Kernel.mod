MODULE Kernel;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Multi-threading kernel v1
  --
  Based on coroutines
  Multi-core
  Time-driven scheduler
  Cooperative scheduling
  No support for interrupts
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Coroutines, Config, Memory, SysTick, Cores, MCU := MCU2, Errors;

  CONST
    MaxNumThreads* = 16;
    NumCores = Config.NumCoresUsed;

    (* result codes *)
    OK* = 0;
    NoError* = 0;
    Failed* = 1;

    DefaultPrio* = 7;

    (* thread states *)
    StateEnabled = 0;    (* triggered: queued at next trigger event; queued at next scheduler run *)
    StateSuspended = 1;  (* must be (re-) enabled before it can run *)

    (* thread trigger modes *)
    TrigNone* = 0;
    TrigPeriod* = 1;
    TrigDelay* = 2;
    TrigDevice* = 3;


    (* loop *)
    LoopStackSize = 256; (* bytes *)
    LoopCorId = -1;

  TYPE
    (* one thread *)
    PROC* = PROCEDURE; (* Modula-2 vibes *)
    Thread* = POINTER TO ThreadDesc;
    ThreadDesc* = RECORD
      prio, tid: INTEGER;
      state: INTEGER;
      period, ticker: INTEGER;
      delay: INTEGER;
      devAddr: INTEGER;
      devFlagsSet, devFlagsClr: SET;
      cor: Coroutines.Coroutine;
      trigCode: INTEGER;
      next*: Thread
    END;

    (* core-specific data *)
    CoreContext = POINTER TO CoreContextDesc;
    CoreContextDesc = RECORD
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

  PROCEDURE* slotIn(t: Thread; ctx: CoreContext);
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
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    res := Failed;
    IF ctx.numThreads < MaxNumThreads THEN
      tid := ctx.numThreads;
      t := ctx.threads[tid];
      INC(ctx.numThreads);
      t.state := StateSuspended;
      t.prio := DefaultPrio;
      t.period := 0; t.delay := 0; t.devAddr := 0;
      Memory.AllocThreadStack(stackAddr, tid, stackSize);
      IF stackAddr # 0 THEN
        Coroutines.Init(t.cor, stackAddr, stackSize, tid);
        Coroutines.Allocate(t.cor, proc);
        res := NoError
      END
    END
  END Allocate;


  PROCEDURE Reallocate*(t: Thread; proc: PROC; VAR res: INTEGER);
  BEGIN
    res := Failed;
    IF t.state = StateSuspended THEN
      t.prio := DefaultPrio;
      t.period := 0; t.delay := 0;
      t.devAddr := 0;
      Coroutines.Allocate(t.cor, proc);
      res := NoError
    END
  END Reallocate;



  PROCEDURE* Enable*(t: Thread);
  BEGIN
    ASSERT(t # NIL, Errors.PreCond);
    t.state := StateEnabled
  END Enable;


  (* in-process api *)

  PROCEDURE Next*;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END Next;


  PROCEDURE NextQueued*(): Thread;
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    RETURN coreCon[cid].ct
  END NextQueued;


  PROCEDURE SuspendMe*;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    ctx.Ct.state := StateSuspended;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END SuspendMe;


  PROCEDURE DelayMe*(delay: INTEGER);
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    ctx.Ct.delay := delay;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END DelayMe;


  PROCEDURE StartTimeout*(timeout: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    coreCon[cid].Ct.delay := timeout
  END StartTimeout;


  PROCEDURE CancelTimeout*;
  BEGIN
    StartTimeout(0)
  END CancelTimeout;


  PROCEDURE AwaitDeviceFlags*(addr: INTEGER; setFlags, clrFlags: SET);
  (**
    Await any of the 'setFlags' to be set, or any of the 'clrFlags'
    to be set or cleared by the hardware, respectively.
    Any resetting of the flags must be done by the thread.
    Device flag awaiting takes precedence over period.
    Can be combined with a delay for timeout, though.
  **)
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    ctx.Ct.devAddr := addr;
    ctx.Ct.devFlagsSet := setFlags;
    ctx.Ct.devFlagsClr := clrFlags;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END AwaitDeviceFlags;


  PROCEDURE CancelAwaitDeviceFlags*;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    ctx.Ct.devAddr := 0
  END CancelAwaitDeviceFlags;


  PROCEDURE SetPrio*(prio: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    coreCon[cid].Ct.prio := prio
  END SetPrio;


  PROCEDURE SetPeriod*(period, startAfter: INTEGER); (* as number of ticks *)
     VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);
    ctx := coreCon[cid];
    ctx.Ct.period := period * ctx.loopPeriod;
    ctx.Ct.ticker := startAfter * ctx.loopPeriod
  END SetPeriod;


  PROCEDURE Ct*(): Thread;
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    RETURN coreCon[cid].Ct
  END Ct;


  PROCEDURE Tid*(): INTEGER;
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    RETURN coreCon[cid].Ct.tid
  END Tid;


  PROCEDURE Prio*(t: Thread): INTEGER;
    RETURN t.prio
  END Prio;


  PROCEDURE Trigger*(): INTEGER;
    VAR cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    RETURN coreCon[cid].Ct.trigCode
  END Trigger;

  (* scheduler coroutine code *)

  PROCEDURE loopc;
    VAR tid, cid: INTEGER; t, t0: Thread; ctx: CoreContext; devFlags: SET;
  BEGIN
    Cores.GetCoreId(cid);;
    Memory.ResetMainStack; (* for clean stack traces in main stack *)
    ctx := coreCon[cid];
    ctx.Ct := NIL;
    REPEAT
      IF SysTick.Tick() THEN
        tid := 0;
        WHILE tid < ctx.numThreads DO
          t := ctx.threads[tid];
          t0 := NIL;
          IF t.state = StateEnabled THEN
            t.trigCode := TrigNone;
            IF (t.delay <= 0) & (t.period = 0) & (t.devAddr = 0) THEN (* no triggers *)
              t0 := t;
            ELSE
              IF t.period > 0 THEN (* keep the periodic timing on schedule in any case *)
                DEC(t.ticker, ctx.loopPeriod);
                IF t.ticker <= 0 THEN
                  t.ticker := t.ticker + t.period;
                  t.trigCode := TrigPeriod
                  (* don't slot in here *)
                END
              END;
              IF t.delay > 0 THEN (* on delay or timeout *)
                DEC(t.delay, ctx.loopPeriod);
                IF t.delay <= 0 THEN
                  t0 := t;
                  t.trigCode := TrigDelay
                END
              END;
              IF t.devAddr # 0 THEN (* waiting for device flags *)
                SYSTEM.GET(t.devAddr, devFlags);
                IF (t.devFlagsSet * devFlags # {}) OR (devFlags * t.devFlagsClr # t.devFlagsClr) THEN
                  t0 := t;
                  t.devAddr := 0;
                  t.trigCode := TrigDevice
                END
              END;
              IF t.trigCode = TrigPeriod THEN (* see above *)
                IF (t.delay <= 0) & (t.devAddr = 0) THEN (* delay and device flags take precedence *)
                  t0 := t
                END
              END
            END
          END;
          IF t0 # NIL THEN
            slotIn(t0, ctx)
          END;
          INC(tid)
        END
      END;
      (* print ready-queue for debugging *)
      (* cannot be used together with UARTkstr, simply use UARTstr in Main.mod *)
      (*
      IF ctx.ct # NIL THEN
        t := ctx.ct;
        WHILE t # NIL DO
          Out.Int(t.tid, 4); Out.String(" / "); Out.Int(t.prio, 0);
          t := t.next
        END;
        Out.Ln;
      END;
      *)
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
    Cores.GetCoreId(cid);
    (* set PSP to current MSP *)
    SYSTEM.LDREG(R11, SYSTEM.REG(SP));
    SYSTEM.EMIT(MCU.MSR_PSP_R11);
    (* enable PSP use *)
    SYSTEM.LDREG(R11, ORD({MCU.CONTROL_SPSEL}));
    SYSTEM.EMIT(MCU.MSR_CTL_R11);
    SYSTEM.EMIT(MCU.ISB);
    (* from here, we use the PSP *)
    (* still in main stack memory *)
    SysTick.Enable;
    Coroutines.Transfer(coreCon[cid].jump, coreCon[cid].loop)
    (* we'll not return here *)
  END Run;


  (* installation *)

  PROCEDURE Install*(millisecsPerTick: INTEGER);
    VAR i, stkAddr, cid: INTEGER; ctx: CoreContext;
  BEGIN
    Cores.GetCoreId(cid);

    (* allocate and init the core's context *)
    NEW(coreCon[cid]); ASSERT(coreCon[cid] # NIL, Errors.HeapOverflow);
    ctx := coreCon[cid];
    ctx.Ct := NIL; ctx.ct := NIL;
    ctx.queued := {};
    ctx.numThreads := 0;
    ctx.loopPeriod := millisecsPerTick;
    NEW(ctx.jump); ASSERT(ctx.jump # NIL, Errors.HeapOverflow);
    NEW(ctx.loop); ASSERT(ctx.loop # NIL, Errors.HeapOverflow);
    Memory.AllocLoopStack(stkAddr, LoopStackSize); ASSERT(stkAddr # 0, Errors.StorageOverflow);
    Coroutines.Init(ctx.loop, stkAddr, LoopStackSize, LoopCorId);
    Coroutines.Allocate(ctx.loop, loopc);

    (* allocate the data structures for all threads and their coroutines *)
    (* don't yet allocate the stacks *)
    i := 0;
    WHILE i < MaxNumThreads DO
      NEW(ctx.threads[i]); ASSERT(ctx.threads[i] # NIL, Errors.HeapOverflow);
      ctx.threads[i].state := StateSuspended;
      ctx.threads[i].tid := i;
      NEW(ctx.threads[i].cor); ASSERT(ctx.threads[i].cor # NIL, Errors.HeapOverflow);
      INC(i)
    END;
    (* configure sys tick *)
    SysTick.Config(millisecsPerTick)
  END Install;

BEGIN
  ASSERT(MaxNumThreads <= 32, Errors.ProgError);
  Done := SuspendMe; Yield := Next
END Kernel.
