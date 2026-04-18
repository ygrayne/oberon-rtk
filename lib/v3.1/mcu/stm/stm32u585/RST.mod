MODULE RST;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Resets and clock control via RCC
  Always clocked
  --
  MCU: STM32U585AI
  --
  MCU starts with all resets off.
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM;

  PROCEDURE* EnableBusClock*(bcEnReg, bcEnPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(bcEnReg, val);
    SYSTEM.PUT(bcEnReg, val + {bcEnPos})
  END EnableBusClock;


  PROCEDURE* DisableBusClock*(bcEnReg, bcEnPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(bcEnReg, val);
    SYSTEM.PUT(bcEnReg, val - {bcEnPos})
  END DisableBusClock;


  PROCEDURE* ConfigDevClock*(clkSelVal, clkSelReg, posSel, numBits: INTEGER);
  (* set functional/kernel clock *)
  (* use with bus clock disabled *)
    VAR mask, val, sel: SET;
  BEGIN
    clkSelVal := LSR(LSL(clkSelVal, 32 - numBits), 32 - numBits);
    mask := {posSel, posSel + numBits - 1};
    sel := BITS(LSL(clkSelVal, posSel));
    SYSTEM.GET(clkSelReg, val);
    val := val - mask + sel;
    SYSTEM.PUT(clkSelReg, val)
  END ConfigDevClock;


  PROCEDURE* ApplyReset*(rstEnReg, rstEnPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(rstEnReg, val);
    SYSTEM.PUT(rstEnReg, val + {rstEnPos})
  END ApplyReset;


  PROCEDURE* ReleaseReset*(rstEnReg, rstEnPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(rstEnReg, val);
    SYSTEM.PUT(rstEnReg, val - {rstEnPos})
  END ReleaseReset;

END RST.

