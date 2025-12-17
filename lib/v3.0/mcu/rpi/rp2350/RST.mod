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
  MCU: RP2350
  --
  See
  * 'RESETS_*' values in MCU2.mod for subsytems to reset
  * 'PSM_*' values in MCU2.mod for components to reset
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* POWMAN_WDSEL bits *)
    (* for 'SetPowmanWatchdogReset' *)
    POWMAN_WDSEL_RST_PSM*          = 12;
    POWMAN_WDSEL_RST_SWCORE*       = 8;
    POWMAN_WDSEL_RST_POWMAN*       = 4;
    POWMAN_WDSEL_RST_POWMAN_ASYNC* = 0;

    (* POWMAN [31:16] passcode *)
    POWMAN_PASSCODE = 05AFE0000H;

  (* -- RESETS controller -- *)

  PROCEDURE* ReleaseResets*(devices: SET);
  (* release the reset of a set of device out of start-up *)
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


  (* -- PSM: power on state machine -- *)

  PROCEDURE* AwaitPowerOnResetDone*(component: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.PSM_DONE, x)
    UNTIL component IN x
  END AwaitPowerOnResetDone;


  (* -- watchdog resets -- *)

  PROCEDURE* SetPowerOnWatchdogResets*(components: SET);
  (* system resets *)
  BEGIN
    SYSTEM.PUT(MCU.PSM_WDSEL, components)
  END SetPowerOnWatchdogResets;


  PROCEDURE* SetResetWatchdogResets*(devices: SET);
  (* sub-system resets *)
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL, devices)
  END SetResetWatchdogResets;


  PROCEDURE* SetPowmanWatchdogReset*(reset: INTEGER);
  (* chip resets *)
  BEGIN
    SYSTEM.PUT(MCU.POWMAN_WDSEL, POWMAN_PASSCODE + reset)
  END SetPowmanWatchdogReset;

END RST.
