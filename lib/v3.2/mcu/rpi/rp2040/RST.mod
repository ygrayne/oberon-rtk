MODULE RST;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Resets controller
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, SYS := RESETS_SYS;


  PROCEDURE ReleaseReset*(reg, pos: INTEGER);
    CONST DoneOffset = 8;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(reg + DoneOffset, val);
    WHILE ~(pos IN val) DO
      SYSTEM.PUT(reg + BASE.ACLR, {pos});
      SYSTEM.GET(reg + DoneOffset, val)
    END
  END ReleaseReset;


  PROCEDURE ApplyReset*(reg, pos: INTEGER);
    CONST DoneOffset = 8;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(reg + DoneOffset, val);
    WHILE pos IN val DO
      SYSTEM.PUT(reg + BASE.ASET, {pos});
      SYSTEM.GET(reg + DoneOffset, val)
    END
  END ApplyReset;


  (* -- watchdog resets -- *)

  PROCEDURE* SetPowerOnWatchdogResets*(components: SET);
  BEGIN
    SYSTEM.PUT(SYS.PSM_WDSEL, components)
  END SetPowerOnWatchdogResets;


  PROCEDURE* SetResetWatchdogResets*(devices: SET);
  BEGIN
    SYSTEM.PUT(SYS.RESETS_WDSEL, devices)
  END SetResetWatchdogResets;

END RST.
