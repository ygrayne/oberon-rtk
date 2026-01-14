(*! SEC *)
MODULE S0;
(**
  Oberon RTK Framework v3.0
  --
  Experimental program
  https://oberon-rtk.org/docs/examples/v3/secure0/
  Secure code
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main;

  CONST
    GPIOH_BSSR = MCU.GPIOH_BASE + MCU.GPIO_BSRR_Offset;

    LEDgreen = 7; (* GPIOH *)
    LEDred   = 6;

    POP_LR = 0E8BD4000H;
    BX_LR = 04770H;


  PROCEDURE testLR(x: INTEGER);
  END testLR;


  PROCEDURE* ToggleLED*(VAR leds: SET);
    CONST Mask = {LEDred, LEDgreen, LEDred + 16, LEDgreen + 16};
  BEGIN
    SYSTEM.PUT(GPIOH_BSSR, leds);
    leds := leds / Mask;

    (* manually inserted Secure epilogue *)
    (* no add sp,#n as leaf procedure *)
    SYSTEM.EMIT(POP_LR);
    SYSTEM.EMITH(BX_LR)
  END ToggleLED;


  PROCEDURE SetBits2*(pin, addr, twoBitValue: INTEGER);
    VAR val, mask: SET;
  BEGIN
    twoBitValue := twoBitValue MOD 04H;
    twoBitValue := LSL(twoBitValue, pin * 2);
    SYSTEM.GET(addr, val);
    mask := BITS(LSL(03H, pin * 2));
    val := val * (-mask);
    val := val + BITS(twoBitValue);
    SYSTEM.PUT(addr, val);
    testLR(42);

    (* manually inserted Secure epilogue *)
    SYSTEM.EMITH(0B005H); (* add sp,#20 *)
    SYSTEM.EMIT(POP_LR);
    SYSTEM.EMITH(BX_LR)
  END SetBits2;


  PROCEDURE Test*(x, v: INTEGER);
    VAR z: INTEGER;
  BEGIN
    (* stuff *)
    (* manually inserted Secure epilogue *)
    SYSTEM.EMITH(0B003H); (* add sp,#12 *)
    SYSTEM.EMIT(POP_LR);
    SYSTEM.EMITH(BX_LR)
  END Test;

END S0.
