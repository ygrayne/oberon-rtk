MODULE K4alarms;
(**
  Oberon RTK Framework v3.0
  --
  Example/test program for kernel-v4: kernel alarms.
  https://oberon-rtk.org/docs/examples/v2/k4tests/
  --
  MCU: RP2350, RP2040
  Board: Pico2, Pico
  --
  Kernel-v4
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, MCU := MCU2, Kernel, KernelAlarms, Alarms, Out, Errors;

  CONST
    MillisecsPerTick = 1000;
    RunPrio = MCU.ExcPrio4;
    RunIntNo = MCU.IRQ_SW_0;
    SysTickPrio = MCU.ExcPrio2;
    TimerNo = Alarms.T0;
    AlarmNo0 = Alarms.A1;
    AlarmPrio = MCU.ExcPrio2;

    StateRun = 0;
    StateRunAlarm0 = 1;
    StateRunAlarm1 = 2;

  TYPE
    A0 = POINTER TO A0desc;
    A0desc = RECORD (Kernel.ActorDesc)
      states: ARRAY 4 OF Kernel.ActorRun;
      cnt, alarmSet: INTEGER
    END;

  VAR
    ai0: A0;
    rdyQ: Kernel.ReadyQ;
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

  PROCEDURE aiRunAlarm1(act: Kernel.Actor);
    VAR a: A0; now: INTEGER;
  BEGIN
    KernelAlarms.GetTime(al0, now);
    Out.String("=> aiRunAlarm1 tick"); Out.Int(act.id, 2);
    a := act(A0);
    Out.Int(now - a.alarmSet, 10); Out.Ln;
    a.run := a.states[StateRun];
    Kernel.Submit(act, 2)
  END aiRunAlarm1;


  PROCEDURE aiRunAlarm0(act: Kernel.Actor);
    VAR a: A0; now: INTEGER;
  BEGIN
    KernelAlarms.GetTime(al0, now);
    Out.String("=> aiRunAlarm0 bg"); Out.Int(act.id, 2);
    a := act(A0);
    Out.Int(now - a.alarmSet, 10); Out.Ln;
    a.run := a.states[StateRun];
    Kernel.GetTick(act)
  END aiRunAlarm0;


  PROCEDURE aiRun(act: Kernel.Actor);
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


  PROCEDURE aiInit(act: Kernel.Actor);
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
    Kernel.NewRdyQ(rdyQ, 0, 0);
    Kernel.InstallRdyQ(rdyQ, rdyRun, RunIntNo, RunPrio);

    NEW(al0); ASSERT(al0 # NIL, Errors.HeapOverflow);
    KernelAlarms.Init(al0, TimerNo, AlarmNo0, AlarmPrio);

    NEW(ai0); ASSERT(ai0 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ai0, aiInit, 0);
    Kernel.RunAct(ai0, rdyQ);
    Out.String("end init => start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END K4alarms.
