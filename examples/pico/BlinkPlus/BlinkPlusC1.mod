MODULE BlinkPlusC1;
(**
  Oberon RTK Framework
  Example program, multi-core
  See module 'BlinkPlusC0'
  Uncomment 'Run' in the module init section to run this program alone on core 0.
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2023 Gray gray@grayraven.org
**)

  IMPORT Main, Out, GPIO, LED, Timers;

  CONST
    Interval = 500 * 1000;


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
    Timers.GetTime(timeH, before);
    cnt := 0;
    REPEAT
      Timers.GetTime(timeH, timeL);
      IF timeL - before >= Interval THEN
        GPIO.Toggle({LED.Green});
        Out.Int(cnt, 0); Out.Int(timeL - before, 8); Out.Ln;
        before := timeL;
        INC(cnt)
      END;
      IF cnt = 40 THEN fail END
    UNTIL FALSE
  END Run;

BEGIN
  (* Run *)
END BlinkPlusC1.
