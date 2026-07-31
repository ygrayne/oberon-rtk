MODULE TIMER;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  TIMER device
  64 bit micro seconds => rolls over in 500,000+ years.
  --
  MCU: RP2350
  --
  Note: bootrom procedure releases reset of TIMER0
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, DEV := TIMER_DEV, RST, Errors;

  CONST
    (* unit numbers as on chip *)
    TIMER0* = DEV.TIMER0;
    TIMER1* = DEV.TIMER1;

    NumTimers* = DEV.NumTimers;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      unitNo*, handle*: INTEGER;
      rstReg, rstPos: INTEGER;
      TIMERAWH, TIMERAWL: INTEGER;
      TIMEHW, TIMELW: INTEGER
    END;

  VAR
    Devices*: ARRAY NumTimers OF Device;


  PROCEDURE* IsValid*(dev: Device; timerHandle, timerNo: INTEGER): BOOLEAN;
    RETURN (timerNo IN DEV.Timers_all) & (dev # NIL) &
           (timerHandle >= 0) & (timerHandle < NumTimers) &
           (Devices[timerHandle] = dev) &
           (Devices[timerHandle].unitNo = timerNo)
  END IsValid;


  PROCEDURE* Bound*(timerHandle: INTEGER): BOOLEAN;
    RETURN (timerHandle >= 0) & (timerHandle < NumTimers) &
           (Devices[timerHandle] # NIL) &
           (Devices[timerHandle].handle = timerHandle)
  END Bound;


  PROCEDURE* Init*(dev: Device; timerHandle, timerNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(timerNo IN DEV.Timers_all, Errors.PreCond);
    ASSERT((timerHandle >= 0) & (timerHandle < NumTimers), Errors.PreCond);
    ASSERT((Devices[timerHandle] = NIL) OR (Devices[timerHandle] = dev), Errors.ConsCheck);
    dev.unitNo := timerNo;
    dev.handle := timerHandle;
    dev.rstReg := DEV.TIMER_RST_reg;
    dev.rstPos := DEV.TIMER0_RST_pos + timerNo;
    base := DEV.TIMER0_BASE + (timerNo * DEV.TIMER_Offset);
    dev.TIMERAWH := base + DEV.TIMER_TIMERAWH_Offset;
    dev.TIMERAWL := base + DEV.TIMER_TIMERAWL_Offset;
    dev.TIMEHW := base + DEV.TIMER_TIMEHW_Offset;
    dev.TIMELW := base + DEV.TIMER_TIMELW_Offset;
    Devices[timerHandle] := dev
  END Init;


  PROCEDURE Configure*(timerHandle: INTEGER);
    VAR dev: Device;
  BEGIN
    dev := Devices[timerHandle];
    RST.ReleaseReset(dev.rstReg, dev.rstPos)
  END Configure;


  PROCEDURE* GetTime*(timerHandle: INTEGER; VAR timeH, timeL: INTEGER);
    VAR t0: INTEGER; done: BOOLEAN; dev: Device;
  BEGIN
    dev := Devices[timerHandle];
    SYSTEM.GET(dev.TIMERAWH, timeH);
    done := FALSE;
    REPEAT
      SYSTEM.GET(dev.TIMERAWL, timeL);
      SYSTEM.GET(dev.TIMERAWH, t0);
      done := t0 = timeH;
      timeH := t0
    UNTIL done
  END GetTime;


  PROCEDURE* GetTimeL*(timerHandle: INTEGER; VAR timeL: INTEGER);
    VAR dev: Device;
  BEGIN
    dev := Devices[timerHandle];
    SYSTEM.GET(dev.TIMERAWL, timeL)
  END GetTimeL;


  PROCEDURE* DelayBlk*(timerHandle: INTEGER; delay: INTEGER); (* microseconds *)
  (* blocking delay *)
    VAR start, now, elapsed: INTEGER; dev: Device;
  BEGIN
    ASSERT(delay > 0, Errors.PreCond);
    dev := Devices[timerHandle];
    SYSTEM.GET(dev.TIMERAWL, start);
    REPEAT
      SYSTEM.GET(dev.TIMERAWL, now);
      elapsed := ABS(now - start)
    UNTIL elapsed >= delay
  END DelayBlk;


  PROCEDURE* SetTime*(timerHandle: INTEGER; timeH, timeL: INTEGER);
  (* for testing only *)
    VAR dev: Device;
  BEGIN
    dev := Devices[timerHandle];
    SYSTEM.PUT(dev.TIMELW, timeL);
    SYSTEM.PUT(dev.TIMEHW, timeH)
  END SetTime;


  PROCEDURE* init;
    VAR timerHandle: INTEGER;
  BEGIN
    timerHandle := 0;
    WHILE timerHandle < NumTimers DO
      Devices[timerHandle] := NIL;
      INC(timerHandle)
    END
  END init;


BEGIN
  init
END TIMER.
