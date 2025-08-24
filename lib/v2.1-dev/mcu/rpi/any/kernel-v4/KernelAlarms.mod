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
    SYSTEM, MCU := MCU2, T := KernelTypes, Kernel, ActorQueues, MessageQueues, Alarms, Errors, GPIO;

  CONST
    PutPin = 17;
    PutPin1 = 18;

  TYPE
    Alarm* = POINTER TO AlarmDesc;
    AlarmDesc* = RECORD
      evQ: T.EventQ;
      msg: T.Message;
      alarm*: Alarms.Device
    END;

  VAR
    alarms: ARRAY MCU.NumTimers OF ARRAY MCU.NumAlarms OF Alarm;


  PROCEDURE handler[0];
    VAR intNo, tmNo, alNo: INTEGER; al: Alarm;
  BEGIN
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {PutPin});*)
    SYSTEM.EMIT(MCU.MRS_R11_IPSR);
    intNo := SYSTEM.REG(11) - MCU.PPB_IRQ_BASE;
    tmNo := intNo DIV 4;
    alNo := intNo MOD 4;
    al := alarms[tmNo, alNo];
    Alarms.DeassertInt(al.alarm);
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {PutPin1});*)
    Kernel.PutMsg(al.evQ, al.msg);
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {PutPin1});*)
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {PutPin});*)
  END handler;


  PROCEDURE Arm*(al: Alarm; act: T.Actor; time: INTEGER);
  BEGIN
    ASSERT(~Alarms.Armed(al.alarm), Errors.ProgError);
    Alarms.Arm(al.alarm, handler, time);
    Kernel.GetMsg(al.evQ, act)
  END Arm;


  PROCEDURE Rearm*(al: Alarm; act: T.Actor; delay: INTEGER);
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
    NEW(al.evQ); ASSERT(al.evQ # NIL, Errors.HeapOverflow);
    NEW(al.evQ.msgQ); ASSERT(al.evQ.msgQ # NIL, Errors.HeapOverflow);
    NEW(al.evQ.actQ); ASSERT(al.evQ.actQ # NIL, Errors.HeapOverflow);
    MessageQueues.Init(al.evQ.msgQ);
    ActorQueues.Init(al.evQ.actQ);
    NEW(al.msg); ASSERT(al.msg # NIL, Errors.HeapOverflow);
    al.msg.pool := NIL;
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
  init;
  (*
  GPIO.SetFunction(PutPin, MCU.IO_BANK0_Fsio);
  GPIO.SetFunction(PutPin1, MCU.IO_BANK0_Fsio);
  GPIO.OutputEnable({PutPin, PutPin1});
  GPIO.Clear({PutPin, PutPin1})
  *)
END KernelAlarms.
