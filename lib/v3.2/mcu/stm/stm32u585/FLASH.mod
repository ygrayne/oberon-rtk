MODULE FLASH;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Embedded flash memory controller
  Bus clock is enabled after reset
  --
  Wait state values: ref manual 7.3.3
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := FLASH_SYS;


  PROCEDURE* SetWaitStates*(ws: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(SYS.FLASH_ACR, val);
    BFI(val, 3, 0, ws);
    IF ws = 0 THEN
      BFI(val, 8, 0)
    ELSE
      BFI(val, 8, 1)
    END;
    SYSTEM.PUT(SYS.FLASH_ACR, val)
  END SetWaitStates;


(* better/safer: use STM32CubeProgrammer *)
(*
  PROCEDURE* EnableTrustZone*;
  (* MUST be run from SRAM *)
  (* see example program EnableTZ *)
  (* obviously, this runs as Non-secure code *)
  (* alternatively, use STM32CubeProgrammer *)
    VAR val: SET;
  BEGIN
    (* if TZ not yet enabled *)
    IF ~SYSTEM.BIT(SYS.FLASH_OPTR, TZEN) THEN
      (* await flash not busy *)
      REPEAT UNTIL ~SYSTEM.BIT(SYS.FLASH_NSSR, BSY);
      (* unlock flash and flash options *)
      SYSTEM.PUT(SYS.FLASH_NSKEYR, KEY_val0);
      SYSTEM.PUT(SYS.FLASH_NSKEYR, KEY_val1);
      SYSTEM.PUT(SYS.FLASH_OPTKEYR, OPTKEY_val0);
      SYSTEM.PUT(SYS.FLASH_OPTKEYR, OPTKEY_val1);
      (* modify TZEN bit *)
      SYSTEM.GET(SYS.FLASH_OPTR, val);
      INCL(val, TZEN);
      SYSTEM.PUT(SYS.FLASH_OPTR, val);
      (* start options modification *)
      SYSTEM.GET(SYS.FLASH_NSCR, val);
      INCL(val, OPTSTRT);
      SYSTEM.PUT(SYS.FLASH_NSCR, val);
      (* await flash not busy *)
      REPEAT UNTIL ~SYSTEM.BIT(SYS.FLASH_NSSR, BSY)
    END
  END EnableTrustZone;
*)

END FLASH.
