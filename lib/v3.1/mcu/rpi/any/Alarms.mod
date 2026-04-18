MODULE Alarms;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  * schedule handler procedures for the timers' alarms
  * see: https://oberon-rtk.org/examples/v2/alarmtest/
  --
  Type: MCU
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2024-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, PPB, DEV := TIMERS_DEV, EXC, RST, Exceptions, Errors;

  CONST
    A0* = DEV.A0;
    A1* = DEV.A1;
    A2* = DEV.A2;
    A3* = DEV.A3;
    T0* = DEV.T0;
    T1* = DEV.T1;

    NumTimers* = DEV.NumTimers;
    NumAlarms* = DEV.NumAlarms;

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
      TIMERAWL*: INTEGER;
      INTE, INTR*: INTEGER
    END;


  PROCEDURE* Init*(dev: Device; timerNo, alarmNo: INTEGER; cached: BOOLEAN);
    CONST VectorAddrSize = 4; TimerRegSize = 4;
    VAR vtor, timerBaseAddr: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(timerNo IN DEV.Timers_all, Errors.PreCond);
    ASSERT(alarmNo IN DEV.Alarms_all, Errors.PreCond);
    dev.alarmNo := alarmNo;
    dev.timerNo := timerNo;
    dev.intNo := EXC.IRQ_TIMER0_0 + (timerNo * DEV.NumAlarms) + alarmNo;
    timerBaseAddr := DEV.TIMER0_BASE + (timerNo * DEV.TIMER_Offset);
    dev.ALARM := timerBaseAddr + DEV.TIMER_ALARM0_Offset + (alarmNo * TimerRegSize);
    dev.ARMED := timerBaseAddr + DEV.TIMER_ARMED_Offset;
    dev.TIMERAWL := timerBaseAddr + DEV.TIMER_TIMERAWL_Offset;
    dev.INTE := timerBaseAddr + DEV.TIMER_INTE_Offset;
    dev.INTR := timerBaseAddr + DEV.TIMER_INTR_Offset;
    IF cached THEN dev.margin := MarginCached ELSE dev.margin := MarginUncached END;
    SYSTEM.GET(PPB.VTOR, vtor);
    dev.vectAddr := vtor + ((dev.intNo + PPB.IRQ_BASE) * VectorAddrSize)
  END Init;


  PROCEDURE EnableTimer*(dev: Device);
  BEGIN
    RST.ReleaseReset(DEV.TIMER_RST_reg, DEV.TIMER0_RST_pos + dev.timerNo)
  END EnableTimer;


  PROCEDURE* Arm*(dev: Device; proc: PROCEDURE; time: INTEGER);
    VAR now: INTEGER;
  BEGIN
    INCL(SYSTEM.VAL(SET, proc), 0); (* thumb code *)
    dev.alarmTime := time;
    (* asm
      cpsid i     (* run timing calc and hw arming with interrupts off *)
    end asm *)
    (* +asm *)
    SYSTEM.EMITH(0B672H);  (* cpsid i *)
    (* -asm *)
    SYSTEM.GET(dev.TIMERAWL, now);
    IF ~(time - now > dev.margin) THEN
      time := now + dev.margin
    END;
    dev.alarmRetimed := time;
    SYSTEM.PUT(dev.vectAddr, proc);
    SYSTEM.PUT(dev.ALARM, time);
    (* asm
      cpsie i
    end asm *)
    (* +asm *)
    SYSTEM.EMITH(0B662H);  (* cpsie i *)
    (* -asm *)
  END Arm;


  PROCEDURE Rearm*(dev: Device; proc: PROCEDURE; delay: INTEGER);
  BEGIN
    Arm(dev, proc, dev.alarmTime + delay)
  END Rearm;


  PROCEDURE* Disarm*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.ARMED + BASE.ACLR, {dev.alarmNo}) (* atomic *)
  END Disarm;


  PROCEDURE* Armed*(dev: Device): BOOLEAN;
    VAR armed: SET;
  BEGIN
    SYSTEM.GET(dev.ARMED, armed)
    RETURN dev.alarmNo IN armed
  END Armed;


  PROCEDURE* DeassertInt*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.INTR + BASE.ACLR, {dev.alarmNo})  (* atomic *)
  END DeassertInt;


  PROCEDURE Enable*(dev: Device; prio: INTEGER);
  (* must not change int prio while enabled *)
  BEGIN
    SYSTEM.PUT(dev.INTE + BASE.ASET, {dev.alarmNo});
    SYSTEM.PUT(dev.INTR + BASE.ACLR, {dev.alarmNo}); (* de-assert *)
    Exceptions.ClearPendingInt(dev.intNo);
    Exceptions.SetIntPrio(dev.intNo, prio);
    Exceptions.EnableInt(dev.intNo)
  END Enable;


  PROCEDURE Disable*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.INTE + BASE.ACLR, {dev.alarmNo});
    SYSTEM.PUT(dev.INTR + BASE.ACLR, {dev.alarmNo}); (* de-assert *)
    Exceptions.ClearPendingInt(dev.intNo);
    Exceptions.DisableInt(dev.intNo)
  END Disable;


  PROCEDURE GetTime*(dev: Device; VAR timeL: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := dev.TIMERAWL;
    SYSTEM.GET(addr, timeL)
  END GetTime;

END Alarms.
