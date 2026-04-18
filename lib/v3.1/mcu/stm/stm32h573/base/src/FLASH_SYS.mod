MODULE FLASH_SYS;
(**
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE;

  CONST
    FLASH_BASE* = BASE.FLASH_BASE;

    (* core registers *)
    FLASH_ACR*          = FLASH_BASE + 000H;
    FLASH_NSKEYR*       = FLASH_BASE + 004H;
    FLASH_SECKEYR*      = FLASH_BASE + 008H;
    FLASH_OPTKEYR*      = FLASH_BASE + 00CH;
    FLASH_OPSR*         = FLASH_BASE + 018H;
    FLASH_OPTCR*        = FLASH_BASE + 01CH;
    FLASH_NSSR*         = FLASH_BASE + 020H;
    FLASH_SECSR*        = FLASH_BASE + 024H;
    FLASH_NSCR*         = FLASH_BASE + 028H;
    FLASH_SECCR*        = FLASH_BASE + 02CH;
    FLASH_NSCCR*        = FLASH_BASE + 030H;
    FLASH_SECCCR*       = FLASH_BASE + 034H;
    FLASH_PRIVCFGR*     = FLASH_BASE + 03CH;
    FLASH_HDPEXTR*      = FLASH_BASE + 048H;

    (* option byte registers *)
    FLASH_OPTSR_CUR*    = FLASH_BASE + 050H;
    FLASH_OPTSR_PRG*    = FLASH_BASE + 054H;
    FLASH_OPTSR2_CUR*   = FLASH_BASE + 070H;
    FLASH_OPTSR2_PRG*   = FLASH_BASE + 074H;
    FLASH_NSBOOTR_CUR*  = FLASH_BASE + 080H;
    FLASH_SECBOOTR_CUR* = FLASH_BASE + 088H;
    FLASH_OTPBLR_CUR*   = FLASH_BASE + 090H;

    (* bank 1: security watermark, write protection, HDP *)
    FLASH_SECBB1R*      = FLASH_BASE + 0A0H; (* 1..4, 4 bytes offset per reg *)
    FLASH_PRIVBB1R*     = FLASH_BASE + 0C0H; (* 1..4, 4 bytes offset per reg *)
    FLASH_SECWM1R_CUR*  = FLASH_BASE + 0E0H;
    FLASH_SECWM1R_PRG*  = FLASH_BASE + 0E4H;
    FLASH_WRP1R_CUR*    = FLASH_BASE + 0E8H;
    FLASH_WRP1R_PRG*    = FLASH_BASE + 0ECH;
    FLASH_EDATA1R_CUR*  = FLASH_BASE + 0F0H;
    FLASH_HDP1R_CUR*    = FLASH_BASE + 0F8H;

    (* bank 2: security watermark, write protection, HDP *)
    FLASH_SECBB2R*      = FLASH_BASE + 1A0H; (* 1..4, 4 bytes offset per reg *)
    FLASH_PRIVBB2R*     = FLASH_BASE + 1C0H; (* 1..4, 4 bytes offset per reg *)
    FLASH_SECWM2R_CUR*  = FLASH_BASE + 1E0H;
    FLASH_SECWM2R_PRG*  = FLASH_BASE + 1E4H;
    FLASH_WRP2R_CUR*    = FLASH_BASE + 1E8H;
    FLASH_WRP2R_PRG*    = FLASH_BASE + 1ECH;
    FLASH_EDATA2R_CUR*  = FLASH_BASE + 1F0H;
    FLASH_HDP2R_CUR*    = FLASH_BASE + 1F8H;

    (* ECC *)
    FLASH_ECCCORR*      = FLASH_BASE + 100H;
    FLASH_ECCDETR*      = FLASH_BASE + 104H;
    FLASH_ECCDR*        = FLASH_BASE + 108H;

    (* RCC: bus clock *)
    (* always clocked (AHB3/system bus), no explicit enable *)

    (* Secure *)
    (* each register is defined as S or NS; no separate SECCFGR *)
    (* secure watermark: FLASH_SECWMxR *)
    (* block-based security: FLASH_SECBBxR *)

END FLASH_SYS.
