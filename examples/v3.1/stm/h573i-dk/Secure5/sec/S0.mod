MODULE S0;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure5
  Secure module, used from Secure and Non-secure program
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, DEV := GPIO_DEV, Out, PPB;

  CONST
    GPIOF_BSSR* = DEV.GPIOF_BASE + DEV.GPIO_BSRR_Offset;
    LEDred = 1; (* GPIOF *)

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
    (* test errors/faults for stack tracing *)
    (*ASSERT(FALSE);*)
    (* => UsageFault
    x := PPB.NVIC_ISER0 + 1;
    SYSTEM.PUT(x, x);
    *)

    SYSTEM.PUT(GPIOF_BSSR, led);
    led := led / Mask;
    Out.String("LEDred toggle across S/NS"); Out.Ln
  END toggleLED;

  PROCEDURE toggleLED2(VAR led: SET);
  BEGIN
    toggleLED(led)
  END toggleLED2;

  PROCEDURE toggleLED1(VAR led: SET);
    VAR a: ARRAY 512 OF INTEGER;
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
    (*
    r := 1.0;
    r := r / r;
    ASSERT(FALSE);
    *)
  (* +sec-epilogue *)
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
    SYSTEM.EMITH(0B005H); (* add sp, #20 *)
    SYSTEM.EMIT(0E8BD4000H); (* pop.w {lr} *)
    SYSTEM.EMITH(04774H); (* bxns lr *)
  (* -sec-epilogue *)
  END SetBits;

END S0.
