MODULE RAM;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Embedded SRAM management
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

  CONST
    SRAM1* = 1;
    SRAM2* = 2;
    SRAM3* = 3;
    SRAM4* = 4;
    BKPSRAM* = 5;
    SRAM* = {1 .. 5};
    ECCSRAM* = {2, 3, 5};

(*
  PROCEDURE* SetWaitStates*(sram, ws: INTEGER);
    VAR addr, val: INTEGER;
  BEGIN
    ASSERT(sram IN SRAM, Errors.PreCond);
    addr := MCU.RAMCFG_M1CR + (MCU.RAMCFG_Offset * (sram - 1));
    SYSTEM.GET(addr, val);
    BFI(val, 18, 16, ws);
    SYSTEM.PUT(addr, val)
  END SetWaitStates;
*)

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
