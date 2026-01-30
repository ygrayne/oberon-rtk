(*! SEC *)
MODULE S0;
(**
  Oberon RTK Framework v3.0
  --
  Experimental program Secure1
  https://oberon-rtk.org/docs/examples/v3/secure1/
  Secure module, used from Secure and Non-secure program
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    GPIOH_BSSR = MCU.GPIOH_BASE + MCU.GPIO_BSRR_Offset + MCU.PERI_S_Offset;

    LEDred   = 6; (* GPIOH *)


  PROCEDURE testLR(x: INTEGER);
  BEGIN
    x := 42
  END testLR;


  PROCEDURE* ToggleLED*(VAR led: SET);
    CONST Mask = {LEDred, LEDred + 16};
  BEGIN
    SYSTEM.PUT(GPIOH_BSSR, led);
    led := led / Mask;

    (* manually inserted Secure epilogue *)
    (* no add sp,#n as leaf procedure *)
    SYSTEM.EMIT(MCU.POP_LR);
    SYSTEM.EMITH(MCU.BXNS_LR) (* ok within Secure code *)
  END ToggleLED;


  PROCEDURE SetBits2*(pin, addr, twoBitValue: INTEGER);
  (* could be leaf, but is not for testing purposes *)
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
    SYSTEM.EMITH(MCU.ADD_SP + 05H); (* add sp,#20 *)
    SYSTEM.EMIT(MCU.POP_LR);
    SYSTEM.EMITH(MCU.BXNS_LR)
  END SetBits2;


  PROCEDURE Test*(x, v: INTEGER);
    VAR z: INTEGER;
  BEGIN
    (* ... stuff ... *)
    (* manually inserted Secure epilogue *)
    SYSTEM.EMITH(MCU.ADD_SP + 03H); (* add sp,#12 *)
    SYSTEM.EMIT(MCU.POP_LR);
    SYSTEM.EMITH(MCU.BXNS_LR)
  END Test;

END S0.
