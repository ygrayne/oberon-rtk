MODULE Resets;
(**
  Oberon RTK Framework
  Start-up resets handling (reset controller)
  Watchdog resets
  --
  Note: maybe put watchdog resets config into watchdog module?
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  Datasheet: 2.14, p174
  --
  See 'RESETS_*' values in MCU2.mod for subsytems to reset
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  PROCEDURE Release*(devNo: INTEGER);
  (* release the reset out of start-up *)
    VAR x: SET;
  BEGIN
    SYSTEM.GET(MCU.RESETS_DONE, x);
    IF ~(devNo IN x) THEN
      SYSTEM.PUT(MCU.RESETS_RESET + MCU.ACLR, {devNo})
    END
  END Release;


  PROCEDURE AwaitReleaseDone*(devNo: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.RESETS_DONE, x);
    UNTIL (devNo IN x)
  END AwaitReleaseDone;


  (* note: if the reset controller block has been reset by the *)
  (* watchdog, in the power-on sequence, all subsystems/peripherals *)
  (* will be reset anyway *)

  PROCEDURE WatchdogSelect*(mask: SET);
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL + MCU.ASET, mask)
  END WatchdogSelect;

  PROCEDURE WatchdogDeselect*(mask: SET);
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL + MCU.ACLR, mask)
  END WatchdogDeselect;

END Resets.
