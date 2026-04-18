MODULE Startup;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific start-up code.
  Gets VTOR from LinkOptions and thus the Astrobe config file data.
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

  IMPORT SYSTEM, LinkOptions, PPB; (* LinkOptions must be first module in list *)

  VAR Done*: BOOLEAN;

  (* "catch-and-halt" error/fault handler for the startup sequence *)
  (* prevents run-away *)

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
    CONST Core0 = 0;
    VAR vtor: INTEGER;
  BEGIN
    (* VTOR *)
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
    install(vtor + PPB.EXC_SVC_Offset, errorHandler);

    (* the STM32U585 does not provide a register to get the core ID *)
    (* use value at address 0H of vector table as core ID *)
    (* see Cores.GetCoreId *)
    SYSTEM.PUT(vtor, Core0)
  END run;

BEGIN
  Done := FALSE;
  run;
  Done := TRUE
END Startup.
