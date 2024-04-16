MODULE Tasks;
(**
  Oberon RTK Framework
  Task scheduling and execution.
  --
  Test version, only core 0 is implemented, includes test and evaluation code.
  See https://oberon-rtk.org/examples/taskeval/
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors, Exceptions, Timers, Out, MemoryExt;

  CONST
    NumCores = MCU.NumCores;
    RunModeInt* = 0;
    RunModeDirect* = 1;

    (* scheduling trap *)
    SlotInIntNo = 26;
    SlotInIntPrio = 1;

    (* alarms *)
    (* alarm numbers on the timer *)
    CoreZeroAlarmNo = 0;
    CoreOneAlarmNo = 1;
    (* interrupts on the NVIC, must be consistent with alarm numbers *)
    CoreZeroAlarmIntNo = Exceptions.TIMER_IRQ_0;  (* alarm 0 *)
    CoreOneAlarmIntNo = Exceptions.TIMER_IRQ_1;   (* alarm 1 *)
    AlarmIntPrio = 2;

    (* test control *)
    AlarmInRam = FALSE; (* install alarm handling in SRAM *)
    PutInRam = FALSE; (* install scheduling in SRAM *)
    ForceCache = FALSE; (* force cache loading *)

  TYPE
    Task* = POINTER TO TaskDesc;
    TaskDesc* = RECORD
      id*: INTEGER;
      p: PROCEDURE;
      time*: INTEGER;
      runMode*: INTEGER;
      runTime*: INTEGER;
      next: Task;
      (* test *)
      scheduleTime*: INTEGER;
      queuedTime*: INTEGER;
      intTime*: INTEGER
    END;

    CoreContext = POINTER TO CoreContextDesc;
    CoreContextDesc = RECORD
      nt: Task;
      alarmNo: INTEGER;
      alarmIntNo: INTEGER;
      alarmAddr: INTEGER;
    END;

    Handler = PROCEDURE;
    PutProc = PROCEDURE(t: Task; time: INTEGER);
    NextProc = PROCEDURE(VAR t: Task; alarmAddr: INTEGER);

  VAR
    coreCon: ARRAY NumCores OF CoreContext;
    Put*: PutProc;
    next: NextProc;
    Ct*: Task; (* test *)
    printQ: BOOLEAN; (* test *)


  PROCEDURE Init*(t: Task; p: PROCEDURE; id: INTEGER);
  BEGIN
    ASSERT(t # NIL, Errors.PreCond);
    t.id := id;
    t.p := p
  END Init;


  PROCEDURE put(t: Task; time: INTEGER);
  (* put a tasks on the run queue *)
    CONST Rtask = 2; Rctx = 3;
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    t.time := time;
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    SYSTEM.LDREG(Rtask, t);
    SYSTEM.LDREG(Rctx, ctx);
    SYSTEM.PUT(MCU.NVIC_ISPR, {SlotInIntNo})
  END put;


  PROCEDURE next0(VAR t: Task; alarmAddr: INTEGER);
    CONST Margin = 1;
    VAR armed: BOOLEAN; now: INTEGER;
  BEGIN
    armed := FALSE;
    WHILE (t # NIL) & ~armed DO
      SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
      IF t.time - now > Margin THEN (* if t.time is after (now + Margin) *)
        armed := TRUE;
        SYSTEM.PUT(alarmAddr, t.time)
      ELSE
        Ct := t; (* test *)
        t.p;
        t.runTime := now;
        t.runMode := RunModeDirect;
        t := t.next
      END
    END
  END next0;


  PROCEDURE slotInHandler[0];
    CONST Rtask = 2; Rctx = 3; RtaskOffset = 8; RctxOffset = 12; LR = 14; SP = 13;
    VAR regAddr: INTEGER; t, t0, t1: Task; ctx: CoreContext;
  BEGIN
    (*
    (* read parameters from registers *)
    t := SYSTEM.VAL(Task, SYSTEM.REG(Rtask));
    ctx := SYSTEM.VAL(CoreContext, SYSTEM.REG(Rctx));
    *)
    (* read parameters from stack *)
    IF 2 IN BITS(SYSTEM.REG(LR)) THEN
      SYSTEM.EMIT(MCU.MRS_R11_PSP);
      regAddr := SYSTEM.REG(11)
    ELSE
      regAddr := SYSTEM.REG(SP) + 40;
    END;
    SYSTEM.GET(regAddr + RtaskOffset, t);
    SYSTEM.GET(regAddr + RctxOffset, ctx);

    (* insert in run-queue *)
    t0 := ctx.nt; t1 := t0;
    WHILE (t0 # NIL) & (t.time - t0.time >= 0) DO (* while t.time is after t0.time *)
      t1 := t0; t0 := t0.next
    END;
    IF t1 = t0 THEN ctx.nt := t ELSE t1.next := t END;
    t.next := t0;

    (* test *)
    IF printQ THEN
      Out.Ln;
      t0 := ctx.nt;
      WHILE t0 # NIL DO
        Out.Int(t0.id, 4); Out.Hex(t0.time, 12); Out.Ln;
        t0 := t0.next
      END
    END;
    (* test end *)

    (* if inserted task is at the head of the queue *)
    IF t = ctx.nt THEN
      next(t, ctx.alarmAddr);
      ctx.nt := t
    END
  END slotInHandler;


  PROCEDURE alarmHandler[0];
    VAR cid, now: INTEGER; ctx: CoreContext; t: Task; en: SET;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now); (* test *)
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    en := {ctx.alarmNo}; (* compiler issue workaround v9.1 *)
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, en); (* Timers.DeassertAlarmInt(ctx.alarmNo) *)
    t := ctx.nt;
    t.runMode := RunModeInt;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, t.runTime);
    t.intTime := now;  (* test *)
    Ct := t; (* test *)
    t.p;
    t := t.next;
    next(t, ctx.alarmAddr);
    ctx.nt := t
  END alarmHandler;


  PROCEDURE Install*(printQueue: BOOLEAN);
    VAR
      cid, slotInHandlerAddr, alarmHandlerAddr, putAddr, nextAddr: INTEGER;
      ctx: CoreContext;
      slotInHandlerProc, alarmHandlerProc: PROCEDURE;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    NEW(coreCon[cid]);
    ctx := coreCon[cid];
    ctx.nt := NIL;
    printQ := printQueue;

    (* trap handlers *)
    IF PutInRam THEN
      (* install putting tasks on run queue in SRAM *)
      MemoryExt.CopyProc(SYSTEM.ADR(slotInHandler), slotInHandlerAddr);
      ASSERT(slotInHandlerAddr # 0, Errors.StorageError);
      slotInHandlerProc := SYSTEM.VAL(Handler, slotInHandlerAddr);
      Exceptions.InstallIntHandler(SlotInIntNo, slotInHandlerProc);

      MemoryExt.CopyProc(SYSTEM.ADR(put), putAddr);
      ASSERT(putAddr # 0, Errors.StorageError);
      Put := SYSTEM.VAL(PutProc, putAddr);

      (* install next in SRAM *)
      MemoryExt.CopyProc(SYSTEM.ADR(next0), nextAddr);
      ASSERT(nextAddr # 0, Errors.StorageError);
      next := SYSTEM.VAL(NextProc, nextAddr)
    ELSE
      IF ForceCache THEN
        MemoryExt.CacheProc(SYSTEM.ADR(slotInHandler));
        MemoryExt.CacheProc(SYSTEM.ADR(put));
        MemoryExt.CacheProc(SYSTEM.ADR(next0))
      END;
      Exceptions.InstallIntHandler(SlotInIntNo, slotInHandler);
      Put := put;
      next := next0
    END;

    Exceptions.SetIntPrio(SlotInIntNo, SlotInIntPrio);
    Exceptions.ClearPendingInt({SlotInIntNo});
    Exceptions.EnableInt({SlotInIntNo});

    (* alarm handlers *)
    IF cid = 0 THEN
      ctx.alarmNo := CoreZeroAlarmNo;
      ctx.alarmIntNo := CoreZeroAlarmIntNo;
      ctx.alarmAddr := MCU.TIMER_ALARM + (CoreZeroAlarmNo * MCU.TIMER_ALARM_Offset);

      IF AlarmInRam THEN
        (* install alarm handler in SRAM *)
        MemoryExt.CopyProc(SYSTEM.ADR(alarmHandler), alarmHandlerAddr);
        ASSERT(alarmHandlerAddr # 0, Errors.StorageError);
        alarmHandlerProc := SYSTEM.VAL(Handler, alarmHandlerAddr);
        Timers.InstallAlarmIntHandler(CoreZeroAlarmNo, alarmHandlerProc);
        (* install next in SRAM *)
        IF ~PutInRam THEN
          MemoryExt.CopyProc(SYSTEM.ADR(next0), nextAddr);
          ASSERT(nextAddr # 0, Errors.StorageError);
          next := SYSTEM.VAL(NextProc, nextAddr)
        END
      ELSE
        IF ForceCache THEN
          MemoryExt.CacheProc(SYSTEM.ADR(alarmHandler));
          MemoryExt.CacheProc(SYSTEM.ADR(next0))
        END;
        Timers.InstallAlarmIntHandler(CoreZeroAlarmNo, alarmHandler);
        next := next0
      END;

      Timers.SetAlarmIntPrio(CoreZeroAlarmNo, AlarmIntPrio);
      Timers.EnableAlarmInt(CoreZeroAlarmNo);
      Timers.DeassertAlarmInt(CoreZeroAlarmNo);
      Exceptions.ClearPendingInt({CoreZeroAlarmIntNo});
      Exceptions.EnableInt({CoreZeroAlarmIntNo})
    ELSE
      (* core 1 not implemented in this test version *)
      ASSERT(FALSE)
    END
  END Install;

END Tasks.

