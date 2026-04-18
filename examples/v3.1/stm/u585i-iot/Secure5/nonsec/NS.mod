MODULE NS;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure5
  Non-secure program, uses Secure module S0
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, DEV := GPIO_DEV, S0 := NS_S0, Out;

  CONST
    (* Non-secure GPIOH registers, due to correct (NS) MCU.mod picked via lib search path *)
    GPIOH_BSSR = DEV.GPIOH_BASE + DEV.GPIO_BSRR_Offset;
    GPIOH_MODER = DEV.GPIOH_BASE + DEV.GPIO_MODER_Offset;
    GPIOH_OSPEEDR = DEV.GPIOH_BASE + DEV.GPIO_OSPEEDR_Offset;

    LEDgreen = 7; (* GPIOH *)
    LEDred   = 6;
    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE cfgGPIO; (* Non-secure part *)
  (* set-up GPIOH for Non-secure pin LEDgreen *)
    VAR twoBits: S0.TwoBits;
  BEGIN
    (*ASSERT(FALSE);*)
    (* bus clock has been enabled by Secure program *)
    (* GPIOH pin has been set Non-secure by Secure program *)
    twoBits.pin := LEDgreen;
    twoBits.addr := GPIOH_MODER;
    twoBits.value := MODER_Out;
    S0.SetBits(twoBits);
    twoBits.addr := GPIOH_OSPEEDR;
    twoBits.value := OSPEED_High;
    S0.SetBits(twoBits);

    (* LEDgreen off *)
    SYSTEM.PUT(GPIOH_BSSR, {LEDgreen});
    (*ASSERT(FALSE)*)
  END cfgGPIO;


  PROCEDURE toggleLED(VAR led: SET; cnt: INTEGER);
    CONST Mask = {LEDgreen, LEDgreen + 16};
  BEGIN
    (*ASSERT(FALSE);*)
    SYSTEM.PUT(GPIOH_BSSR, led);
    led := led / Mask;
    Out.String("local NS LEDgreen toggle "); Out.Int(cnt, 10); Out.Ln;

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
    SYSTEM.LDREG(12, 0ABABABABH);
    toggleLED1(led, cnt)
  END toggleLED0;


  PROCEDURE run;
    VAR i, cnt: INTEGER; ledRed, ledGreen: SET;
  BEGIN
    ledRed := {LEDred};
    ledGreen := {LEDgreen + 16};
    cnt := 0;
    REPEAT
      S0.ToggleLED(ledRed);
      toggleLED0(ledGreen, cnt);
      INC(cnt);
      i := 0;
      WHILE i < 5000000 DO INC(i) END
    UNTIL FALSE
  END run;


BEGIN
  cfgGPIO;
  run
END NS.
