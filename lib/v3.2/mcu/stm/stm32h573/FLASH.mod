MODULE FLASH;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Embedded flash memory controller driver
  Bus clock is enabled after reset
  --
  Wait state values: ref manual 7.3.4
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := FLASH_SYS;


  PROCEDURE* SetWaitStates*(ws: INTEGER);
    CONST Mask = {0 .. 3, 8};
    VAR val, checkValue: INTEGER;
  BEGIN
    SYSTEM.GET(SYS.FLASH_ACR, val);
    BFI(val, 3, 0, ws);
    checkValue := ws;
    IF ws = 0 THEN
      BFI(val, 8, 0);
    ELSE
      BFI(val, 8, 1);
      checkValue := checkValue + ORD({8})
    END;
    SYSTEM.PUT(SYS.FLASH_ACR, val);
    REPEAT
      SYSTEM.GET(SYS.FLASH_ACR, val)
    UNTIL BITS(val) * Mask = BITS(checkValue)
  END SetWaitStates;

END FLASH.
