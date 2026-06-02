MODULE S0;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure
  Secure module, used from Non-secure program across NSC veneers
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LED, Out;

  PROCEDURE testLR(VAR x: INTEGER);
  BEGIN
    x := 42
  END testLR;


  PROCEDURE toggleLED(led: SET);
  BEGIN
    LED.Toggle(led);
    Out.String("LEDred toggle across S/NS"); Out.Ln;
    (*ASSERT(FALSE)*)
  END toggleLED;

  PROCEDURE toggleLED2(led: SET);
  BEGIN
    toggleLED(led)
  END toggleLED2;

  PROCEDURE toggleLED1(led: SET);
  BEGIN
    toggleLED2(led)
  END toggleLED1;

  PROCEDURE toggleLED0(led: SET);
  BEGIN
    toggleLED1(led)
  END toggleLED0;

  PROCEDURE ToggleLED*(led: SET);
    (* unused array to detect false positives *)
    VAR a: ARRAY 1024 OF INTEGER; r: REAL; x: INTEGER;
  BEGIN
    r := 1.0;
    r := r / r;
    toggleLED0(led);
    testLR(x);

  (* +sec-epilogue *)
    SYSTEM.EMIT(0F50D5D80H); (* add.w sp, sp, #4096 *)
    SYSTEM.EMITH(0B003H); (* add sp, #12 *)
    SYSTEM.EMIT(0E8BD4000H); (* pop.w {lr} *)
    SYSTEM.EMITH(04774H); (* bxns lr *)
  (* -sec-epilogue *)
  END ToggleLED;

END S0.
