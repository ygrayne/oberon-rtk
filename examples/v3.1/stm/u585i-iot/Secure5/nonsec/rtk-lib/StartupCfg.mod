MODULE StartupCfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific start-up code.
  --
  For different or additional init code, copy to the project directory and adapt accordingly.
  Must be set in any case: VTOR, core Id as explained below.
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LinkOptions, PPB, LED; (* LinkOptions must be first in list *)

  VAR Initialised*: BOOLEAN;

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
    (* make LED operational for the simple init/fault handlers *)
    LED.Init;

    (* VTOR and initial simple error/fault handlers *)
    (* UsageFault and friends are not enabled yet and escalate to HardFault *)
    vtor := LinkOptions.DataStart;
    SYSTEM.PUT(PPB.VTOR, vtor);
    (* asm
      dsb
      isb
    end asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3BF8F4FH);  (* dsb *)
    SYSTEM.EMIT(0F3BF8F6FH);  (* isb *)
    (* -asm *)

    install(vtor + PPB.EXC_NMI_Offset, faultHandler);
    install(vtor + PPB.EXC_HardFault_Offset, faultHandler);
    install(vtor + PPB.EXC_SVC_Offset, errorHandler);

    (* the STM32U585 does not provide a register to get the core ID *)
    (* use value at address 0H of vector table as core ID *)
    (* see Cores.GetCoreId *)
    SYSTEM.PUT(vtor, Core0)
  END init;

BEGIN
  Initialised := FALSE;
  init;
  Initialised := TRUE
END StartupCfg.
