MODULE S0;
(**
  Oberon RTK Framework v3.0
  --
  Experimental program Secure5
  https://oberon-rtk.org/docs/examples/v3/secure5/
  Secure module, used from Secure and Non-secure program
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, DEV2, Out;

  CONST
    GPIOH_BSSR* = DEV2.GPIOH_BASE + DEV2.GPIO_BSRR_Offset;
    LEDred = 6; (* GPIOH *)

  TYPE
    TwoBits* = RECORD
      pin*: INTEGER;
      addr*: INTEGER;
      value*: INTEGER
    END;


  PROCEDURE testLR(x: INTEGER);
  BEGIN
    x := 42
  END testLR;


  PROCEDURE toggleLED(VAR led: SET);
    CONST Mask = {LEDred, LEDred + 16};
    VAR x: INTEGER;
  BEGIN
    (*ASSERT(FALSE);*)
    (*
    x := PPB.NVIC_ISER0 + 1;
    SYSTEM.PUT(x, x);
    *)
    SYSTEM.PUT(GPIOH_BSSR, led);
    led := led / Mask;
    Out.String("LEDred toggle across S/NS"); Out.Ln
  END toggleLED;

  PROCEDURE toggleLED2(VAR led: SET);
  BEGIN
    toggleLED(led)
  END toggleLED2;

  PROCEDURE toggleLED1(VAR led: SET);
  BEGIN
    toggleLED2(led)
  END toggleLED1;

  PROCEDURE toggleLED0(VAR led: SET);
  BEGIN
    toggleLED1(led)
  END toggleLED0;

  PROCEDURE ToggleLED*(VAR led: SET);
    VAR a: ARRAY 1024 OF INTEGER; r: REAL;
  BEGIN
    toggleLED0(led);
    r := 1.0;
    r := r / r;

  (* +sec-epilogue *)
    SYSTEM.LDREG(0, 0); (* clear r0 *)
    SYSTEM.LDREG(1, 0); (* clear r1 *)
    SYSTEM.LDREG(2, 0); (* clear r2 *)
    SYSTEM.LDREG(3, 0); (* clear r3 *)
    SYSTEM.LDREG(4, 0); (* clear r4 *)
    SYSTEM.LDREG(5, 0); (* clear r5 *)
    SYSTEM.LDREG(6, 0); (* clear r6 *)
    SYSTEM.LDREG(7, 0); (* clear r7 *)
    SYSTEM.LDREG(8, 0); (* clear r8 *)
    SYSTEM.LDREG(9, 0); (* clear r9 *)
    SYSTEM.LDREG(10, 0); (* clear r10 *)
    SYSTEM.LDREG(11, 0); (* clear r11 *)
    SYSTEM.EMIT(0F3808800H); (* msr APSR_nzcvq, r0 *)
    SYSTEM.EMIT(0EC411B10H); (* vmov d0, r1, r1 *)
    SYSTEM.EMIT(0EC411B11H); (* vmov d1, r1, r1 *)
    SYSTEM.EMIT(0EC411B12H); (* vmov d2, r1, r1 *)
    SYSTEM.EMIT(0EC411B13H); (* vmov d3, r1, r1 *)
    SYSTEM.EMIT(0EC411B14H); (* vmov d4, r1, r1 *)
    SYSTEM.EMIT(0EC411B15H); (* vmov d5, r1, r1 *)
    SYSTEM.EMIT(0EC411B16H); (* vmov d6, r1, r1 *)
    SYSTEM.EMIT(0EC411B17H); (* vmov d7, r1, r1 *)
    SYSTEM.EMIT(0EC411B18H); (* vmov d8, r1, r1 *)
    SYSTEM.EMIT(0EC411B19H); (* vmov d9, r1, r1 *)
    SYSTEM.EMIT(0EC411B1AH); (* vmov d10, r1, r1 *)
    SYSTEM.EMIT(0EC411B1BH); (* vmov d11, r1, r1 *)
    SYSTEM.EMIT(0EC411B1CH); (* vmov d12, r1, r1 *)
    SYSTEM.EMIT(0EC411B1DH); (* vmov d13, r1, r1 *)
    SYSTEM.EMIT(0EC411B1EH); (* vmov d14, r1, r1 *)
    SYSTEM.EMIT(0EC411B1FH); (* vmov d15, r1, r1 *)
    SYSTEM.EMIT(0EEE11A10H); (* vmsr FPSCR, r1 *)
    SYSTEM.EMIT(0F50D5D80H); (* add.w sp, sp, #4096 *)
    SYSTEM.EMITH(0B002H); (* add sp, #8 *)
    SYSTEM.EMIT(0E8BD4000H); (* pop.w {lr} *)
    SYSTEM.EMITH(04774H); (* bxns lr *)
  (* -sec-epilogue *)
  END ToggleLED;


  PROCEDURE SetBits*(twoBits: TwoBits);
  (* could be leaf, but is not for testing purposes *)
    VAR val, mask: SET; value: INTEGER;
  BEGIN
    value := twoBits.value;
    value := value MOD 04H;
    value := LSL(value, twoBits.pin * 2);
    SYSTEM.GET(twoBits.addr, val);
    mask := BITS(LSL(03H, twoBits.pin * 2));
    val := val * (-mask);
    val := val + BITS(value);
    SYSTEM.PUT(twoBits.addr, val);
    testLR(42);

  (* +sec-epilogue *)
    SYSTEM.LDREG(0, 0); (* clear r0 *)
    SYSTEM.LDREG(1, 0); (* clear r1 *)
    SYSTEM.LDREG(2, 0); (* clear r2 *)
    SYSTEM.LDREG(3, 0); (* clear r3 *)
    SYSTEM.LDREG(4, 0); (* clear r4 *)
    SYSTEM.LDREG(5, 0); (* clear r5 *)
    SYSTEM.LDREG(6, 0); (* clear r6 *)
    SYSTEM.LDREG(7, 0); (* clear r7 *)
    SYSTEM.LDREG(8, 0); (* clear r8 *)
    SYSTEM.LDREG(9, 0); (* clear r9 *)
    SYSTEM.LDREG(10, 0); (* clear r10 *)
    SYSTEM.LDREG(11, 0); (* clear r11 *)
    SYSTEM.EMIT(0F3808800H); (* msr APSR_nzcvq, r0 *)
    SYSTEM.EMITH(0B005H); (* add sp, #20 *)
    SYSTEM.EMIT(0E8BD4000H); (* pop.w {lr} *)
    SYSTEM.EMITH(04774H); (* bxns lr *)
  (* -sec-epilogue *)
  END SetBits;

END S0.
