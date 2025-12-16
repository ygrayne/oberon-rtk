MODULE FLASH;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Embedded flash memory controller driver
  Bus clock is enabled after reset
  --
  Type: MCU
  --
  Wait state values: ref manual 7.3.4
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* FLASH_ACR bits and values *)
    FLASH_ACR_PRFTEN = 8;

  PROCEDURE* SetWaitStates*(ws: INTEGER);
    CONST Mask = {0 .. 3, 8};
    VAR val, checkValue: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.FLASH_ACR, val);
    BFI(val, 3, 0, ws);
    checkValue := ws;
    IF ws = 0 THEN
      BFI(val, FLASH_ACR_PRFTEN, 0);
    ELSE
      BFI(val, FLASH_ACR_PRFTEN, 1);
      checkValue := checkValue + ORD({FLASH_ACR_PRFTEN})
    END;
    SYSTEM.PUT(MCU.FLASH_ACR, val);
    REPEAT
      SYSTEM.GET(MCU.FLASH_ACR, val)
    UNTIL BITS(val) * Mask = BITS(checkValue)
  END SetWaitStates;

END FLASH.
