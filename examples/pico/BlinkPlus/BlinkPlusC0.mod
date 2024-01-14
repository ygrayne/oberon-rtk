MODULE BlinkPlusC0;
(**
  Oberon RTK Framework
  Example program, multi-core
  Core 1 program module: BlinkPlusC1
  --
  MCU: RP2040
  Board: Pico
  --
  Description: refer to https://oberon-rtk.org/examples/blinkplus/
  --
  Copyright (c) 2023 Gray gray@grayraven.org
**)

  IMPORT Main, Out, MultiCore, Memory, Timers, C1 := BLinkPlusC1;

  CONST
    Core1 = 1;
    Interval = 1000 * 1000;


  PROCEDURE fail;
    VAR x: INTEGER;
  BEGIN
    x := 0;
    x := x DIV x
  END fail;


  PROCEDURE run;
    VAR before, timeH, timeL, cnt: INTEGER;
  BEGIN
    MultiCore.InitCoreOne(C1.Run, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);
    Out.String("core 0"); Out.Ln;
    Timers.SetTime(0, 0FFFFFFFFH - 10000000); (* force timeL roll-over after ten seconds *)
    Timers.GetTime(timeH, before);
    cnt := 0;
    REPEAT
      Timers.GetTime(timeH, timeL);
      ASSERT(timeL - before >= 0); (* check if the 32-bit rollover works *)
      IF timeL - before >= Interval THEN
        Out.Int(cnt, 0); Out.Int(timeL - before, 8); Out.Hex(timeL, 10); Out.Ln;
        before := timeL;
        INC(cnt)
      END;
      IF cnt = 20 THEN fail END
    UNTIL FALSE
  END run;

BEGIN
  run
END BlinkPlusC0.
