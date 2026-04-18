MODULE NS;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure7
  Non-secure program, uses Secure module S0
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, S0 := NS_S0, LED, Out;


  PROCEDURE toggleLED(cnt: INTEGER);
  BEGIN
    LED.Clear;
    Out.String("local NS LEDgreen clear "); Out.Int(cnt, 10); Out.Ln;
    (*ASSERT(FALSE)*)
  END toggleLED;

  PROCEDURE toggleLED3(cnt: INTEGER);
  BEGIN
    toggleLED(cnt)
  END toggleLED3;

  PROCEDURE toggleLED2(cnt: INTEGER);
  BEGIN
    toggleLED3(cnt)
  END toggleLED2;

  PROCEDURE toggleLED1(cnt: INTEGER);
  BEGIN
    toggleLED2(cnt)
  END toggleLED1;

  PROCEDURE toggleLED0(cnt: INTEGER);
  BEGIN
    SYSTEM.LDREG(12, 0ABABABABH);
    toggleLED1(cnt)
  END toggleLED0;

  PROCEDURE wait;
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < 5000000 DO INC(i) END
  END wait;

  PROCEDURE run;
    VAR cnt: INTEGER;
  BEGIN
    cnt := 0;
    REPEAT
      S0.ToggleLED;
      wait;
      toggleLED0(cnt);
      wait
    UNTIL FALSE
  END run;


BEGIN
  run
END NS.
