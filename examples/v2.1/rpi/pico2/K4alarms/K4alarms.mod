MODULE K4alarms;
(**
  Oberon RTK Framework v2.1
  --
  Example/test program for kernel-v4: kernel alarms.
  https://oberon-rtk.org/docs/examples/v2/k4tests/
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, MCU := MCU2, T := KernelTypes, Kernel, Actors, ReadyQueues, KernelAlarms, Alarms, Out, Errors;

  CONST
    MillisecsPerTick = 1000;
    RunPrio = MCU.PPB_ExcPrio4;
    RunIntNo = MCU.PPB_SPAREIRQ_IRQ0;
    SysTickPrio = MCU.PPB_ExcPrio2;
    TimerNo = Alarms.T1;
    AlarmNo0 = Alarms.A1;
    AlarmPrio = MCU.PPB_ExcPrio2;

    StateRun = 0;
    StateRunAlarm0 = 1;
    StateRunAlarm1 = 2;

  TYPE
    A0 = POINTER TO A0desc;
    A0desc = RECORD (T.ActorDesc)
      states: ARRAY 4 OF T.ActorRun;
      cnt, alarmSet: INTEGER
    END;

  VAR
    ai0: A0;
    rdyQ: T.ReadyQ;
    al0: KernelAlarms.Alarm;


  PROCEDURE rdyRun[0];
  (* ready queue run int handler *)
  BEGIN
    (*
    Out.String("rdyRun"); Out.Ln;
    *)
    Kernel.RunQueue(rdyQ)
  END rdyRun;

  (* actor states *)

  PROCEDURE aiRunAlarm1(act: T.Actor);
    VAR a: A0; now: INTEGER;
  BEGIN
    KernelAlarms.GetTime(al0, now);
    Out.String("=> aiRunAlarm1"); Out.Int(act.id, 2);
    a := act(A0);
    Out.Int(now - a.alarmSet, 10); Out.Ln;
    a.run := a.states[StateRun];
    Kernel.Submit(act, 2)
  END aiRunAlarm1;


  PROCEDURE aiRunAlarm0(act: T.Actor);
    VAR a: A0; now: INTEGER;
  BEGIN
    KernelAlarms.GetTime(al0, now);
    Out.String("=> aiRunAlarm0"); Out.Int(act.id, 2);
    a := act(A0);
    Out.Int(now - a.alarmSet, 10); Out.Ln;
    a.run := a.states[StateRun];
    Kernel.GetTick(act)
  END aiRunAlarm0;


  PROCEDURE aiRun(act: T.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> aiRun"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    KernelAlarms.GetTime(al0, a.alarmSet);
    IF ODD(a.cnt) THEN
      a.run := a.states[StateRunAlarm1];
      KernelAlarms.Arm(al0, a, a.alarmSet + 3500000)
    ELSE
      a.run := a.states[StateRunAlarm0];
      KernelAlarms.Arm(al0, a, a.alarmSet + 2500000)
    END;
    INC(a.cnt)
  END aiRun;


  PROCEDURE aiInit(act: T.Actor);
    VAR a: A0;
  BEGIN
    Out.String("=> init"); Out.Int(act.id, 2); Out.Ln;
    a := act(A0);
    a.cnt := 0;
    a.states[StateRun] := aiRun;
    a.states[StateRunAlarm0] := aiRunAlarm0;
    a.states[StateRunAlarm1] := aiRunAlarm1;
    a.run := a.states[StateRun];
    Kernel.GetTick(act)
  END aiInit;


  PROCEDURE run;
  BEGIN
    Out.String("begin init"); Out.Ln;
    Kernel.Install(MillisecsPerTick, SysTickPrio);
    NEW(rdyQ); ASSERT(rdyQ # NIL, Errors.HeapOverflow);
    ReadyQueues.Install(rdyQ, rdyRun, RunIntNo, RunPrio, 0, 0);
    NEW(al0); ASSERT(al0 # NIL, Errors.HeapOverflow);
    KernelAlarms.Init(al0, TimerNo, AlarmNo0, AlarmPrio);
    NEW(ai0); ASSERT(ai0 # NIL, Errors.HeapOverflow);
    Actors.Init(ai0, aiInit, 0);
    Actors.Run(ai0, rdyQ);
    Out.String("end init => start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END K4alarms.
