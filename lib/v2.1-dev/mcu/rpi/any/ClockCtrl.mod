MODULE ClockCtrl;
(**
  Oberon RTK Framework v2
  --
  Clock-gating: enabling and disabling of specific clocks for power-savings.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  (* clock gating *)
  (* note: all clocks are enabled upon reset *)

  PROCEDURE* EnableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_WAKE_EN0 + MCU.ASET, en0);
    SYSTEM.PUT(MCU.CLK_WAKE_EN1 + MCU.ASET, en1)
  END EnableClockWake;

  PROCEDURE* DisableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_WAKE_EN0 + MCU.ACLR, en0);
    SYSTEM.PUT(MCU.CLK_WAKE_EN1 + MCU.ACLR, en1)
  END DisableClockWake;

  PROCEDURE* EnableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_SLEEP_EN0 + MCU.ASET, en0);
    SYSTEM.PUT(MCU.CLK_SLEEP_EN1 + MCU.ASET, en1)
  END EnableClockSleep;

  PROCEDURE* DisableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_SLEEP_EN0 + MCU.ACLR, en0);
    SYSTEM.PUT(MCU.CLK_SLEEP_EN1 + MCU.ACLR, en1)
  END DisableClockSleep;

  PROCEDURE* GetEnabled*(VAR en0, en1: SET);
  BEGIN
    SYSTEM.GET(MCU.CLK_ENABLED0, en0);
    SYSTEM.GET(MCU.CLK_ENABLED1, en1)
  END GetEnabled;

END ClockCtrl.
