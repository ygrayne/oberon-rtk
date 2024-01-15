MODULE Timers;
(**
  Oberon RTK Framework
  One single timer on MCU
  64 bit micro seconds => rolls over in 500,000+ years.
  --
  * get time, set time
  * setting alarms
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions;

  CONST
    Alarms = {0..3};


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


  PROCEDURE SetAlarm*(which, when: INTEGER; handler: PROCEDURE);
  (* 'when': microseconds from now *)
  (* will trigger when 'now + when' = TIMER_TIMERAWL *)
    VAR now, alarmAddr: INTEGER;
  BEGIN
    ASSERT(which IN Alarms);
    Exceptions.InstallIntHandler(which, handler); (* timer IRQs are 0 .. 3 *)
    SYSTEM.PUT(MCU.TIMER_INTE + MCU.ASET, {which});
    alarmAddr := MCU.TIMER_ALARM + (which * MCU.TIMER_ALARM_Offset);
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    when := now + when; (* can roll over, but so will TIMER_TIMERAWL *)
    SYSTEM.PUT(alarmAddr, when);
    Exceptions.EnableInt({which})
  END SetAlarm;


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
