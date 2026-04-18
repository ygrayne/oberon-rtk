MODULE GTZC;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Global TrustZone Controller
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := GTZC_SYS, RST;

  CONST
    (* handles *)
    (* do  not assume any specific value for these handles *)
    SRAM1* = SYS.GTZC_SRAM1; (* 256k, 512 blocks, 16 super-blocks *)
    SRAM2* = SYS.GTZC_SRAM2; (*  64k, 128 blocks,  4 super-blocks *)
    SRAM3* = SYS.GTZC_SRAM3; (* 320k, 640 blocks, 20 super-blocks *)

    (* number of blocks and super-blocks *)
    SRAM1_blk* = 512; SRAM1_sblk* = 16;
    SRAM2_blk* = 128; SRAM2_sblk* = 4;
    SRAM3_blk* = 640; SRAM3_sblk* = 20;

    AllBlocksSecure* = {0 .. 31};
    AllBlocksNonSecure* = {};


  PROCEDURE* ConfigSRAMsecRange*(sram, sbStart, numSb: INTEGER; blockMap: SET);
  (* configure Secure protection of SRAM from super-block 'sbStart' for 'numSb' super-blocks *)
    VAR addr, cnt: INTEGER;
  BEGIN
    IF sram IN SYS.GTZC_SRAM_all THEN
      CASE sram OF
        SRAM1: addr := SYS.GTZC1_MPCBB1
      | SRAM2: addr := SYS.GTZC1_MPCBB2
      | SRAM3: addr := SYS.GTZC1_MPCBB3
      END;
      addr := addr + SYS.MPCBB_SECCFGR0_Offset + (SYS.MPCBB_SECCFGR_Offset * sbStart);
      cnt := 0;
      WHILE cnt < numSb DO
        SYSTEM.PUT(addr, blockMap);
        addr := addr + SYS.MPCBB_SECCFGR_Offset;
        INC(cnt)
      END
    END
  END ConfigSRAMsecRange;


  PROCEDURE* ConfigSRAMsecAccess*(sram, enabled: INTEGER);
  (* enable/disable secure read/write Non-secure SRAM from Secure code *)
  (* flag SRWILADIS *)
    VAR addr, val: INTEGER;
  BEGIN
    IF sram IN SYS.GTZC_SRAM_all THEN
      CASE sram OF
        SRAM1: addr := SYS.GTZC1_MPCBB1
      | SRAM2: addr := SYS.GTZC1_MPCBB2
      | SRAM3: addr := SYS.GTZC1_MPCBB3
      END;
      addr := addr + SYS.MPCBB_CR_Offset;
      SYSTEM.GET(addr, val);
      BFI(val, 31, enabled); (* SRWILADIS *)
      SYSTEM.PUT(addr, val)
    END
  END ConfigSRAMsecAccess;


  PROCEDURE* SetDevSecAll*;
  BEGIN
    SYSTEM.PUT(SYS.GTZC1_TZSC + SYS.TZSC_SECCFGR1_Offset, SYS.GTZC1_TZSC_SECCFGR1_ALL);
    SYSTEM.PUT(SYS.GTZC1_TZSC + SYS.TZSC_SECCFGR2_Offset, SYS.GTZC1_TZSC_SECCFGR2_ALL);
    SYSTEM.PUT(SYS.GTZC1_TZSC + SYS.TZSC_SECCFGR3_Offset, SYS.GTZC1_TZSC_SECCFGR3_ALL);
  END SetDevSecAll;


  PROCEDURE* SetDevSec*(secReg, secPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(secReg, val);
    SYSTEM.PUT(secReg, val + {secPos})
  END SetDevSec;


  PROCEDURE* SetDevNonsec*(secReg, secPos: INTEGER);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(secReg, val);
    SYSTEM.PUT(secReg, val - {secPos})
  END SetDevNonsec;


  PROCEDURE init;
  BEGIN
    RST.EnableBusClock(SYS.GTZC1_BC_reg, SYS.GTZC1_BC_pos);
  END init;

BEGIN
  init
END GTZC.
