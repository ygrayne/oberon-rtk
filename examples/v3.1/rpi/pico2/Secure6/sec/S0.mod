MODULE S0;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure6
  Secure module, used from Secure and Non-secure program
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LED, Out;


  PROCEDURE testLR(x: INTEGER);
  BEGIN
    x := 42
  END testLR;


  PROCEDURE toggleLED;
  BEGIN
    LED.Set;
    Out.String("LEDred set across S/NS"); Out.Ln;
    (*ASSERT(FALSE)*)
  END toggleLED;

  PROCEDURE toggleLED2;
  BEGIN
    toggleLED
  END toggleLED2;

  PROCEDURE toggleLED1;
  BEGIN
    toggleLED2
  END toggleLED1;

  PROCEDURE toggleLED0;
  BEGIN
    toggleLED1
  END toggleLED0;


  PROCEDURE ToggleLED*;
    VAR r: REAL; x: INTEGER;
  BEGIN
    r := 1.0;
    r := r / r;
    testLR(x);
    toggleLED0;

  (* +sec-epilogue *)
    SYSTEM.EMITH(0B002H); (* add sp, #8 *)
    SYSTEM.EMIT(0E8BD4000H); (* pop.w {lr} *)
    SYSTEM.EMITH(04774H); (* bxns lr *)
  (* -sec-epilogue *)
  END ToggleLED;


END S0.
