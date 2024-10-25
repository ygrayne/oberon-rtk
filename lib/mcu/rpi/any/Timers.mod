MODULE Timers;
(**
  Oberon RTK Framework
  One single timer on MCU
  64 bit micro seconds => rolls over in 500,000+ years.
  --
  * get time, set time
  * alarm interrupt handling
  --
  MCU: RP2040, not yet extended/adapted for RP2350
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Exceptions;

  CONST
    NumAlarms* = 4;
    (* tmp *)
    TIMERAWH = MCU.TIMER0_BASE + MCU.TIMER_TIMERAWH_Offset;
    TIMERAWL = MCU.TIMER0_BASE + MCU.TIMER_TIMERAWL_Offset;
    TIMELW = MCU.TIMER0_BASE + MCU.TIMER_TIMELW_Offset;
    TIMEHW = MCU.TIMER0_BASE + MCU.TIMER_TIMEHW_Offset;
    INTE = MCU.TIMER0_BASE + MCU.TIMER_INTE_Offset;
    INTR = MCU.TIMER0_BASE + MCU.TIMER_INTR_Offset;


  PROCEDURE GetTime*(VAR timeH, timeL: INTEGER);
    VAR t0: INTEGER; done: BOOLEAN;
  BEGIN
    SYSTEM.GET(TIMERAWH, timeH);
    done := FALSE;
    REPEAT
      SYSTEM.GET(TIMERAWL, timeL);
      SYSTEM.GET(TIMERAWH, t0);
      done := t0 = timeH;
      timeH := t0
    UNTIL done
  END GetTime;


  PROCEDURE GetTimeL*(VAR timeL: INTEGER);
  BEGIN
    SYSTEM.GET(TIMERAWL, timeL)
  END GetTimeL;


  PROCEDURE InstallAlarmIntHandler*(alarmNo: INTEGER; handler: PROCEDURE);
  BEGIN
    Exceptions.InstallIntHandler(MCU.PPB_NVIC_TIMER0_IRQ_0 + alarmNo, handler)
  END InstallAlarmIntHandler;


  PROCEDURE SetAlarmIntPrio*(alarmNo, prio: INTEGER);
  BEGIN
    Exceptions.SetIntPrio(MCU.PPB_NVIC_TIMER0_IRQ_0 + alarmNo, prio)
  END SetAlarmIntPrio;


  PROCEDURE EnableAlarmInt*(alarmNo: INTEGER);
  BEGIN
    SYSTEM.PUT(INTE + MCU.ASET, {alarmNo})
  END EnableAlarmInt;


  PROCEDURE DeassertAlarmInt*(alarmNo: INTEGER);
  BEGIN
    SYSTEM.PUT(INTR + MCU.ACLR, {alarmNo})
  END DeassertAlarmInt;


  PROCEDURE SetTime*(timeH, timeL: INTEGER);
  (* for testing only *)
  BEGIN
    SYSTEM.PUT(TIMELW, timeL);
    SYSTEM.PUT(TIMEHW, timeH)
  END SetTime;

(*
  Nothing to configure, resets to time zero
  PROCEDURE Init*;
  END Init;
*)

END Timers.
