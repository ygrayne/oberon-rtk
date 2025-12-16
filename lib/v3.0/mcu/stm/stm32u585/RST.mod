MODULE RST;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Resets via RCC
  Always clocked
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  MCU starts with all resets off.
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  PROCEDURE* ApplyReset*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER; val: SET;
  BEGIN
    reg := device DIV 32;
    reg := MCU.RCC_AHB1RSTR + (reg * 4);
    IF reg > MCU.RCC_AHB3RSTR THEN INC(reg, 4) END; (* register address gap *)
    devNo := device MOD 32;
    SYSTEM.GET(reg, val);
    INCL(val, devNo);
    SYSTEM.PUT(reg, val)
  END ApplyReset;


  PROCEDURE* ReleaseReset*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER; val: SET;
  BEGIN
    reg := device DIV 32;
    reg := MCU.RCC_AHB1RSTR + (reg * 4);
    IF reg > MCU.RCC_AHB3RSTR THEN INC(reg, 4) END; (* register address gap *)
    devNo := device MOD 32;
    SYSTEM.GET(reg, val);
    EXCL(val, devNo);
    SYSTEM.PUT(reg, val)
  END ReleaseReset;

END RST.

