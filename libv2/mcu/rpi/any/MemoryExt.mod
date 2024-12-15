MODULE MemoryExt;
(**
  Oberon RTK Framework v2
  --
  * extended memory allocation for two cores
  * two 4k blocks,
    * for RP2040:
      * above the 256k memory managed via Memory.mod
        * SRAM block 4: core 0 => MCU2.SRAM4_BASE = MCU2.SRAM_EXT0
        * SRAM block 5: core 1 => MCU2.SRAM5_BASE = MCU2.SRAM_EXT1
    * for RP 2350:
      * above the 512k memory managed via Memory.mod
        * SRAM block 8: core 0 => MCU2.SRAM8_BASE = MCU2.SRAM_EXT0
        * SRAM block 9: core 1 => MCU2.SRAM9_BASE = MCU2.SRAM_EXT1
    See module Config.mod.
  The following two features may be factored out into another module:
  * Copy procedure to SRAM
  * Cache a procedure
  --
  MCU: RP2040, RP2350
  Boards: Pico, Pico2
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Config, ProgData;

  CONST
    NumCores = MCU.NumCores;

  TYPE
    CoreContext = RECORD
      memTop: INTEGER;
      memLimit: INTEGER
    END;

  VAR
    coreCon: ARRAY NumCores OF CoreContext;


  PROCEDURE* Allocate*(VAR addr: INTEGER; blockSize: INTEGER);
  (* parameter order as in Memory.mod for consistency *)
    VAR cid, h: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    h := coreCon[cid].memTop + blockSize;
    IF h < coreCon[cid].memLimit THEN
      addr :=  coreCon[cid].memTop;
      coreCon[cid].memTop := h
    ELSE
      addr := 0
    END
  END Allocate;


  PROCEDURE getCopyEndAddr(procAddr: INTEGER; VAR copyEndAddr: INTEGER);
    VAR entry0, entry1: ProgData.Entry;
  BEGIN
    ProgData.FindEntry(procAddr, entry0);
    ProgData.GetNextEntry(entry0, entry1);
    copyEndAddr := entry1.codeAddr
  END getCopyEndAddr;


  PROCEDURE CopyProc*(procAddr: INTEGER; VAR toAddr: INTEGER);
  (* Copy a procedure to extended memory *)
  (* Includes any data blocks after the instructions *)
    VAR procSize: INTEGER;
  BEGIN
    getCopyEndAddr(procAddr, toAddr);
    IF toAddr # 0 THEN
      procSize := toAddr - procAddr;
      Allocate(toAddr, procSize);
      IF toAddr # 0 THEN
        SYSTEM.COPY(procAddr, toAddr, procSize DIV 4)
      END
    END
  END CopyProc;


  PROCEDURE CacheProc*(procAddr: INTEGER);
  (* Read a procedure to load it into flash memory cache *)
  (* Includes any data blocks after the instructions *)
    VAR instr, toAddr: INTEGER;
  BEGIN
    getCopyEndAddr(procAddr, toAddr);
    WHILE procAddr < toAddr DO
      SYSTEM.GET(procAddr, instr);
      INC(procAddr, 4)
    END
  END CacheProc;


  PROCEDURE init;
    CONST Core0 = 0; Core1 = 1;
  BEGIN
    coreCon[Core0].memTop := Config.CoreZeroRamExtStart;
    coreCon[Core0].memLimit := Config.CoreZeroRamExtEnd;
    coreCon[Core1].memTop := Config.CoreOneRamExtStart;
    coreCon[Core1].memLimit := Config.CoreOneRamExtEnd
  END init;

BEGIN
  init
END MemoryExt.
