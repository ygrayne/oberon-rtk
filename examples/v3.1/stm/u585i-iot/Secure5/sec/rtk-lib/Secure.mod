MODULE Secure;
(**
  Oberon RTK Framework
  Version: v3.1
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

  IMPORT SYSTEM, PPB;

  PROCEDURE* StartNonSecProg*(imageAddr, vtorOffset: INTEGER);
    VAR val: INTEGER;
  BEGIN
    (* VTOR *)
    SYSTEM.PUT(PPB.VTOR + PPB.PPB_NS_Offset, imageAddr + vtorOffset);
    (* stack pointer *)
    SYSTEM.GET(imageAddr + vtorOffset, val);
    (* asm
      val -> msr msp_ns, r11
    end asm *)
    (* +asm *)
    SYSTEM.LDREG(11, val);  (* val -> r11 *)
    SYSTEM.EMIT(0F38B8888H);  (* msr MSP_NS, r11 *)
    (* -asm *)
    (* branch to NS entry *)
    SYSTEM.GET(imageAddr  + vtorOffset + 04H, val);
    EXCL(SYSTEM.VAL(SET, val), 0);
    (* asm
      val -> blxns r11
    end asm *)
    (* +asm *)
    SYSTEM.LDREG(11, val);  (* val -> r11 *)
    SYSTEM.EMITH(047DCH);  (* blxns r11 *)
    (* -asm *)
  END StartNonSecProg;


  PROCEDURE IsNonSecMemory*(addr, size: INTEGER): BOOLEAN;
  RETURN FALSE
  END IsNonSecMemory;

  PROCEDURE IsNonSecProc*(addr: INTEGER): BOOLEAN;
  RETURN FALSE
  END IsNonSecProc;

END Secure.
