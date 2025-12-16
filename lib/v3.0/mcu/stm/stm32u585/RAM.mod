MODULE RAM;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Embedded SRAM configuration controller driver
  Wait state values: ref manual 6.3.4
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

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
    addr := MCU.RAMCFG_M1CR + (MCU.RAMCFG_Offset * sram);
    SYSTEM.GET(addr, val);
    BFI(val, 18, 16, ws);
    SYSTEM.PUT(addr, val)
  END SetWaitStates;


  PROCEDURE* init;
  (* enable bus clock *)
    CONST RAMCFGEN = 17;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.RCC_AHB1ENR, val);
    INCL(val, RAMCFGEN);
    SYSTEM.PUT(MCU.RCC_AHB1ENR, val)
  END init;

BEGIN
  init
END RAM.
