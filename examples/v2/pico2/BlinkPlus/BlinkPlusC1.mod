MODULE BlinkPlusC1;
(**
  Oberon RTK Framework
  --
  Example program, multi-core
  Description: refer to https://oberon-rtk.org/examples/blinkplus/
  --
  See module 'BlinkPlusC0'
  Uncomment 'Run' in the module init section to run this program alone on core 0.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Out, GPIO, LED, Timers, Errors;

  CONST
    Interval = 1000 * 1000;


  PROCEDURE fail;
    VAR x: INTEGER; a: ARRAY 2 OF INTEGER;
  BEGIN
    a[0] := 0; a[1] := 0; (* avoid false positives in stack trace *)
    x := 2;
    x := a[x]
  END fail;


  PROCEDURE Run*;
    VAR before, timeH, timeL, cnt: INTEGER; timer: Timers.Device;
  BEGIN
    NEW(timer); ASSERT(timer # NIL, Errors.HeapOverflow);
    Timers.Init(timer, Timers.TIMER1);
    Timers.Configure(timer);
    Timers.SetTime(timer, 0, 0FFFFFFFFH - 10000000); (* force timeL roll-over after ten seconds *)
    Out.String("core 1"); Out.Ln;
    GPIO.Set({LED.Green});
    Timers.GetTime(timer, timeH, before);
    cnt := 0;
    REPEAT
      Timers.GetTime(timer, timeH, timeL);
      IF timeL - before >= Interval THEN
        GPIO.Toggle({LED.Green});
        Out.Int(cnt, 0); Out.Int(timeL - before, 8); Out.Hex(timeL, 10); Out.Ln;
        before := timeL;
        INC(cnt)
      END;
      IF cnt = 20 THEN fail END
    UNTIL FALSE
  END Run;

BEGIN
  (* Run *)
END BlinkPlusC1.
