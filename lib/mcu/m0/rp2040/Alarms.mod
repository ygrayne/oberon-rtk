MODULE Alarms;
(**
  Oberon RTK Framework
  * schedule handler procedures for the timer's four alarms
  * see: https://oberon-rtk.org/examples/alarmtest/
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions, Errors;

  CONST
    A0* = 0;
    A1* = 1;
    A2* = 2;
    A3* = 3;
    Alarms* = {A0 .. A3};
    NumAlarms* = 4;

    MarginCached = 1;
    MarginUncached = 7;

  TYPE
    Device* = POINTER TO DeviceDesc;
    ArmProc* = PROCEDURE(dev: Device; proc: PROCEDURE; time: INTEGER);
    DeviceDesc* = RECORD
      alarmNo: INTEGER;
      intNo: INTEGER;
      timeAddr: INTEGER;
      vectAddr: INTEGER;
      margin: INTEGER;
      time*, timeRun*: INTEGER
    END;


  PROCEDURE Init*(dev: Device; alarmNo: INTEGER; cached: BOOLEAN);
    CONST VectorAddrSize = 4;
    VAR vtor: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(alarmNo IN Alarms, Errors.PreCond);
    dev.alarmNo := alarmNo;
    IF cached THEN dev.margin := MarginCached ELSE dev.margin := MarginUncached END;
    dev.intNo := Exceptions.TIMER_IRQ_0 + alarmNo;
    dev.timeAddr := MCU.TIMER_ALARM + (alarmNo * MCU.TIMER_ALARM_Offset);
    SYSTEM.GET(MCU.M0PLUS_VTOR, vtor);
    dev.vectAddr := vtor + MCU.IrqZeroHandlerOffset + (VectorAddrSize * alarmNo)
  END Init;


  PROCEDURE Arm*(dev: Device; proc: PROCEDURE; time: INTEGER);
    VAR now: INTEGER;
  BEGIN
    INCL(SYSTEM.VAL(SET, proc), 0); (* thumb code *)
    dev.time := time;
    SYSTEM.EMITH(MCU.CPSID); (* run timing calc and hw arming with interrupts off *)
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    IF ~(time - now > dev.margin) THEN
      time := now + dev.margin
    END;
    dev.timeRun := time;
    SYSTEM.PUT(dev.vectAddr, proc);
    SYSTEM.PUT(dev.timeAddr, time);
    SYSTEM.EMITH(MCU.CPSIE)
  END Arm;


  PROCEDURE Rearm*(dev: Device; proc: PROCEDURE; delay: INTEGER);
  BEGIN
    Arm(dev, proc, dev.time + delay)
  END Rearm;


  PROCEDURE Disarm*(dev: Device);
    VAR en: SET;
  BEGIN
    en := {dev.alarmNo}; (* compiler issue workaround v9.1 *)
    SYSTEM.PUT(MCU.TIMER_ARMED + MCU.ASET, en) (* atomic *)
  END Disarm;


  PROCEDURE Armed*(dev: Device): BOOLEAN;
    VAR armed: SET;
  BEGIN
    SYSTEM.GET(MCU.TIMER_ARMED, armed)
    RETURN dev.alarmNo IN armed
  END Armed;


  PROCEDURE DeassertInt*(dev: Device);
    VAR en: SET;
  BEGIN
    en := {dev.alarmNo}; (* compiler issue workaround v9.1 *)
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, en)  (* atomic *)
  END DeassertInt;


  PROCEDURE Enable*(dev: Device; prio: INTEGER);
  (* must not change int prio while enabled *)
    VAR en: SET;
  BEGIN
    en := {dev.alarmNo}; (* compiler issue workaround v9.1 *)
    SYSTEM.PUT(MCU.TIMER_INTE + MCU.ASET, en);
    DeassertInt(dev);
    en := {dev.intNo}; (* compiler issue workaround v9.1 *)
    Exceptions.ClearPendingInt(en);
    Exceptions.SetIntPrio(dev.intNo, prio);
    Exceptions.EnableInt(en)
  END Enable;


  PROCEDURE Disable*(dev: Device);
    VAR en: SET;
  BEGIN
    en := {dev.alarmNo}; (* compiler issue workaround v9.1 *)
    SYSTEM.PUT(MCU.TIMER_INTE + MCU.ACLR, en);
    DeassertInt(dev);
    en := {dev.intNo}; (* compiler issue workaround v9.1 *)
    Exceptions.ClearPendingInt(en);
    Exceptions.DisableInt(en)
  END Disable;

END Alarms.

