MODULE NS;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure5
  Non-secure program, uses Secure module S0
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, DEV := GPIO_DEV, S0 := NS_S0, Out;

  CONST
    (* Non-secure GPIOF registers, due to correct (NS) BASE.mod picked via lib search path *)
    GPIOF_BSSR = DEV.GPIOF_BASE + DEV.GPIO_BSRR_Offset;
    GPIOF_MODER = DEV.GPIOF_BASE + DEV.GPIO_MODER_Offset;
    GPIOF_OSPEEDR = DEV.GPIOF_BASE + DEV.GPIO_OSPEEDR_Offset;

    LEDred   = 1;
    LEDblue = 4;
    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE cfgGPIO; (* Non-secure part *)
  (* set-up GPIOH for Non-secure pin LEDblue *)
    VAR twoBits: S0.TwoBits;
  BEGIN
    (*ASSERT(FALSE);*)
    (* bus clock has been enabled by Secure program *)
    (* GPIOH pin has been set Non-secure by Secure program *)
    twoBits.pin := LEDblue;
    twoBits.addr := GPIOF_MODER;
    twoBits.value := MODER_Out;
    S0.SetBits(twoBits);
    twoBits.addr := GPIOF_OSPEEDR;
    twoBits.value := OSPEED_High;
    S0.SetBits(twoBits);

    (* LEDblue off *)
    SYSTEM.PUT(GPIOF_BSSR, {LEDblue});
    (*ASSERT(FALSE)*)
  END cfgGPIO;


  PROCEDURE toggleLED(VAR led: SET; cnt: INTEGER);
    CONST Mask = {LEDblue, LEDblue + 16};
  BEGIN
    SYSTEM.PUT(GPIOF_BSSR, led);
    led := led / Mask;
    Out.String("local NS LEDblue toggle "); Out.Int(cnt, 10); Out.Ln;
    (*ASSERT(FALSE)*)
  END toggleLED;

  PROCEDURE toggleLED3(VAR led: SET; cnt: INTEGER);
  BEGIN
    toggleLED(led, cnt)
  END toggleLED3;

  PROCEDURE toggleLED2(VAR led: SET; cnt: INTEGER);
  BEGIN
    toggleLED3(led, cnt)
  END toggleLED2;

  PROCEDURE toggleLED1(VAR led: SET; cnt: INTEGER);
  BEGIN
    toggleLED2(led, cnt)
  END toggleLED1;

  PROCEDURE toggleLED0(VAR led: SET; cnt: INTEGER);
  BEGIN
    toggleLED1(led, cnt)
  END toggleLED0;


  PROCEDURE run;
    VAR i, cnt: INTEGER; ledRed, ledBlue: SET;
  BEGIN
    ledRed := {LEDred};
    ledBlue := {LEDblue + 16};
    cnt := 0;
    REPEAT
      S0.ToggleLED(ledRed);
      toggleLED0(ledBlue, cnt);
      INC(cnt);
      i := 0;
      WHILE i < 5000000 DO INC(i) END
    UNTIL FALSE
  END run;


BEGIN
  Out.String("start NS"); Out.Ln;
  cfgGPIO;
  run
END NS.
