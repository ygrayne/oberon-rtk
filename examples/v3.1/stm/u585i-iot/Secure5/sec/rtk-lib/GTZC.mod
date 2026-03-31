MODULE GTZC;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Global TrustZone Controller
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV0, RST;

  CONST
    SRAM1* = 0; (* 192k,  384 blocks, 12 super-blocks *)
    SRAM2* = 1; (*  64k,  128 blocks,  4 super-blocks *)
    SRAM3* = 2; (* 512k, 1024 blocks, 32 super-blocks *)
    SRAM4* = 3; (*  16k,   32 blocks,  1 super-block  *)
    SRAM* = {SRAM1 .. SRAM4};

    AllBlocksSecure* = {0 .. 31};
    AllBlocksNonSecure* = {};


  PROCEDURE* ConfigSRAMsecRange*(sram, sbStart, numSb: INTEGER; blockMap: SET);
  (* configure Secure protection of SRAM from super-block 'sbStart' for 'numSb' super-blocks *)
    VAR addr, cnt: INTEGER;
  BEGIN
    IF sram IN SRAM THEN
      CASE sram OF
        SRAM1: addr := CFG.GTZC1_MPCBB1
      | SRAM2: addr := CFG.GTZC1_MPCBB2
      | SRAM3: addr := CFG.GTZC1_MPCBB3
      | SRAM4: addr := CFG.GTZC2_MPCBB4
      END;
      addr := addr + CFG.MPCBB_SECCFGR0_Offset + (CFG.MPCBB_SECCFGR_Offset * sbStart);
      cnt := 0;
      WHILE cnt < numSb DO
        SYSTEM.PUT(addr, blockMap);
        addr := addr + CFG.MPCBB_SECCFGR_Offset;
        INC(cnt)
      END
    END
  END ConfigSRAMsecRange;


  PROCEDURE* ConfigSRAMsecAccess*(sram, enabled: INTEGER);
  (* enable/disable secure read/write Non-secure SRAM from Secure code *)
  (* flag SRWILADIS *)
    VAR addr, val: INTEGER;
  BEGIN
    IF sram IN SRAM THEN
      CASE sram OF
        SRAM1: addr := CFG.GTZC1_MPCBB1
      | SRAM2: addr := CFG.GTZC1_MPCBB2
      | SRAM3: addr := CFG.GTZC1_MPCBB3
      | SRAM4: addr := CFG.GTZC2_MPCBB4
      END;
      addr := addr + CFG.MPCBB_CR_Offset;
      SYSTEM.GET(addr, val);
      BFI(val, 31, enabled); (* SRWILADIS *)
      SYSTEM.PUT(addr, val)
    END
  END ConfigSRAMsecAccess;


  PROCEDURE* SetDevSecAll*;
  BEGIN
    SYSTEM.PUT(CFG.GTZC1_TZSC + CFG.TZSC_SECCFGR1_Offset, CFG.GTZC1_TZSC_SECCFGR1_ALL);
    SYSTEM.PUT(CFG.GTZC1_TZSC + CFG.TZSC_SECCFGR2_Offset, CFG.GTZC1_TZSC_SECCFGR2_ALL);
    SYSTEM.PUT(CFG.GTZC1_TZSC + CFG.TZSC_SECCFGR3_Offset, CFG.GTZC1_TZSC_SECCFGR3_ALL);
    SYSTEM.PUT(CFG.GTZC2_TZSC + CFG.TZSC_SECCFGR1_Offset, CFG.GTZC2_TZSC_SECCFGR1_ALL)
  END SetDevSecAll;


  PROCEDURE* SetDevSec*(secReg, secPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(secReg, val);
    SYSTEM.PUT(secReg, val + {secPos})
  END SetDevSec;


  PROCEDURE* ReleaseDevSec*(secReg, secPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(secReg, val);
    SYSTEM.PUT(secReg, val - {secPos})
  END ReleaseDevSec;


  PROCEDURE init;
  BEGIN
    RST.EnableBusClock(CFG.GTZC1_BC_reg, CFG.GTZC1_BC_pos);
    RST.EnableBusClock(CFG.GTZC2_BC_reg, CFG.GTZC2_BC_pos)
  END init;

BEGIN
  init
END GTZC.
