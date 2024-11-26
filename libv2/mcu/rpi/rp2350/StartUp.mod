MODULE StartUp;
(**
  Oberon RTK Framework v2
  --
  Start-up control
  * power-on state machine (hardware controlled part)
  * reset controller (software controlled part)
  * power manager boot vector
  * watchdog boot vector
  * watchdog resets configs (powman, psm, resets)
  --
  MCU: RP2350
  --
  See
  * 'PSM_*' values in MCU2.mod for components to reset
  * 'RESETS_*' values in MCU2.mod for subsytems to reset
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    BootMagic = 0B007C0D3H;

    (* POWMAN_WDSEL bits *)
    POWMAN_WDSEL_RST_PSM*          = 12;
    POWMAN_WDSEL_RST_SWCORE*       = 8;
    POWMAN_WDSEL_RST_POWMAN*       = 4;
    POWMAN_WDSEL_RST_POWMAN_ASYNC* = 0;

    (* POWMAN [31:16] passcode *)
    POWMAN_PASSCODE = 05AFEH;

  (* -- power manager POWMAN-- *)

  PROCEDURE* SetPowmanBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.POWMAN_BOOT0, BootMagic);
    SYSTEM.PUT(MCU.POWMAN_BOOT1, BITS(entryPoint) / BITS(BootMagic));
    SYSTEM.PUT(MCU.POWMAN_BOOT2, stackPointer);
    SYSTEM.PUT(MCU.POWMAN_BOOT3, entryPoint)
  END SetPowmanBootVector;


  PROCEDURE* SetWatchdogPowmanReset*(reset: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.POWMAN_WDSEL, POWMAN_PASSCODE + reset)
  END SetWatchdogPowmanReset;


  (* -- power on state machine PSM -- *)

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


  (* -- resets controller -- *)

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


  (* -- watchdog -- *)

  PROCEDURE* SetWatchdogBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH4, BootMagic);
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH5, BITS(entryPoint) / BITS(BootMagic));
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH6, stackPointer);
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH7, entryPoint)
  END SetWatchdogBootVector;

END StartUp.
