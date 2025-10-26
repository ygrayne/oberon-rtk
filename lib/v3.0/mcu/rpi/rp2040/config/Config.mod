MODULE Config;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  * Memory configuration data
  * Set VTOR, install initial simple error/fault handlers
  --
  MCU: RP2040
  Board: Pico
  --
  Two cores
  --
  Copyright (c) 2023-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LinkOptions, MCU := MCU2, LED; (* LinkOptions must be first in list *)

  CONST
    NumCoresUsed* = MCU.NumCores;

  TYPE
    DataDesc* = RECORD
      start*, end*: INTEGER
    END;

    HeapDesc* = RECORD
      start*: INTEGER;
      limit*: INTEGER
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

  VAR
    DataMem*: ARRAY NumCoresUsed OF DataDesc;
    HeapMem*: ARRAY NumCoresUsed OF HeapDesc;
    StackMem*: ARRAY NumCoresUsed OF StackDesc;
    ExtMem*: ARRAY NumCoresUsed OF ExtDesc;
    ModMem*: ModDesc;
    CodeMem*: CodeDesc;
    ResMem*: ResDesc;


  (* simple error/fault handlers for the startup sequence *)
  PROCEDURE* errorHandler*[0];
    VAR i: INTEGER;
  BEGIN
    REPEAT
      SYSTEM.PUT(LED.LXOR, {LED.Pico});
      i := 0;
      WHILE i < 1000000 DO INC(i) END
    UNTIL FALSE
  END errorHandler;


  PROCEDURE* faultHandler*[0];
    VAR i: INTEGER;
  BEGIN
    REPEAT
      SYSTEM.PUT(LED.LXOR, {LED.Pico});
      i := 0;
      WHILE i < 5000000 DO INC(i) END
    UNTIL FALSE
  END faultHandler;


  PROCEDURE* install(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END install;


  PROCEDURE init;
    CONST Core0 = 0; Core1 = 1;
    VAR vtor: INTEGER;
  BEGIN
    DataMem[Core0].start := LinkOptions.DataStart;
    DataMem[Core0].end := LinkOptions.DataEnd;
    HeapMem[Core0].start := LinkOptions.HeapStart;
    HeapMem[Core0].limit := LinkOptions.HeapLimit;
    StackMem[Core0].start := LinkOptions.StackStart;
    ExtMem[Core0].start := MCU.SRAM4_BASE;
    ExtMem[Core0].end := MCU.SRAM4_BASE + MCU.SRAM4_Size;

    CodeMem.start := LinkOptions.CodeStart;
    CodeMem.end := LinkOptions.CodeEnd;
    ResMem.start := LinkOptions.ResourceStart;
    ModMem.start := StackMem[Core0].start + 04H;
    ModMem.end := DataMem[Core0].end;

    DataMem[Core1].start := DataMem[Core0].end;
    DataMem[Core1].end := MCU.SRAM0_BASE + MCU.SRAM0_Size + MCU.SRAM4_Size;
    HeapMem[Core1].start := DataMem[Core1].start + (HeapMem[Core0].start - DataMem[Core0].start);
    IF LinkOptions.HeapLimit = 0 THEN
      HeapMem[Core1].limit := 0
    ELSE
      HeapMem[Core1].limit := DataMem[Core1].start + (HeapMem[Core0].limit - DataMem[Core0].start)
    END;
    StackMem[Core1].start := DataMem[Core1].end - 04H;
    ExtMem[Core1].start := MCU.SRAM5_BASE;
    ExtMem[Core1].end := MCU.SRAM5_BASE + MCU.SRAM5_Size;

    (* VTOR and initial simple error/fault handlers *)
    (* UsageFault and friends are not enabled yet and escalate to HardFault *)
    vtor := DataMem[Core0].start;
    SYSTEM.PUT(MCU.PPB_VTOR, vtor);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);
    install(vtor + MCU.EXC_NMI_Offset, faultHandler);
    install(vtor + MCU.EXC_HardFault_Offset, faultHandler);
    install(vtor + MCU.EXC_SVC_Offset, errorHandler)
  END init;

BEGIN
  init
END Config.
