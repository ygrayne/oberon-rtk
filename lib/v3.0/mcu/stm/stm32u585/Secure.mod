MODULE Secure;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Secure/Non-secure support
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  PROCEDURE* StartNonSecure*(imageAddr: INTEGER);
    CONST R11 = 11;
    VAR val: INTEGER;
  BEGIN
    (* VTOR *)
    SYSTEM.PUT(MCU.PPB_VTOR + MCU.PPB_NS_Offset, imageAddr);
    (* stack pointer *)
    SYSTEM.GET(imageAddr, val);
    SYSTEM.LDREG(R11, val);
    SYSTEM.EMIT(MCU.MSR_MSPns_R11);
    (* branch to NS entry *)
    SYSTEM.GET(imageAddr + 04H, val);
    EXCL(SYSTEM.VAL(SET, val), 0);
    SYSTEM.LDREG(R11, val);
    SYSTEM.EMITH(MCU.BLXNS_R11)
  END StartNonSecure;

END Secure.
