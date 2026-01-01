MODULE FLASH;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Embedded flash memory controller driver
  --
  Type: MCU
  --
  MCU: MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* wait states at freq WS_* *)
    WS_200* = 4;
    WS_160* = 3;
    WS_120* = 2;
    WS_80*  = 1;
    WS_40*  = 0;


  PROCEDURE* SetWaitStates*(ws: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.FMU_FCTRL, val);
    BFI(val, 3, 0, ws);
    SYSTEM.PUT(MCU.FMU_FCTRL, val)
  END SetWaitStates;

END FLASH.
