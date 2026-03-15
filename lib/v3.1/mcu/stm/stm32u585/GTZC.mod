MODULE GTZC;
(**
  Oberon RTK Framework
  Version: v3.0
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

  IMPORT SYSTEM, MCU := MCU2, CLK;

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
        SRAM1: addr := MCU.GTZC1_MPCBB1 + MCU.PERI_S_Offset
      | SRAM2: addr := MCU.GTZC1_MPCBB2 + MCU.PERI_S_Offset
      | SRAM3: addr := MCU.GTZC1_MPCBB3 + MCU.PERI_S_Offset
      | SRAM4: addr := MCU.GTZC2_MPCBB4 + MCU.PERI_S_Offset
      END;
      addr := addr + MCU.MPCBB_SECCFGR0_Offset + (MCU.MPCBB_SECCFGR_Offset * sbStart);
      cnt := 0;
      WHILE cnt < numSb DO
        SYSTEM.PUT(addr, blockMap);
        addr := addr + MCU.MPCBB_SECCFGR_Offset;
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
        SRAM1: addr := MCU.GTZC1_MPCBB1 + MCU.PERI_S_Offset
      | SRAM2: addr := MCU.GTZC1_MPCBB2 + MCU.PERI_S_Offset
      | SRAM3: addr := MCU.GTZC1_MPCBB3 + MCU.PERI_S_Offset
      | SRAM4: addr := MCU.GTZC2_MPCBB4 + MCU.PERI_S_Offset
      END;
      addr := addr + MCU.MPCBB_CR_Offset;
      SYSTEM.GET(addr, val);
      BFI(val, 0, enabled); (* SRWILADIS *)
      SYSTEM.PUT(addr, val)
    END
  END ConfigSRAMsecAccess;


  PROCEDURE init;
  BEGIN
    CLK.EnableBusClock(MCU.DEV_GTZC1);
    CLK.EnableBusClock(MCU.DEV_GTZC2)
  END init;

BEGIN
  init
END GTZC.
