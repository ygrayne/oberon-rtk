MODULE Startup;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific start-up code.
  --
  For different or additional init code, copy to the project directory and adapt accordingly.
  Must be set in any case: VTOR
  --
  MCU: RP2350
  Board: Pico 2
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, LinkOptions, PPB; (* LinkOptions must be first in list *)

  (* "catch-and-halt" error/fault handler for the startup sequence *)
  (* prevents run-away *)

  VAR
    Done*: BOOLEAN;

  PROCEDURE errorHandler[0];
  BEGIN
    REPEAT UNTIL FALSE
  END errorHandler;

  PROCEDURE* install(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END install;


  PROCEDURE run;
    VAR vtor: INTEGER;
  BEGIN
    (* VTOR and initial simple error/fault handlers (core 0) *)
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

    (* UsageFault and friends are not enabled yet and escalate to HardFault *)
    install(vtor + PPB.EXC_NMI_Offset, errorHandler);
    install(vtor + PPB.EXC_HardFault_Offset, errorHandler);
    install(vtor + PPB.EXC_SVC_Offset, errorHandler)
  END run;

BEGIN
  Done := FALSE;
  run;
  Done := TRUE
END Startup.
