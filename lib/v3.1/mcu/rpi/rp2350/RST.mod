MODULE RST;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Resets controller
  Power-on state machine
  --
  MCU: RP2350
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, SYS := RESETS_SYS;

  CONST
  (*
    (* POWMAN_WDSEL bits *)
    (* for 'SetPowmanWatchdogReset' *)
    POWMAN_WDSEL_RST_PSM*          = 12;
    POWMAN_WDSEL_RST_SWCORE*       = 8;
    POWMAN_WDSEL_RST_POWMAN*       = 4;
    POWMAN_WDSEL_RST_POWMAN_ASYNC* = 0;

    (* POWMAN [31:16] passcode *)
    POWMAN_PASSCODE = 05AFE0000H;
*)

  PROCEDURE ReleaseReset*(reg, pos: INTEGER);
    CONST DoneOffset = 4;
    VAR val: SET;
  BEGIN
    SYSTEM.PUT(reg + BASE.ACLR, {pos});
    REPEAT
      SYSTEM.GET(reg + DoneOffset, val)
    UNTIL ~(pos IN val)
  END ReleaseReset;


  PROCEDURE ApplyReset*(reg, pos: INTEGER);
    CONST DoneOffset = 4;
    VAR val: SET;
  BEGIN
    SYSTEM.PUT(reg + BASE.ASET, {pos});
    REPEAT
      SYSTEM.GET(reg + DoneOffset, val)
    UNTIL pos IN val
  END ApplyReset;


  PROCEDURE* GetDevSec*(VAR reg: INTEGER);
  BEGIN
    reg := SYS.RESETS_SEC_reg
  END GetDevSec;


  (* -- watchdog resets -- *)

  PROCEDURE* SetPowerOnWatchdogResets*(components: SET);
  (* system resets *)
  BEGIN
    SYSTEM.PUT(SYS.PSM_WDSEL, components)
  END SetPowerOnWatchdogResets;


  PROCEDURE* SetResetWatchdogResets*(devices: SET);
  (* sub-system resets *)
  BEGIN
    SYSTEM.PUT(SYS.RESETS_WDSEL, devices)
  END SetResetWatchdogResets;

(*
  #todo
  PROCEDURE* SetPowmanWatchdogReset*(reset: INTEGER);
  (* chip resets *)
  BEGIN
    SYSTEM.PUT(SYS_2.POWMAN_WDSEL, POWMAN_PASSCODE + reset)
  END SetPowmanWatchdogReset;
*)

END RST.
