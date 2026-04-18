MODULE Timers;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  64 bit micro seconds => rolls over in 500,000+ years.
  --
  * get time, set time
  --
  MCU: RP2040, RP2350
  --
  Notes:
  * Available timer devices:
    * RP2040: one timer
    * RP2350: two timers
  * Reset releases:
    * TIMER0: by boot procedure (RP2040, RP2350)
    * TIMER1: by Main.mod (RP2350)
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, DEV := TIMERS_DEV, RST, Errors;

  CONST
    TIMER0* = DEV.TIMER0;
    TIMER1* = DEV.TIMER1;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      timerNo: INTEGER;
      rstReg, rstPos: INTEGER;
      TIMERAWH, TIMERAWL: INTEGER;
      TIMEHW, TIMELW: INTEGER
    END;


  PROCEDURE Init*(dev: Device; timerNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(timerNo IN DEV.Timers_all, Errors.ProgError);
    dev.timerNo := timerNo;
    dev.rstReg := DEV.TIMER_RST_reg;
    dev.rstPos := DEV.TIMER0_RST_pos + timerNo;
    base := DEV.TIMER0_BASE + (timerNo * DEV.TIMER_Offset);
    dev.TIMERAWH := base + DEV.TIMER_TIMERAWH_Offset;
    dev.TIMERAWL := base + DEV.TIMER_TIMERAWL_Offset;
    dev.TIMEHW := base + DEV.TIMER_TIMEHW_Offset;
    dev.TIMELW := base + DEV.TIMER_TIMELW_Offset
  END Init;


  PROCEDURE Enable*(dev: Device);
  BEGIN
    RST.ReleaseReset(dev.rstReg, dev.rstPos)
  END Enable;


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


  (* Secure/Non-secure, RP2350 only *)

  PROCEDURE GetDevSec*(timerNo: INTEGER; VAR reg: INTEGER);
  BEGIN
    ASSERT(timerNo IN DEV.Timers_all);
    reg := DEV.TIMER0_SEC_reg + (timerNo * 4)
  END GetDevSec;

END Timers.
