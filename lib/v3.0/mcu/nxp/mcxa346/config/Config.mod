MODULE Config;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  * Memory configuration data
  * Set VTOR, install initial simple error/fault handlers
  * Set core ID register via VTOR/vector table
  * Reset some MCU registers left behind set by boot ROM
  --
  MCU: MCXA346
  Board: FRDM-MCXA346
  --
  One core
  --
  Copyright (c) 2023-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LinkOptions, MCU := MCU2, StartUp; (* LinkOptions must be first in list *)

  CONST
    NumCoresUsed* = MCU.NumCores;

    ErrorLEDpinNo = 18; (* red, port 3 *)
    LXOR* = MCU.GPIO3_BASE + MCU.GPIO_PTOR_Offset;

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

  PROCEDURE initLED;
    VAR addr: INTEGER; val: SET;
  BEGIN
    StartUp.ReleaseReset(MCU.DEV_PORT3);
    StartUp.ReleaseReset(MCU.DEV_GPIO3);
    StartUp.EnableClock(MCU.DEV_PORT3);
    StartUp.EnableClock(MCU.DEV_GPIO3);
    addr := MCU.GPIO3 + MCU.GPIO_PDDR_Offset;
    SYSTEM.GET(addr, val);
    val := val + {ErrorLEDpinNo};
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
    CONST Core0 = 0; R11 = 11;
    VAR vtor: INTEGER;
  BEGIN
    DataMem[Core0].start := LinkOptions.DataStart;
    DataMem[Core0].end := LinkOptions.DataEnd;
    HeapMem[Core0].start := LinkOptions.HeapStart;
    HeapMem[Core0].limit := LinkOptions.HeapLimit;
    StackMem[Core0].start := LinkOptions.StackStart;

    CodeMem.start := LinkOptions.CodeStart;
    CodeMem.end := LinkOptions.CodeEnd;
    ResMem.start := LinkOptions.ResourceStart;
    ModMem.start := StackMem[Core0].start + 04H;
    ModMem.end := DataMem[Core0].end;

    ExtMem[Core0].start := MCU.SRAM_X0_ALIAS;;
    ExtMem[Core0].end := MCU.SRAM_X0_ALIAS + MCU.SRAM_X0_Size;

    (* VTOR and initial simple error/fault handlers *)
    (* UsageFault and friends are not enabled yet and escalate to HardFault *)
    SYSTEM.PUT(MCU.PPB_VTOR, DataMem[Core0].start);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);

    initLED;
    vtor := DataMem[Core0].start;
    install(vtor + MCU.EXC_NMI_Offset, faultHandler);
    install(vtor + MCU.EXC_HardFault_Offset, faultHandler);
    install(vtor + MCU.EXC_SVC_Offset, errorHandler);

    (* the MCXA346 does not provide a register to get the core ID *)
    (* use value at address 0H of vector table as core ID *)
    (* see Cores.GetCoreId *)
    SYSTEM.GET(MCU.PPB_VTOR, vtor);
    SYSTEM.PUT(vtor, Core0);

    (* it appears exceptions are globally disabled via PRIMASK -- boot ROM? *)
    (* init to reset value as per the M33 ref/arch manuals *)
    SYSTEM.EMIT(MCU.CPSIE_I);
    (* it appears CONTROL.FPCA is set, indicating FPU usage -- boot ROM? *)
    (* which means all thread-level code interrupts will stack the FPU registers every time... *)
    (* init CONTROL to reset value as per the M33 ref/arch manuals *)
    SYSTEM.LDREG(R11, 0);
    SYSTEM.EMIT(MCU.MSR_CTL_R11)
  END init;

BEGIN
  init
END Config.
