MODULE Timers;
(**
  Oberon RTK Framework
  One single timer on MCU
  64 bit micro seconds => rolls over in 500,000+ years.
  --
  * get time, set time
  * alarm interrupt handling
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions;

  CONST
    NumAlarms* = 4;


  PROCEDURE GetTime*(VAR timeH, timeL: INTEGER);
    VAR t0: INTEGER; done: BOOLEAN;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWH, timeH);
    done := FALSE;
    REPEAT
      SYSTEM.GET(MCU.TIMER_TIMERAWL, timeL);
      SYSTEM.GET(MCU.TIMER_TIMERAWH, t0);
      done := t0 = timeH;
      timeH := t0
    UNTIL done
  END GetTime;


  PROCEDURE GetTimeL*(VAR timeL: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, timeL)
  END GetTimeL;


  PROCEDURE InstallAlarmIntHandler*(alarmNo: INTEGER; handler: PROCEDURE);
  BEGIN
    Exceptions.InstallIntHandler(Exceptions.TIMER_IRQ_0 + alarmNo, handler)
  END InstallAlarmIntHandler;


  PROCEDURE SetAlarmIntPrio*(alarmNo, prio: INTEGER);
  BEGIN
    Exceptions.SetIntPrio(Exceptions.TIMER_IRQ_0 + alarmNo, prio)
  END SetAlarmIntPrio;


  PROCEDURE EnableAlarmInt*(alarmNo: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.TIMER_INTE + MCU.ASET, {alarmNo})
  END EnableAlarmInt;


  PROCEDURE DeassertAlarmInt*(alarmNo: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, {alarmNo})
  END DeassertAlarmInt;


  PROCEDURE SetTime*(timeH, timeL: INTEGER);
  (* for testing only *)
  BEGIN
    SYSTEM.PUT(MCU.TIMER_TIMELW, timeL);
    SYSTEM.PUT(MCU.TIMER_TIMEHW, timeH)
  END SetTime;

(*
  Nothing to configure, resets to time zero
  PROCEDURE Init*;
  END Init;
*)

END Timers.

