MODULE BlinkPlusC1;
(**
  Oberon RTK Framework
  --
  Example program, multi-core
  Description: refer to https://oberon-rtk.org/docs/examples/v2/blinkplus/
  --
  See module 'BlinkPlusC0'
  Uncomment 'Run' in the module init section to run this program alone on core 0.
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Out, GPIO, LED, Timers, Errors;

  CONST
    Interval = 1000 * 1000;

  VAR
    Timer*: Timers.Device;


  PROCEDURE fail;
    VAR x: INTEGER; a: ARRAY 2 OF INTEGER;
  BEGIN
    a[0] := 0; a[1] := 0; (* avoid false positives in stack trace *)
    x := 2;
    x := a[x]
  END fail;


  PROCEDURE Run*;
    VAR before, timeH, timeL, cnt: INTEGER;
  BEGIN
    Out.String("core 1"); Out.Ln;
    GPIO.Set({LED.Green});
    Timers.GetTime(Timer, timeH, before);
    cnt := 0;
    REPEAT
      Timers.GetTime(Timer, timeH, timeL);
      IF timeL - before >= Interval THEN
        GPIO.Toggle({LED.Green});
        Out.Int(cnt, 0); Out.Int(timeL - before, 8); Out.Hex(timeL, 10); Out.Ln;
        before := timeL;
        INC(cnt)
      END;
      IF cnt = 20 THEN fail END
    UNTIL FALSE
  END Run;


  PROCEDURE initTimer;
  BEGIN
    NEW(Timer); ASSERT(Timer # NIL, Errors.HeapOverflow);
    Timers.Init(Timer, Timers.TIMER0);
    Timers.SetTime(Timer, 0, 0FFFFFFFFH - 10000000); (* force timeL roll-over after ten seconds *)
  END initTimer;

BEGIN
  initTimer (* executes on core 0 *)
  (* Run *)
END BlinkPlusC1.
