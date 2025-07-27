MODULE Ticker;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  For example program: periodic timing message.
  --
  MCU: RP2350
  Board: Pico2, Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Types, Kernel, Alarms, MessagePool, MessageQueue, ActorQueue, Errors, LED;

  CONST
    NumMsg = 10;
    Prio = MCU.PPB_ExcPrio1;
    TickerAlarm = Alarms.A0;
    TickerTimer = Alarms.T0;

  TYPE
    Message* = POINTER TO MessageDesc;
    MessageDesc* = RECORD (Types.MessageDesc)
      cnt*: INTEGER
    END;

  VAR
    alarm: Alarms.Device;
    EvQ*: Types.EventQueue;
    msgPool: Types.MessagePool;
    cnt, alarmInt: INTEGER;


  PROCEDURE handler[0];
    VAR m: Types.Message; msg: Message;
  BEGIN
    SYSTEM.PUT(LED.LXOR, {LED.Green});
    Alarms.DeassertInt(alarm);
    MessagePool.Get(msgPool, m); (* protected *)
    IF m # NIL THEN
      msg := m(Message);
      msg.cnt := cnt;
      INC(cnt);
      Kernel.PutMsg(EvQ, msg) (* protected *)
    ELSE
      ASSERT(FALSE) (* out of messages, add error handling *)
    END;
    Alarms.Rearm(alarm, handler, alarmInt)
  END handler;


  PROCEDURE makeMsg(): Types.Message;
    VAR m: Message;
  BEGIN
    NEW(m); ASSERT(m # NIL, Errors.HeapOverflow);
    RETURN m
  END makeMsg;


  PROCEDURE Init*(milliSecsPerTick: INTEGER);
  BEGIN
    cnt := 0;
    NEW(msgPool); ASSERT(msgPool # NIL, Errors.HeapOverflow);
    MessagePool.Init(msgPool, makeMsg, NumMsg);
    NEW(EvQ); ASSERT(EvQ # NIL, Errors.HeapOverflow);
    NEW(EvQ.msgQ); ASSERT(EvQ.msgQ # NIL, Errors.HeapOverflow);
    NEW(EvQ.actQ); ASSERT(EvQ.actQ # NIL, Errors.HeapOverflow);
    MessageQueue.Init(EvQ.msgQ);
    ActorQueue.Init(EvQ.actQ);
    NEW(alarm); ASSERT(alarm # NIL, Errors.HeapOverflow);
    Alarms.Init(alarm, TickerTimer, TickerAlarm, FALSE);
    Alarms.Enable(alarm, Prio);
    alarmInt := milliSecsPerTick * 1000;
  END Init;

  PROCEDURE Start*;
    VAR now: INTEGER;
  BEGIN
    Alarms.GetTime(TickerTimer, now);
    Alarms.Arm(alarm, handler, now + alarmInt)
  END Start;

END Ticker.
