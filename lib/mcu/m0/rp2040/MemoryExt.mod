MODULE MemoryExt;
(**
  Oberon RTK Framework
  * extended memory allocation for two cores
  * two 4k blocks above the 256k memory managed via Memory.mod
    * SRAM block 4: core 0
    * SRAM block 5: core 1
    See module Config.mod.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Config;

  CONST
    NumCores = Config.NumCores;

  TYPE
    CoreContext = RECORD
      memTop: INTEGER;
      memLimit: INTEGER
    END;

  VAR
    coreCon: ARRAY NumCores OF CoreContext;


  PROCEDURE Allocate*(VAR addr: INTEGER; blockSize: INTEGER);
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


  PROCEDURE CopyProc*(procAddr: INTEGER; VAR toAddr: INTEGER);
  (* Copy a procedure to extended memory *)
    CONST PushLr = 0B5H;
    VAR addr, instr, procSize: INTEGER;
  BEGIN
    addr := procAddr + 4;
    SYSTEM.GET(addr, instr);
    (* scan for push{... lr}, is always word aligned *)
    WHILE BFX(instr, 15, 8) # PushLr DO
      INC(addr, 4);
      SYSTEM.GET(addr, instr);
    END;
    procSize := addr - procAddr;
    Allocate(toAddr, procSize);
    IF toAddr # 0 THEN
      SYSTEM.COPY(procAddr, toAddr, procSize DIV 4)
    END
  END CopyProc;


  PROCEDURE CacheProc*(procAddr: INTEGER);
    CONST PushLr = 0B5H;
    VAR addr, instr: INTEGER;
  BEGIN
    SYSTEM.GET(procAddr, instr);
    addr := procAddr + 4;
    SYSTEM.GET(addr, instr);
    WHILE BFX(instr, 15, 8) # PushLr DO
      INC(addr, 4);
      SYSTEM.GET(addr, instr)
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

