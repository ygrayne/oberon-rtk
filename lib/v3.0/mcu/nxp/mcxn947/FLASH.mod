MODULE FLASH;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Embedded flash memory controller driver
  --
  Type: MCU
  --
  MCU: MCXN947
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* wait states at freq WS_* *)
    WS_OD_150*  = 3; (* reset value *)
    WS_OD_100*  = 2;
    WS_OD_64*   = 1;
    WS_OD_36*   = 0;

    WS_SD_100*  = WS_OD_100;
    WS_SD_64*   = WS_OD_64;
    WS_SD_36*   = WS_OD_36;

    WS_MD_50*   = WS_OD_64;
    WS_MD_24*   = WS_OD_36;


  PROCEDURE* SetWaitStates*(ws: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.FMU_FCTRL, val);
    BFI(val, 3, 0, ws);
    SYSTEM.PUT(MCU.FMU_FCTRL, val)
  END SetWaitStates;

END FLASH.
