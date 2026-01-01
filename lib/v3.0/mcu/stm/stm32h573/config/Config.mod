MODULE Config;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  * Memory configuration data
  * Set VTOR, install initial simple error/fault handlers
  * Set core ID register via VTOR/vector table
  * Other basic low level set-ups
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
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


  (* simple error/fault handlers for the startup sequence *)

  PROCEDURE blink(cnt: INTEGER);
    VAR i: INTEGER;
  BEGIN
    REPEAT
      LED.Toggle({LED.Red});
      i := 0;
      WHILE i < cnt DO INC(i) END
    UNTIL FALSE
  END blink;

  PROCEDURE errorHandler[0];
  BEGIN
    blink(1000000)
  END errorHandler;

  PROCEDURE faultHandler[0];
  BEGIN
    blink(5000000)
  END faultHandler;

  PROCEDURE* install(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END install;


  PROCEDURE init;
    CONST Core0 = 0;
    VAR vtor: INTEGER;
  BEGIN
    (* core 0 *)
    DataMem[Core0].start := LinkOptions.DataStart;
    DataMem[Core0].end := LinkOptions.DataEnd;
    HeapMem[Core0].start := LinkOptions.HeapStart;
    HeapMem[Core0].limit := LinkOptions.HeapLimit;
    StackMem[Core0].start := LinkOptions.StackStart;
    ExtMem[Core0].start := MCU.SRAM2_Cb_NS_BASE;
    ExtMem[Core0].end := MCU.SRAM2_Cb_NS_BASE + MCU.SRAM2_Size;
    VectMem[Core0].start := DataMem[Core0].start;
    VectMem[Core0].end := VectMem[Core0].start + MCU.VectorTableSize;

    (* common *)
    CodeMem.start := LinkOptions.CodeStart;
    CodeMem.end := LinkOptions.CodeEnd;
    ResMem.start := LinkOptions.ResourceStart;
    ModMem.start := StackMem[Core0].start + 04H;
    ModMem.end := DataMem[Core0].end;


    (* VTOR and initial simple error/fault handlers *)
    (* UsageFault and friends are not enabled yet and escalate to HardFault *)
    vtor := VectMem[Core0].start;
    SYSTEM.PUT(MCU.PPB_VTOR, vtor);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);
    install(vtor + MCU.EXC_NMI_Offset, faultHandler);
    install(vtor + MCU.EXC_HardFault_Offset, faultHandler);
    install(vtor + MCU.EXC_SVC_Offset, errorHandler);

    (* the STM32U585 does not provide a register to get the core ID *)
    (* use value at address 0H of vector table as core ID *)
    (* see Cores.GetCoreId *)
    SYSTEM.PUT(vtor, Core0)
  END init;

BEGIN
  init
END Config.
