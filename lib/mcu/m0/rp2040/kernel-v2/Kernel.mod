MODULE Kernel;
(**
  Oberon RTK Framework
  Multi-threading kernel, second variant (kernel-v2)
  Early prototype!
  --
  Based on coroutines
  Multi-core
  Hybrid scheduler
  Cooperative scheduling
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Coroutines, Config, Memory, SysTick, MCU := MCU2, Errors, Exceptions;

  CONST
    MaxNumThreads* = Config.MaxNumThreads;
    NumCores = Config.NumCores;

    (* result codes *)
    OK* = 0;
    NoError* = 0;
    Failed* = 1;

    DefaultPrio* = 7;

    (* thread states *)
    StateEnabled = 0;    (* triggered: queued at next trigger event; queued at next scheduler run *)
    StateSuspended = 1;  (* must be (re-) enabled before it can run *)

    (* thread trigger causes *)
    TrigNone* = 0;
    TrigPeriod* = 1;
    TrigDelay* = 2;
    TrigDevice* = 3;

    (* loop *)
    LoopStackSize = 256; (* bytes *)
    LoopCorId = -1;

    (* slow loop down for debugging *)
    SloMo = 1;

    (* kernel traps *)
    SlotInIntNo = 31;
    SlotOutIntNo = 30; (* implies higher prio than int no 31, when both are set to same prio *)

    SlotInIntPrio = 1;
    SlotOutIntPrio = 1;

    (* loop/scanner *)
    (* sys tick exception handler *)
    LoopIntPrio = 2;


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
      retCode: INTEGER;
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


  (* ready queue mgmt *)
  (* via interrupt traps *)

  PROCEDURE slotIn(t: Thread; ctx: CoreContext);
    CONST R2 = 2; R3 = 3;
  BEGIN
    IF ~(t.tid IN ctx.queued) THEN
      SYSTEM.LDREG(R2, t);
      SYSTEM.LDREG(R3, ctx);
      SYSTEM.PUT(MCU.NVIC_ISPR, {SlotInIntNo})
    END
  END slotIn;


  PROCEDURE slotInHandler[0];
    CONST R2 = 2; R3 = 3;
    VAR t, t0, t1: Thread; ctx: CoreContext;
  BEGIN
    (*
    need to get PSP for this to work
    SYSTEM.EMIT(MCU.MRS_R11_PSP);
    sp := SYSTEM.REG(11)
    SYSTEM.GET(sp + R2offset, t);
    SYSTEM.GET(sp + R3offset, ctx);
    *)
    t := SYSTEM.VAL(Thread, SYSTEM.REG(R2));
    ctx := SYSTEM.VAL(CoreContext, SYSTEM.REG(R3));
    t0 := ctx.ct; t1 := t0;
    WHILE (t0 # NIL) & (t0.prio <= t.prio) DO
      t1 := t0; t0 := t0.next
    END;
    IF t1 = t0 THEN ctx.ct := t ELSE t1.next := t END;
    t.next := t0;
    INCL(ctx.queued, t.tid)
  END slotInHandler;


  PROCEDURE slotOut(ctx: CoreContext);
    CONST R3 = 3;
  BEGIN
    SYSTEM.LDREG(R3, ctx);
    SYSTEM.PUT(MCU.NVIC_ISPR, {SlotOutIntNo})
  END slotOut;


  PROCEDURE slotOutHandler[0];
    CONST R3 = 3;
    VAR ctx: CoreContext;
  BEGIN
    ctx := SYSTEM.VAL(CoreContext, SYSTEM.REG(R3));
    ctx.Ct := ctx.ct;
    ctx.ct := ctx.ct.next;
    EXCL(ctx.queued, ctx.Ct.tid)
  END slotOutHandler;


  (* manage threads *)

  PROCEDURE Allocate*(proc: PROC; stackSize: INTEGER; VAR t: Thread; VAR tid, res: INTEGER);
    VAR cid, stackAddr: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
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
    IF t.state = StateSuspended THEN (* todo: protect threads suspended on signals *)
      t.prio := 1;
      t.period := 0; t.delay := 0;
      t.devAddr := 0;
      Coroutines. Allocate(t.cor, proc);
      res := NoError
    END
  END Reallocate;


  PROCEDURE Enable*(t: Thread);
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    t.state := StateEnabled;
    IF (t.delay <= 0) & (t.period = 0) & (t.devAddr = 0) THEN (* no triggers *)
      t.retCode := TrigNone;
      slotIn(t, ctx)
    END
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
    VAR cid: INTEGER; ctx: CoreContext; t: Thread;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    t := ctx.Ct;
    IF (t.delay <= 0) & (t.period = 0) & (t.devAddr = 0) THEN (* no triggers *)
      t.retCode := TrigNone;
      slotIn(t, ctx)
    END;
    Coroutines.Transfer(t.cor, ctx.loop)
  END Next;


  PROCEDURE NextQueued*(): Thread;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    RETURN coreCon[cid].ct
  END NextQueued;


  PROCEDURE SuspendMe*;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.state := StateSuspended;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END SuspendMe;


  PROCEDURE DelayMe*(delay: INTEGER);
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.delay := delay;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END DelayMe;


  PROCEDURE StartTimeout*(timeout: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
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
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.devAddr := addr;
    ctx.Ct.devFlagsSet := setFlags;
    ctx.Ct.devFlagsClr := clrFlags;
    Coroutines.Transfer(ctx.Ct.cor, ctx.loop)
  END AwaitDeviceFlags;


  PROCEDURE CancelAwaitDeviceFlags*;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.devAddr := 0
  END CancelAwaitDeviceFlags;


  PROCEDURE Trigger*(): INTEGER;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    RETURN coreCon[cid].Ct.retCode
  END Trigger;


  PROCEDURE ChangePrio*(prio: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    coreCon[cid].Ct.prio := prio
  END ChangePrio;


  PROCEDURE ChangePeriod*(period, startAfter: INTEGER);
     VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ctx.Ct.period := period;
    ctx.Ct.ticker := startAfter
  END ChangePeriod;


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

  (* loop executive coroutine code *)

  PROCEDURE loopc;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Memory.ResetMainStack(cid, 128); (* for clean stack traces in main stack *)
    ctx := coreCon[cid];
    ctx.Ct := NIL;
    REPEAT
      WHILE ctx.ct # NIL DO
        (*
        t := ctx.ct;
        WHILE t # NIL DO
          Out.Int(t.tid, 4); Out.String(" / "); Out.Int(t.prio, 0);
          t := t.next
        END;
        Out.Ln;
        *)
        slotOut(ctx);
        Coroutines.Transfer(ctx.loop, ctx.Ct.cor);
        ctx.Ct := NIL
      END;
    UNTIL FALSE
  END loopc;

  (* loop sys tick int handler *)

  PROCEDURE looph[0];
    VAR tid, cid: INTEGER; t, t0: Thread; ctx: CoreContext; devFlags: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    tid := 0;
    WHILE tid < ctx.numThreads DO
      t := ctx.threads[tid];
      t0 := NIL;
      IF t.state = StateEnabled THEN
        IF t # ctx.Ct THEN (* allow Ct to mutate its data via in-thread API *)
          t.retCode := TrigNone;
          IF t.period > 0 THEN (* keep the periodic timing on schedule in any case *)
            DEC(t.ticker, ctx.loopPeriod);
            IF t.ticker <= 0 THEN
              t.ticker := t.ticker + t.period;
              t.retCode := TrigPeriod
              (* don't slot in here *)
            END
          END;
          IF t.delay > 0 THEN (* on delay or timeout *)
            DEC(t.delay, ctx.loopPeriod);
            IF t.delay <= 0 THEN
              t0 := t;
              t.retCode := TrigDelay
            END
          END;
          IF t.devAddr # 0 THEN (* waiting for device flags *)
            SYSTEM.GET(t.devAddr, devFlags);
            IF (t.devFlagsSet * devFlags # {}) OR (devFlags * t.devFlagsClr # t.devFlagsClr) THEN
              t0 := t;
              t.devAddr := 0;
              t.retCode := TrigDevice
            END
          END;
          IF t.retCode = TrigPeriod THEN (* see above *)
            IF (t.delay <= 0) & (t.devAddr = 0) THEN (* delay and device flags take precedence *)
              t0 := t
            END
          END
        END;
        IF t0 # NIL THEN
          slotIn(t, ctx)
        END
      END;
      INC(tid)
    END
  END looph;


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
    (* from here, we use the PSP, but are still in main stack memory space *)
    SysTick.Enable;
    Coroutines.Transfer(coreCon[cid].jump, coreCon[cid].loop)
    (* we'll not return here *)
  END Run;

  (* installation *)

  PROCEDURE Install*(millisecsPerTick: INTEGER);
    VAR i, stkAddr: INTEGER; cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);

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

    Exceptions.InstallIntHandler(SlotInIntNo, slotInHandler);
    Exceptions.SetIntPrio(SlotInIntNo, SlotInIntPrio);
    Exceptions.EnableInt({SlotInIntNo});

    Exceptions.InstallIntHandler(SlotOutIntNo, slotOutHandler);
    Exceptions.SetIntPrio(SlotOutIntNo, SlotOutIntPrio);
    Exceptions.EnableInt({SlotOutIntNo});

    (* init and install sys tick *)
    SysTick.Init(millisecsPerTick * SloMo);
    SysTick.InstallHandler(looph);
    SysTick.SetPrio(LoopIntPrio);
  END Install;

BEGIN
  ASSERT(MaxNumThreads <= 32, Errors.ProgError);
  Done := SuspendMe; Yield := Next
END Kernel.
