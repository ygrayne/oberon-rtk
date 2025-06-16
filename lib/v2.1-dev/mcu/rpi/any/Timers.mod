MODULE Timers;
(**
  Oberon RTK Framework v2
  --
  64 bit micro seconds => rolls over in 500,000+ years.
  --
  * get time, set time
  --
  MCU: RP2040, RP2350
  --
  --
  Notes:
  * Available timer devices:
    * RP2040: one timer
    * RP2350: two timers
  * Reset releases:
    * TIMER0: by boot procedure (RP2040, RP2350)
    * TIMER1: by Main.mod (RP2350)
  --
  Copyright (c) 2023-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

  CONST
    TIMER0* = 0;
    TIMER1* = 1;
    NumTimers* = MCU.NumTimers;
    Timers = {TIMER0 .. NumTimers - 1};

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      timerNo: INTEGER;
      devNo: INTEGER;
      TIMERAWH, TIMERAWL: INTEGER;
      TIMEHW, TIMELW: INTEGER
    END;


  PROCEDURE Init*(dev: Device; timerNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(timerNo IN Timers, Errors.ProgError);
    dev.timerNo := timerNo;
    dev.devNo := MCU.RESETS_TIMER0 + timerNo;
    base := MCU.TIMER0_BASE + (timerNo * MCU.TIMER_Offset);
    dev.TIMERAWH := base + MCU.TIMER_TIMERAWH_Offset;
    dev.TIMERAWL := base + MCU.TIMER_TIMERAWL_Offset;
    dev.TIMEHW := base + MCU.TIMER_TIMEHW_Offset;
    dev.TIMELW := base + MCU.TIMER_TIMELW_Offset
  END Init;


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


  PROCEDURE DelayBlk*(dev: Device; delay: INTEGER); (* microseconds *)
  (* blocking delay *)
    VAR start, now, elapsed: INTEGER;
  BEGIN
    ASSERT(delay > 0, Errors.PreCond);
    SYSTEM.GET(dev.TIMERAWL, start);
    REPEAT
      SYSTEM.GET(dev.TIMERAWL, now);
      elapsed := ABS(now - start)
    UNTIL elapsed >= delay
  END DelayBlk;


  PROCEDURE* SetTime*(dev: Device; timeH, timeL: INTEGER);
  (* for testing only *)
  BEGIN
    SYSTEM.PUT(dev.TIMELW, timeL);
    SYSTEM.PUT(dev.TIMEHW, timeH)
  END SetTime;

END Timers.
