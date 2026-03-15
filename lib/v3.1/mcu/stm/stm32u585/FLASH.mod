MODULE FLASH;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Embedded flash memory controller
  Bus clock is enabled after reset
  --
  Type: MCU
  --
  Wait state values: ref manual 7.3.3
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    FLASH1* = 0;
    FLASH2* = 1;
    FLASH = {0, 1};

    (* FLASH_ACR bits and values *)
    FLASH_ACR_PRFTEN = 8;

    (* for FLASH_SECKEYR or FLASH_NSKEYR *)
    KEY_val0*     = 045670123H;
    KEY_val1*     = 0CDEF89ABH;

    (* for FLASH_OPTKEYR *)
    OPTKEY_val0*  = 08192A3BH;
    OPTKEY_val1*  = 4C5D6E7FH;

    (* for FLASH_OPTR *)
    TZEN* = 31;

    (* for FLASH_NSSR *)
    BSY* = 16;

    (* for FLASH_NSCR *)
    OPTSTRT* = 17;
    OBL_LAUNCH* = 27;


  PROCEDURE* SetWaitStates*(ws: INTEGER);
  (* S/NS code *)
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



  PROCEDURE* EnableTrustZone*;
  (* MUST be run from SRAM *)
  (* see example program EnableTZ *)
  (* obviously, this runs as Non-secure code *)
  (* alternatively, use STM32CubeProgrammer *)
    VAR val: SET;
  BEGIN
    (* if TZ not yet enabled *)
    IF ~SYSTEM.BIT(MCU.FLASH_OPTR, TZEN) THEN
      (* await flash not busy *)
      REPEAT UNTIL ~SYSTEM.BIT(MCU.FLASH_NSSR, BSY);
      (* unlock flash and flash options *)
      SYSTEM.PUT(MCU.FLASH_NSKEYR, KEY_val0);
      SYSTEM.PUT(MCU.FLASH_NSKEYR, KEY_val1);
      SYSTEM.PUT(MCU.FLASH_OPTKEYR, OPTKEY_val0);
      SYSTEM.PUT(MCU.FLASH_OPTKEYR, OPTKEY_val1);
      (* modify TZEN bit *)
      SYSTEM.GET(MCU.FLASH_OPTR, val);
      INCL(val, TZEN);
      SYSTEM.PUT(MCU.FLASH_OPTR, val);
      (* start options modification *)
      SYSTEM.GET(MCU.FLASH_NSCR, val);
      INCL(val, OPTSTRT);
      SYSTEM.PUT(MCU.FLASH_NSCR, val);
      (* await flash not busy *)
      REPEAT UNTIL ~SYSTEM.BIT(MCU.FLASH_NSSR, BSY)
    END
  END EnableTrustZone;

END FLASH.
