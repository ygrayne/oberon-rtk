MODULE StartUp;
(**
  Oberon RTK Framework
  Start-up control
  * power-on state machine (hardware controlled part)
  * reset controller (software controlled part)
  Note: watchdog resets selecyion in 'Watchdog.mod'
  --
  MCU: Cortex-M0+ RP2040
  --
  See
  * 'PSM_*' values in MCU2.mod for blocks to reset
  * 'RESETS_*' values in MCU2.mod for subsytems to reset
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  (* power on state machine *)

  PROCEDURE AwaitPowerOnResetDone*(which: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.PSM_DONE, x)
    UNTIL which IN x
  END AwaitPowerOnResetDone;

  (* reset controller *)

  PROCEDURE ReleaseReset*(devNo: INTEGER);
  (* release the reset out of start-up *)
    VAR x: SET;
  BEGIN
    SYSTEM.GET(MCU.RESETS_DONE, x);
    IF ~(devNo IN x) THEN
      SYSTEM.PUT(MCU.RESETS_RESET + MCU.ACLR, {devNo})
    END
  END ReleaseReset;


  PROCEDURE AwaitReleaseDone*(devNo: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.RESETS_DONE, x);
    UNTIL (devNo IN x)
  END AwaitReleaseDone;

END StartUp.
