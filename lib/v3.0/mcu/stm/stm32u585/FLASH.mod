MODULE FLASH;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Embedded flash memory
  Bus clock is enabled after reset
  --
  Wait state values: ref manual 7.3.3
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* FLASH_ACR bits and values *)
    FLASH_ACR_PRFTEN = 8;

  PROCEDURE* SetWaitStates*(ws: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.FLASH_ACR, val);
    BFI(val, 3, 0, ws);
    IF ws = 0 THEN
      BFI(val, FLASH_ACR_PRFTEN, 0)
    ELSE
      BFI(val, FLASH_ACR_PRFTEN, 1)
    END;
    SYSTEM.PUT(MCU.FLASH_ACR, val)
  END SetWaitStates;


END FLASH.
