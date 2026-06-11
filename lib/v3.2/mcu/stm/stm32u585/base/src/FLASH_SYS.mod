MODULE FLASH_SYS;
(**
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE;
  
  CONST
    FLASH_BASE* = BASE.FLASH_BASE;

    FLASH_ACR*          = FLASH_BASE + 000H;
    FLASH_NSKEYR*       = FLASH_BASE + 008H;
    FLASH_SECKEYR*      = FLASH_BASE + 00CH;
    FLASH_OPTKEYR*      = FLASH_BASE + 010H;
    FLASH_PDKEY1R*      = FLASH_BASE + 018H;
    FLASH_PDKEY2R*      = FLASH_BASE + 01CH;
    FLASH_NSSR*         = FLASH_BASE + 020H;
    FLASH_SECSR*        = FLASH_BASE + 024H;
    FLASH_NSCR*         = FLASH_BASE + 028H;
    FLASH_SECCR*        = FLASH_BASE + 02CH;
    FLASH_ECCR*         = FLASH_BASE + 030H;
    FLASH_OPSR*         = FLASH_BASE + 034H;
    FLASH_OPTR*         = FLASH_BASE + 040H;
    FLASH_NSBOOTADD0R*  = FLASH_BASE + 044H;
    FLASH_NSBOOTADD1R*  = FLASH_BASE + 048H;
    FLASH_SECBOOTADD0R* = FLASH_BASE + 04CH;
    FLASH_SECWM1R1*     = FLASH_BASE + 050H;
    FLASH_SECWM1R2*     = FLASH_BASE + 054H;
    FLASH_WRP1AR*       = FLASH_BASE + 058H;
    FLASH_WRP1BR*       = FLASH_BASE + 05CH;
    FLASH_SECWM2R1*     = FLASH_BASE + 060H;
    FLASH_SECWM2R2*     = FLASH_BASE + 064H;
    FLASH_WRP2AR*       = FLASH_BASE + 068H;
    FLASH_WRP2BR*       = FLASH_BASE + 06CH;
    FLASH_OEM1KEYR1*    = FLASH_BASE + 070H;
    FLASH_OEM1KEYR2*    = FLASH_BASE + 074H;
    FLASH_OEM2KEYR1*    = FLASH_BASE + 078H;
    FLASH_OEM2KEYR2*    = FLASH_BASE + 07CH;

    FLASH_SECBB1R*      = FLASH_BASE + 080H; (* 0 .. 7, 4 bytes offset per page *)
    FLASH_SECBB2R*      = FLASH_BASE + 0A0H; (* 0 .. 7, 4 bytes offset per page *)

    FLASH_SECHDPCR*     = FLASH_BASE + 0C0H;
    FLASH_PRIVCFGR*     = FLASH_BASE + 0C4H;

    FLASH_PRIVBB1R*     = FLASH_BASE + 0D0H; (* 0 .. 7, 4 bytes offset per page *)
    FLASH_PRIVBB2R*     = FLASH_BASE + 0F0H; (* 0 .. 7, 4 bytes offset per page *)

    (* bus clock *)
    (* is enabled after reset *)

    (* Secure *)
    (* each register is defined as S or NS *)
END FLASH_SYS.
