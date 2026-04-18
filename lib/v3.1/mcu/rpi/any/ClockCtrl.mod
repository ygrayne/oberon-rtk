MODULE ClockCtrl;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Clock-gating: enabling and disabling of specific clocks for power-savings.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, SYS := CLK_SYS;


  (* clock gating *)
  (* note: all clocks are enabled upon reset *)

  PROCEDURE* EnableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(SYS.CLK_WAKE_EN0 + BASE.ASET, en0);
    SYSTEM.PUT(SYS.CLK_WAKE_EN1 + BASE.ASET, en1)
  END EnableClockWake;

  PROCEDURE* DisableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(SYS.CLK_WAKE_EN0 + BASE.ACLR, en0);
    SYSTEM.PUT(SYS.CLK_WAKE_EN1 + BASE.ACLR, en1)
  END DisableClockWake;

  PROCEDURE* EnableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(SYS.CLK_SLEEP_EN0 + BASE.ASET, en0);
    SYSTEM.PUT(SYS.CLK_SLEEP_EN1 + BASE.ASET, en1)
  END EnableClockSleep;

  PROCEDURE* DisableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(SYS.CLK_SLEEP_EN0 + BASE.ACLR, en0);
    SYSTEM.PUT(SYS.CLK_SLEEP_EN1 + BASE.ACLR, en1)
  END DisableClockSleep;

  PROCEDURE* GetEnabled*(VAR en0, en1: SET);
  BEGIN
    SYSTEM.GET(SYS.CLK_ENABLED0, en0);
    SYSTEM.GET(SYS.CLK_ENABLED1, en1)
  END GetEnabled;

END ClockCtrl.
