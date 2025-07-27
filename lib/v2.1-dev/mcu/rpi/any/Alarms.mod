MODULE Alarms;
(**
  Oberon RTK Framework v2
  --
  * schedule handler procedures for the timers' alarms
  * see: https://oberon-rtk.org/examples/v2/alarmtest/
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2024-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions, Errors;

  CONST
    A0* = 0;
    A1* = 1;
    A2* = 2;
    A3* = 3;
    T0* = 0;
    T1* = 1;

    Alarms = {A0 .. A3};
    NumAlarms* = 4;
    NumTimers = MCU.NumTimers;
    Timers = {0 .. NumTimers - 1};

    MarginCached = 1;
    MarginUncached = 7;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      alarmNo*, timerNo*: INTEGER;
      intNo: INTEGER;
      vectAddr: INTEGER;
      margin: INTEGER;
      alarmTime*, alarmRetimed*: INTEGER;
      ALARM, ARMED: INTEGER;
      TIMERAWL: INTEGER;
      INTE, INTR*: INTEGER
    END;


  PROCEDURE* Init*(dev: Device; timerNo, alarmNo: INTEGER; cached: BOOLEAN);
    CONST VectorAddrSize = 4; TimerRegSize = 4;
    VAR vtor, timerBaseAddr: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(timerNo IN Timers, Errors.ProgError);
    ASSERT(alarmNo IN Alarms, Errors.ProgError);
    dev.alarmNo := alarmNo;
    dev.timerNo := timerNo;
    dev.intNo := MCU.PPB_TIMER0_IRQ_0 + (timerNo * NumAlarms) + alarmNo;
    timerBaseAddr := MCU.TIMER0_BASE + (timerNo * MCU.TIMER_Offset);
    dev.ALARM := timerBaseAddr + MCU.TIMER_ALARM0_Offset + (alarmNo * TimerRegSize);
    dev.ARMED := timerBaseAddr + MCU.TIMER_ARMED_Offset;
    dev.TIMERAWL := timerBaseAddr + MCU.TIMER_TIMERAWL_Offset;
    dev.INTE := timerBaseAddr + MCU.TIMER_INTE_Offset;
    dev.INTR := timerBaseAddr + MCU.TIMER_INTR_Offset;
    IF cached THEN dev.margin := MarginCached ELSE dev.margin := MarginUncached END;
    SYSTEM.GET(MCU.PPB_VTOR, vtor);
    dev.vectAddr := vtor + ((dev.intNo + MCU.PPB_IRQ_BASE) * VectorAddrSize)
  END Init;


  PROCEDURE* Arm*(dev: Device; proc: PROCEDURE; time: INTEGER);
    VAR now: INTEGER;
  BEGIN
    INCL(SYSTEM.VAL(SET, proc), 0); (* thumb code *)
    dev.alarmTime := time;
    SYSTEM.EMITH(MCU.CPSID); (* run timing calc and hw arming with interrupts off *)
    SYSTEM.GET(dev.TIMERAWL, now);
    IF ~(time - now > dev.margin) THEN
      time := now + dev.margin
    END;
    dev.alarmRetimed := time;
    SYSTEM.PUT(dev.vectAddr, proc);
    SYSTEM.PUT(dev.ALARM, time);
    SYSTEM.EMITH(MCU.CPSIE)
  END Arm;


  PROCEDURE Rearm*(dev: Device; proc: PROCEDURE; delay: INTEGER);
  BEGIN
    Arm(dev, proc, dev.alarmTime + delay)
  END Rearm;


  PROCEDURE* Disarm*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.ARMED + MCU.ACLR, {dev.alarmNo}) (* atomic *)
  END Disarm;


  PROCEDURE* Armed*(dev: Device): BOOLEAN;
    VAR armed: SET;
  BEGIN
    SYSTEM.GET(dev.ARMED, armed)
    RETURN dev.alarmNo IN armed
  END Armed;


  PROCEDURE* DeassertInt*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.INTR + MCU.ACLR, {dev.alarmNo})  (* atomic *)
  END DeassertInt;


  PROCEDURE Enable*(dev: Device; prio: INTEGER);
  (* must not change int prio while enabled *)
  BEGIN
    SYSTEM.PUT(dev.INTE + MCU.ASET, {dev.alarmNo});
    SYSTEM.PUT(dev.INTR + MCU.ACLR, {dev.alarmNo}); (* de-assert *)
    Exceptions.ClearPendingInt(dev.intNo);
    Exceptions.SetIntPrio(dev.intNo, prio);
    Exceptions.EnableInt(dev.intNo)
  END Enable;


  PROCEDURE Disable*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.INTE + MCU.ACLR, {dev.alarmNo});
    SYSTEM.PUT(dev.INTR + MCU.ACLR, {dev.alarmNo}); (* de-assert *)
    Exceptions.ClearPendingInt(dev.intNo);
    Exceptions.DisableInt(dev.intNo)
  END Disable;


  PROCEDURE GetTime*(timerNo: INTEGER; VAR timeL: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.TIMER0_BASE + (timerNo * MCU.TIMER_Offset) + MCU.TIMER_TIMERAWL_Offset;
    SYSTEM.GET(addr, timeL)
  END GetTime;

END Alarms.
