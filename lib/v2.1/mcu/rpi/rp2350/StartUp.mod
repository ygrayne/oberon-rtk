MODULE StartUp;
(**
  Oberon RTK Framework v2
  --
  Start-up control
  * power-on state machine (hardware controlled part)
  * reset controller (software controlled part)
  * power manager boot vector
  * watchdog boot vector
  * watchdog reset configs (powman, psm, resets)
  * restart entry mode
  --
  MCU: RP2350
  --
  See
  * 'PSM_*' values in MCU2.mod for components to reset
  * 'RESETS_*' values in MCU2.mod for subsytems to reset
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    BootMagic0 = 0B007C0D3H;
    BootMagic1 = 04FF83F2DH;

    (* POWMAN_WDSEL bits *)
    POWMAN_WDSEL_RST_PSM*          = 12;
    POWMAN_WDSEL_RST_SWCORE*       = 8;
    POWMAN_WDSEL_RST_POWMAN*       = 4;
    POWMAN_WDSEL_RST_POWMAN_ASYNC* = 0;

    (* POWMAN [31:16] passcode *)
    POWMAN_PASSCODE = 05AFE0000H;


  (* -- power manager POWMAN-- *)

  PROCEDURE* SetPowmanBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.POWMAN_BOOT0, BootMagic0);
    INCL(SYSTEM.VAL(SET, entryPoint), 0);
    SYSTEM.PUT(MCU.POWMAN_BOOT1, BITS(entryPoint) / BITS(BootMagic1));
    SYSTEM.PUT(MCU.POWMAN_BOOT2, stackPointer);
    SYSTEM.PUT(MCU.POWMAN_BOOT3, entryPoint)
  END SetPowmanBootVector;


  PROCEDURE* SetPowmanWatchdogReset*(reset: INTEGER);
  (* chip resets *)
  BEGIN
    SYSTEM.PUT(MCU.POWMAN_WDSEL, POWMAN_PASSCODE + reset)
  END SetPowmanWatchdogReset;


  (* -- power on state machine PSM -- *)

  PROCEDURE* AwaitPowerOnResetDone*(component: INTEGER);
    VAR x: SET;
  BEGIN
    REPEAT
      SYSTEM.GET(MCU.PSM_DONE, x)
    UNTIL component IN x
  END AwaitPowerOnResetDone;


  PROCEDURE* SetPowerOnWatchdogResets*(components: SET);
  (* system resets *)
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
  (* sub-system resets *)
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL, devices)
  END SetResetWatchdogResets;


  (* -- watchdog -- *)

  PROCEDURE* SetWatchdogBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH4, BootMagic0);
    INCL(SYSTEM.VAL(SET, entryPoint), 0); (* thumb code *)
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH5, BITS(entryPoint) / BITS(BootMagic1)); (* XOR *)
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH6, stackPointer);
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH7, entryPoint)
  END SetWatchdogBootVector;

END StartUp.
