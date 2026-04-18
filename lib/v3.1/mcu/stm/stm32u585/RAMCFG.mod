MODULE RAMCFG;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Embedded SRAM configuration controller driver
  Wait state values: ref manual 6.3.4
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := RAMCFG_SYS, RST, Errors;

  CONST
    (* handles *)
    (* do  not assume any specific value for these handles *)
    SRAM1* = SYS.RAMCFG_SRAM1;
    SRAM2* = SYS.RAMCFG_SRAM2;
    SRAM3* = SYS.RAMCFG_SRAM3;
    SRAM4* = SYS.RAMCFG_SRAM4;
    BKPSRAM* = SYS.RAMCFG_BKPSRAM;


  PROCEDURE* SetWaitStates*(sram, ws: INTEGER);
    VAR addr, val: INTEGER;
  BEGIN
    ASSERT(sram IN SYS.RAMCFG_SRAM_all, Errors.PreCond);
    addr := SYS.RAMCFG_M1CR + (SYS.RAMCFG_Offset * (sram - 1));
    SYSTEM.GET(addr, val);
    BFI(val, 18, 16, ws);
    SYSTEM.PUT(addr, val)
  END SetWaitStates;


  PROCEDURE* GetDevSec*(VAR reg, pos: INTEGER);
  BEGIN
    reg := SYS.RAMCFG_SEC_reg;
    pos := SYS.RAMCFG_SEC_pos
  END GetDevSec;


  PROCEDURE enable;
  (* enable bus clock *)
  BEGIN
    RST.EnableBusClock(SYS.RAMCFG_BC_reg, SYS.RAMCFG_BC_pos)
  END enable;

BEGIN
  enable
END RAMCFG.
