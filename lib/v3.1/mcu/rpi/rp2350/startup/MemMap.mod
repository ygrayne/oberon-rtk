MODULE MemMap;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific memory configuration data.
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: RP2350
  Board: Pico 2
  --
  Two cores
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT LinkOptions, BASE, EXC; (* LinkOptions must be first in list *)

  CONST
    NumCoresUsed* = BASE.NumCores;

  TYPE
    DataDesc* = RECORD
      start*, end*: INTEGER
    END;

    HeapDesc* = RECORD
      start*, limit*: INTEGER
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

  VAR
    DataMem*: ARRAY NumCoresUsed OF DataDesc;
    HeapMem*: ARRAY NumCoresUsed OF HeapDesc;
    StackMem*: ARRAY NumCoresUsed OF StackDesc;
    ExtMem*: ARRAY NumCoresUsed OF ExtDesc;
    VectMem*: ARRAY NumCoresUsed OF VectDesc;
    ModMem*: ModDesc;
    CodeMem*: CodeDesc;
    ResMem*: ResDesc;
    Done*: BOOLEAN;


  PROCEDURE init;
    CONST Core0 = 0; Core1 = 1;
  BEGIN
    (* core 0 *)
    DataMem[Core0].start := LinkOptions.DataStart;
    DataMem[Core0].end := LinkOptions.DataEnd;
    HeapMem[Core0].start := LinkOptions.HeapStart;
    HeapMem[Core0].limit := LinkOptions.HeapLimit;
    StackMem[Core0].start := LinkOptions.StackStart;
    ExtMem[Core0].start := BASE.SRAM8_BASE;
    ExtMem[Core0].end := BASE.SRAM8_BASE + BASE.SRAM8_Size;
    VectMem[Core0].start := DataMem[Core0].start;
    VectMem[Core0].end := VectMem[Core0].start + EXC.VectorTableSize;

    (* common *)
    CodeMem.start := LinkOptions.CodeStart;
    CodeMem.end := LinkOptions.CodeEnd;
    ResMem.start := LinkOptions.ResourceStart;
    ModMem.start := StackMem[Core0].start + 04H;
    ModMem.end := DataMem[Core0].end;

    (* core 1 *)
    DataMem[Core1].start := DataMem[Core0].end;
    DataMem[Core1].end := BASE.SRAM0_BASE + BASE.SRAM0_Size + BASE.SRAM4_Size;
    HeapMem[Core1].start := DataMem[Core1].start + (HeapMem[Core0].start - DataMem[Core0].start);
    IF LinkOptions.HeapLimit = 0 THEN
      HeapMem[Core1].limit := 0
    ELSE
      HeapMem[Core1].limit := DataMem[Core1].start + (HeapMem[Core0].limit - DataMem[Core0].start)
    END;
    StackMem[Core1].start := DataMem[Core1].end - 04H;
    ExtMem[Core1].start := BASE.SRAM9_BASE;
    ExtMem[Core1].end := BASE.SRAM9_BASE + BASE.SRAM9_Size;
    VectMem[Core1].start := DataMem[Core1].start;
    VectMem[Core1].end := VectMem[Core1].start + EXC.VectorTableSize;
  END init;

BEGIN
  Done := FALSE;
  init;
  Done := TRUE
END MemMap.
