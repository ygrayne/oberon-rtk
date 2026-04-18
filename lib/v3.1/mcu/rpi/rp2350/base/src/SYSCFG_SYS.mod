MODULE SYSCFG_SYS;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  SYSCFG
  datasheet 12.15.2, p1236
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, ACCESSCTRL_SYS;

  CONST
    SYSCFG_BASE* = BASE.SYSCFG_BASE;

    SYSCFG_PROC_CONFIG*             = SYSCFG_BASE;
    SYSCFG_PROC_IN_SYNC_BYPASS*     = SYSCFG_BASE + 004H;
    SYSCFG_PROC_IN_SYNC_BYPASS_HI*  = SYSCFG_BASE + 008H;
    SYSCFG_DBGFORCE*                = SYSCFG_BASE + 00CH;
    SYSCFG_MEMPOWERDOWN*            = SYSCFG_BASE + 010H;
    SYSCFG_AUXCTRL*                 = SYSCFG_BASE + 014H;

    (* reset *)
    SYSCFG_RST_reg* = RESETS_SYS.RESETS_RESET;
    SYSCFG_RST_pos* = RESETS_SYS.RESETS_SYSCFG;

    (* secure *)
    SYSCFG_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_SYSCFG;


END SYSCFG_SYS.
