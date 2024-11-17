MODULE Timers;
(**
  Oberon RTK Framework v2
  --
  64 bit micro seconds => rolls over in 500,000+ years.
  --
  * get time, set time
  * alarm interrupt handling
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions, Errors, StartUp;

  CONST
    TIMER0* = 0;
    TIMER1* = 1;
    NumTimers* = MCU.NumTimers;
    Timers = {TIMER0 .. NumTimers - 1};
    NumAlarms* = 4; (* per timer *)

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      timerNo: INTEGER;
      devNo: INTEGER;
      intNo: INTEGER;
      TIMERAWH, TIMERAWL: INTEGER;
      TIMEHW, TIMELW: INTEGER;
      INTE, INTR: INTEGER
    END;


  PROCEDURE Init*(dev: Device; timerNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(timerNo IN Timers, Errors.ProgError);
    dev.timerNo := timerNo;
    dev.devNo := MCU.RESETS_TIMER0 + timerNo;
    dev.intNo := MCU.PPB_TIMER0_IRQ_0 + (timerNo * NumAlarms);
    base := MCU.TIMER0_BASE + (timerNo * MCU.TIMER_Offset);
    dev.TIMERAWH := base + MCU.TIMER_TIMERAWH_Offset;
    dev.TIMERAWL := base + MCU.TIMER_TIMERAWL_Offset;
    dev.TIMEHW := base + MCU.TIMER_TIMEHW_Offset;
    dev.TIMELW := base + MCU.TIMER_TIMELW_Offset;
    dev.INTE := base + MCU.TIMER_INTE_Offset;
    dev.INTR := base + MCU.TIMER_INTR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device);
  BEGIN
    StartUp.ReleaseReset(dev.devNo)
  END Configure;


  PROCEDURE* GetTime*(dev: Device; VAR timeH, timeL: INTEGER);
    VAR t0: INTEGER; done: BOOLEAN;
  BEGIN
    SYSTEM.GET(dev.TIMERAWH, timeH);
    done := FALSE;
    REPEAT
      SYSTEM.GET(dev.TIMERAWL, timeL);
      SYSTEM.GET(dev.TIMERAWH, t0);
      done := t0 = timeH;
      timeH := t0
    UNTIL done
  END GetTime;


  PROCEDURE* GetTimeL*(dev: Device; VAR timeL: INTEGER);
  BEGIN
    SYSTEM.GET(dev.TIMERAWL, timeL)
  END GetTimeL;


  PROCEDURE InstallAlarmIntHandler*(dev: Device; alarmNo: INTEGER; handler: PROCEDURE);
  BEGIN
    Exceptions.InstallIntHandler(dev.intNo + alarmNo, handler)
  END InstallAlarmIntHandler;


  PROCEDURE SetAlarmIntPrio*(dev: Device; alarmNo, prio: INTEGER);
  BEGIN
    Exceptions.SetIntPrio(dev.intNo + alarmNo, prio)
  END SetAlarmIntPrio;


  PROCEDURE* EnableAlarmInt*(dev: Device; alarmNo: INTEGER);
  BEGIN
    SYSTEM.PUT(dev.INTE + MCU.ASET, {alarmNo})
  END EnableAlarmInt;


  PROCEDURE* DeassertAlarmInt*(dev: Device; alarmNo: INTEGER);
  BEGIN
    SYSTEM.PUT(dev.INTR + MCU.ACLR, {alarmNo})
  END DeassertAlarmInt;


  PROCEDURE* SetTime*(dev: Device; timeH, timeL: INTEGER);
  (* for testing only *)
  BEGIN
    SYSTEM.PUT(dev.TIMELW, timeL);
    SYSTEM.PUT(dev.TIMEHW, timeH)
  END SetTime;

END Timers.
