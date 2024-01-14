MODULE PowerOn;
(**
  Oberon RTK Framework
  Power-on state machine
  Watchdog resets
  Not to be mixed up with the reset controller for devices
  --
  Notes:
  * maybe put watchdog resets config into watchdog module?
  * usage concept and testing of watchdog resets TBD
  --
  MCU: Cortex-M0+ RP2040
  --
  See 'PSM-*' values in MCU2.mod for blocks to reset
  --
  Copyright (c) 2023 Gray gray@grayraven.org
**)

  IMPORT SYSTEM, MCU := MCU2;


  PROCEDURE WatchdogResetSelect*(mask: SET);
  BEGIN
    SYSTEM.PUT(MCU.PSM_WDSEL + MCU.ASET, mask)
  END WatchdogResetSelect;


  PROCEDURE WatchdogResetDeselect*(mask: SET);
  BEGIN
    SYSTEM.PUT(MCU.PSM_WDSEL + MCU.ACLR, mask)
  END WatchdogResetDeselect;


  PROCEDURE AwaitResetDone*(which: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.PSM_DONE, x)
    UNTIL which IN x
  END AwaitResetDone;

END PowerOn.
