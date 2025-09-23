MODULE KernelAlarms;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  Alarms for kernel actors for microseconds timing.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Kernel, Alarms, Errors;


  TYPE
    Alarm* = POINTER TO AlarmDesc;
    AlarmDesc* = RECORD
      evQ: Kernel.EventQ;
      msg: Kernel.Message;
      alarm*: Alarms.Device
    END;

  VAR
    alarms: ARRAY MCU.NumTimers OF ARRAY MCU.NumAlarms OF Alarm;


  PROCEDURE handler[0];
    VAR intNo, tmNo, alNo: INTEGER; al: Alarm;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R11_IPSR);
    intNo := SYSTEM.REG(11) - MCU.PPB_IRQ_BASE;
    tmNo := intNo DIV 4;
    alNo := intNo MOD 4;
    al := alarms[tmNo, alNo];
    Alarms.DeassertInt(al.alarm);
    Kernel.PutMsg(al.evQ, al.msg)
  END handler;


  PROCEDURE Arm*(al: Alarm; act: Kernel.Actor; time: INTEGER);
  BEGIN
    ASSERT(~Alarms.Armed(al.alarm), Errors.ProgError);
    Alarms.Arm(al.alarm, handler, time);
    Kernel.GetMsg(al.evQ, act)
  END Arm;


  PROCEDURE Rearm*(al: Alarm; act: Kernel.Actor; delay: INTEGER);
  BEGIN
    ASSERT(~Alarms.Armed(al.alarm), Errors.ProgError);
    Alarms.Rearm(al.alarm, handler, delay);
    Kernel.GetMsg(al.evQ, act)
  END Rearm;


  PROCEDURE GetTime*(al: Alarm; VAR timeL: INTEGER);
  BEGIN
    SYSTEM.GET(al.alarm.TIMERAWL, timeL)
  END GetTime;


  PROCEDURE Init*(al: Alarm; timerNo, alarmNo, prio: INTEGER);
  BEGIN
    ASSERT(al # NIL, Errors.PreCond);
    Kernel.NewEvQ(al.evQ);
    NEW(al.msg); ASSERT(al.msg # NIL, Errors.HeapOverflow);
    Kernel.InitMsg(al.msg);
    NEW(al.alarm); ASSERT(al.alarm # NIL, Errors.HeapOverflow);
    Alarms.Init(al.alarm, timerNo, alarmNo, FALSE);
    Alarms.Enable(al.alarm, prio);
    alarms[timerNo, alarmNo] := al
  END Init;


  PROCEDURE init;
    VAR t, a: INTEGER;
  BEGIN
    t := 0;
    WHILE t < MCU.NumTimers DO
      a := 0;
      WHILE a < MCU.NumAlarms DO
        alarms[t, a] := NIL;
        INC(a)
      END;
      INC(t)
    END
  END init;

BEGIN
  init
END KernelAlarms.
