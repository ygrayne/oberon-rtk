MODULE StartUp;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Start-up control
  * power-on state machine (hardware controlled part)
  * reset controller (software controlled part)
  * watchdog boot vector
  * watchdog reset configs (psm, resets)
  * restart entry mode
  --
  MCU: RP2040
  --
  See
  * 'PSM_*' values in MCU2.mod for blocks to reset
  * 'RESETS_*' values in MCU2.mod for subsytems to reset
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    BootMagic0 = 0B007C0D3H;
    BootMagic1 = 04FF83F2DH;

  (* -- power on state machine PSM -- *)

  PROCEDURE* AwaitPowerOnResetDone*(component: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.PSM_DONE, x)
    UNTIL component IN x
  END AwaitPowerOnResetDone;


  PROCEDURE* SetPowerOnWatchdogResets*(components: SET);
  BEGIN
    SYSTEM.PUT(MCU.PSM_WDSEL, components)
  END SetPowerOnWatchdogResets;


  (* -- resets controller -- *)

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


  PROCEDURE* SetResetWatchdogResets*(devices: SET);
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL, devices)
  END SetResetWatchdogResets;


  (* -- watchdog -- *)

  PROCEDURE* SetWatchdogBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH4, BootMagic0);
    INCL(SYSTEM.VAL(SET, entryPoint), 0);
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH5, BITS(entryPoint) / BITS(BootMagic1));
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH6, stackPointer);
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH7, entryPoint)
  END SetWatchdogBootVector;

END StartUp.
