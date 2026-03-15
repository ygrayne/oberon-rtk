MODULE RST;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Resets controller
  Power-on state machine
  --
  Type: MCU
  --
  MCU: RP2040
  --
  See
  * 'RESETS_*' values in MCU2.mod for subsytems to reset
  * 'PSM_*' values in MCU2.mod for blocks to reset
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  (* -- RESETS controller -- *)

  PROCEDURE* ReleaseResets*(devices: SET);
  (* release the reset of set of device out of start-up *)
    VAR done: SET;
  BEGIN
    SYSTEM.GET(MCU.RESETS_DONE, done);
    devices := devices - done;
    SYSTEM.PUT(MCU.RESETS_RESET + MCU.ACLR, devices);
    WHILE done * devices # devices DO
      SYSTEM.GET(MCU.RESETS_DONE, done)
    END
  END ReleaseResets;


  PROCEDURE ReleaseReset*(devNo: INTEGER);
  BEGIN
    ReleaseResets({devNo})
  END ReleaseReset;


  (* -- PSM: power on state machine PSM -- *)

  PROCEDURE* AwaitPowerOnResetDone*(component: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.PSM_DONE, x)
    UNTIL component IN x
  END AwaitPowerOnResetDone;


  (* -- watchdog resets -- *)

  PROCEDURE* SetPowerOnWatchdogResets*(components: SET);
  BEGIN
    SYSTEM.PUT(MCU.PSM_WDSEL, components)
  END SetPowerOnWatchdogResets;


  PROCEDURE* SetResetWatchdogResets*(devices: SET);
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL, devices)
  END SetResetWatchdogResets;

END RST.
