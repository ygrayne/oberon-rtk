MODULE SYSCFG_SYS;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  SYSCFG
  datasheet 2.21.2, p304
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  
  IMPORT BASE;

  CONST
    SYSCFG_BASE* = BASE.SYSCFG_BASE;

    SYSCFG_PROC0_NMI_MASK*          = SYSCFG_BASE;
    SYSCFG_PROC1_NMI_MASK*          = SYSCFG_BASE + 004H;
    SYSCFG_PROC_CONFIG*             = SYSCFG_BASE + 008H;
    SYSCFG_PROC_IN_SYNC_BYPASS*     = SYSCFG_BASE + 00CH;
    SYSCFG_PROC_IN_SYNC_BYPASS_HI*  = SYSCFG_BASE + 010H;
    SYSCFG_DBGFORCE*                = SYSCFG_BASE + 014H;
    SYSCFG_MEMPOWERDOWN*            = SYSCFG_BASE + 018H;


END SYSCFG_SYS.
