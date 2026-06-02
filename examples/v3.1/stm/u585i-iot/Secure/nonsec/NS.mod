MODULE NS;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure
  Non-secure program, uses Secure module S0
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, LED, S0 := NS_S0, Out;


  PROCEDURE toggleLED(led: SET; cnt: INTEGER);
  BEGIN
    LED.Toggle(led);
    Out.String("local NS LEDgreen toggle "); Out.Int(cnt, 10); Out.Ln;
    (*ASSERT(FALSE);*)
  END toggleLED;

  PROCEDURE toggleLED3(led: SET; cnt: INTEGER);
  BEGIN
    toggleLED(led, cnt)
  END toggleLED3;

  PROCEDURE toggleLED2(led: SET; cnt: INTEGER);
  BEGIN
    toggleLED3(led, cnt)
  END toggleLED2;

  PROCEDURE toggleLED1(led: SET; cnt: INTEGER);
  BEGIN
    toggleLED2(led, cnt)
  END toggleLED1;

  PROCEDURE toggleLED0(led: SET; cnt: INTEGER);
  BEGIN
    SYSTEM.LDREG(12, 0ABABABABH);
    toggleLED1(led, cnt)
  END toggleLED0;


  PROCEDURE run;
    VAR i, cnt: INTEGER;
  BEGIN
    cnt := 0;
    LED.Set({LED.Green});
    REPEAT
      S0.ToggleLED({LED.Red});
      toggleLED0({LED.Green}, cnt);
      INC(cnt);
      i := 0;
      WHILE i < 5000000 DO INC(i) END
    UNTIL FALSE
  END run;


BEGIN
  run
END NS.
