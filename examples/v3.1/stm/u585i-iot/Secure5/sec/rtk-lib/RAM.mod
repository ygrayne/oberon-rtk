MODULE RAM;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Embedded SRAM configuration controller driver
  Wait state values: ref manual 6.3.4
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV0, RST, Errors;

  CONST
    SRAM1* = 0;
    SRAM2* = 1;
    SRAM3* = 2;
    SRAM4* = 3;
    BKPSRAM* = 4;
    SRAM* = {SRAM1 .. BKPSRAM};
    ECCSRAM* = {SRAM2, SRAM3, BKPSRAM};


  PROCEDURE* SetWaitStates*(sram, ws: INTEGER);
    VAR addr, val: INTEGER;
  BEGIN
    ASSERT(sram IN SRAM, Errors.PreCond);
    addr := CFG.RAMCFG_M1CR + (CFG.RAMCFG_Offset * sram);
    SYSTEM.GET(addr, val);
    BFI(val, 18, 16, ws);
    SYSTEM.PUT(addr, val)
  END SetWaitStates;


  PROCEDURE* GetDevSec*(VAR reg, pos: INTEGER);
  BEGIN
    reg := CFG.RAMCFG_SEC_reg;
    pos := CFG.RAMCFG_SEC_pos
  END GetDevSec;


  PROCEDURE init;
  (* enable bus clock *)
  BEGIN
    RST.EnableBusClock(CFG.RAMCFG_BC_reg, CFG.RAMCFG_BC_pos)
  END init;

BEGIN
  init
END RAM.
