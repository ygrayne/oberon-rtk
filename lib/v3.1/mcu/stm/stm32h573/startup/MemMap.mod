MODULE MemMap;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific memory configuration data.
  Uses LinkOptions and thus the corresponding Astrobe config file data
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT LinkOptions, BASE, EXC;

  CONST
    NumCoresUsed* = BASE.NumCores;

  TYPE
    DataDesc* = RECORD
      start*, end*: INTEGER
    END;

    HeapDesc* = RECORD
      start*, limit*: INTEGER;
    END;

    StackDesc* = RECORD
      start*: INTEGER
    END;

    CodeDesc* = RECORD
      start*, end*: INTEGER
    END;

    ModDesc* = RECORD (* module data space *)
      start*, end*: INTEGER
    END;

    ResDesc* = RECORD (* resources block at the end of the binary *)
      start*: INTEGER
    END;

    ExtDesc* = RECORD (* extended memory *)
      start*, end*: INTEGER
    END;

    VectDesc* = RECORD (* vector table *)
      start*, end*: INTEGER
    END;

    NscDesc* = RECORD (* NSC memory *)
      start*, end*: INTEGER
    END;


  VAR
    DataMem*: ARRAY NumCoresUsed OF DataDesc;
    HeapMem*: ARRAY NumCoresUsed OF HeapDesc;
    StackMem*: ARRAY NumCoresUsed OF StackDesc;
    ExtMem*: ARRAY NumCoresUsed OF ExtDesc;
    VectMem*: ARRAY NumCoresUsed OF VectDesc;
    NscMem*: ARRAY NumCoresUsed OF NscDesc;
    ModMem*: ModDesc;
    CodeMem*: CodeDesc;
    ResMem*: ResDesc;
    Done*: BOOLEAN;


  PROCEDURE init;
    CONST Core0 = 0;
  BEGIN
    (* core 0 *)
    DataMem[Core0].start := LinkOptions.DataStart;
    DataMem[Core0].end := LinkOptions.DataEnd;
    HeapMem[Core0].start := LinkOptions.HeapStart;
    HeapMem[Core0].limit := LinkOptions.HeapLimit;
    StackMem[Core0].start := LinkOptions.StackStart;
    ExtMem[Core0].start := BASE.SRAM2_Cb_NS_BASE; (* code bus access *)
    ExtMem[Core0].end := BASE.SRAM2_Cb_NS_BASE + BASE.SRAM2_Size;
    VectMem[Core0].start := DataMem[Core0].start;
    VectMem[Core0].end := VectMem[Core0].start + EXC.VectorTableSize;
    NscMem[Core0].start := LinkOptions.CodeStart + BASE.FLASH_BLK_Size - LinkOptions.CodeEnd;
    NscMem[Core0].end := LinkOptions.CodeStart + BASE.FLASH_BLK_Size;

    (* common *)
    CodeMem.start := LinkOptions.CodeStart;
    CodeMem.end := LinkOptions.CodeEnd;
    ResMem.start := LinkOptions.ResourceStart;
    ModMem.start := StackMem[Core0].start + 04H;
    ModMem.end := DataMem[Core0].end
  END init;

BEGIN
  Done := FALSE;
  init;
  Done := TRUE
END MemMap.
