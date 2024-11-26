MODULE StartUp;
(**
  Oberon RTK Framework v2
  --
  Start-up control
  * power-on state machine (hardware controlled part)
  * reset controller (software controlled part)
  * watchdog boot vector
  * watchdog resets configs (psm, resets)
  --
  MCU: RP2040
  --
  See
  * 'PSM_*' values in MCU2.mod for blocks to reset
  * 'RESETS_*' values in MCU2.mod for subsytems to reset
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    BootMagic = 0B007C0D3H;


  (* power on state machine PSM *)

  PROCEDURE* AwaitPowerOnResetDone*(component: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.PSM_DONE, x)
    UNTIL component IN x
  END AwaitPowerOnResetDone;


  PROCEDURE* SetWatchdogPowerOnResets*(components: SET);
  BEGIN
    SYSTEM.PUT(MCU.PSM_WDSEL, components)
  END SetWatchdogPowerOnResets;


  (* resets controller *)

  PROCEDURE* ReleaseReset*(devNo: INTEGER);
  (* release the reset of a device out of start-up *)
    VAR done: SET;
  BEGIN
    SYSTEM.GET(MCU.RESETS_DONE, done);
    IF ~(devNo IN done) THEN
      SYSTEM.PUT(MCU.RESETS_RESET + MCU.ACLR, {devNo});
      REPEAT
        SYSTEM.GET(MCU.RESETS_DONE, done);
      UNTIL (devNo IN done)
    END
  END ReleaseReset;


  PROCEDURE* SetWatchdogResetResets*(devices: SET);
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL, devices)
  END SetWatchdogResetResets;


  (* watchdog *)

  PROCEDURE* SetWatchdogBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH4, BootMagic);
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH5, BITS(entryPoint) / BITS(BootMagic));
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH6, stackPointer);
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH7, entryPoint)
  END SetWatchdogBootVector;

END StartUp.
