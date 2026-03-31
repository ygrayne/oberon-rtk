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
  MCU: RP2350
  Board: Pico 2
  --
  Two cores
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LinkOptions, MCU := MCU2, LED; (* LinkOptions must be first in list *)

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
    VAR vtor: INTEGER;
  BEGIN
    (* VTOR and initial simple error/fault handlers (core 0) *)
    (* UsageFault and friends are not enabled yet and escalate to HardFault *)
    vtor := LinkOptions.DataStart;
    SYSTEM.PUT(MCU.PPB_VTOR, vtor);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);
    install(vtor + MCU.EXC_NMI_Offset, faultHandler);
    install(vtor + MCU.EXC_HardFault_Offset, faultHandler);
    install(vtor + MCU.EXC_SVC_Offset, errorHandler)
  END init;

BEGIN
  init
END StartupCfg.
