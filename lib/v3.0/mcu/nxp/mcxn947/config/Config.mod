MODULE Config;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  * Memory configuration data
  * Set VTOR, install initial simple error/fault handlers
  * Set core ID register via VTOR/vector table
  * Other basic low level set-up
  --
  One core only (all SRAM allocated to core 0)
  --
  MCU: MCXN947
  Board: FRDM-MCXN947
  --
  Copyright (c) 2023-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LinkOptions, MCU := MCU2, CLK; (* LinkOptions must be first in list *)

  CONST
    NumCoresUsed* = 1;

    ErrorLEDpinNo = 10;   (* red, port 0 *)
    LXOR = MCU.GPIO0_BASE + MCU.GPIO_PTOR_Offset;

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

  PROCEDURE initLED;
    VAR addr: INTEGER; val: SET;
  BEGIN
    CLK.EnableBusClock(MCU.DEV_PORT0);
    CLK.EnableBusClock(MCU.DEV_GPIO0);
    addr := MCU.GPIO0 + MCU.GPIO_PDDR_Offset;
    SYSTEM.GET(addr, val);
    INCL(val, ErrorLEDpinNo);
    SYSTEM.PUT(addr, val)
  END initLED;


  PROCEDURE* errorHandler*[0];
    VAR i: INTEGER;
  BEGIN
    REPEAT
      SYSTEM.PUT(LXOR, {ErrorLEDpinNo});
      i := 0;
      WHILE i < 1000000 DO INC(i) END
    UNTIL FALSE
  END errorHandler;


  PROCEDURE* faultHandler*[0];
    VAR i: INTEGER;
  BEGIN
    REPEAT
      SYSTEM.PUT(LXOR, {ErrorLEDpinNo});
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
    CONST Core0 = 0;
    VAR vtor: INTEGER;
  BEGIN
    (* core 0 *)
    DataMem[Core0].start := LinkOptions.DataStart;
    DataMem[Core0].end := LinkOptions.DataEnd;
    HeapMem[Core0].start := LinkOptions.HeapStart;
    HeapMem[Core0].limit := LinkOptions.HeapLimit;
    StackMem[Core0].start := LinkOptions.StackStart;
    ExtMem[Core0].start := MCU.SRAM_X_S_BASE;
    ExtMem[Core0].end := MCU.SRAM_X_S_BASE + MCU.SRAM_X_Size;
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
    initLED;

    (* the MCXN947 does not provide a register to get the core ID *)
    (* use value at address 0H of vector table as core ID *)
    (* see Cores.GetCoreId *)
    SYSTEM.PUT(vtor, Core0);

    (* disble glitch detectors *)
    SYSTEM.PUT(MCU.GDET0_BASE + MCU.GDET_ENABLE1_Offset, 0);
    SYSTEM.PUT(MCU.GDET1_BASE + MCU.GDET_ENABLE1_Offset, 0)
  END init;

BEGIN
  init
END Config.
