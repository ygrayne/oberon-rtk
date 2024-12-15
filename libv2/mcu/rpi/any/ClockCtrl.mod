MODULE ClockCtrl;
(**
  Oberon RTK Framework v2
  --
  Clocks control and monitor functions.
  --
  * clock monitor on pin 21
  * clock-gating: enabling and disabling of specific clocks for power-savings
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, GPIO;

  CONST
    (* CLK_GPOUT0_CTRL *)
    CLK_GPOUT0_CTRL_ENABLE    = 11;
    CLK_GPOUT0_CTRL_AUXSRC_1  = 8;
    CLK_GPOUT0_CTRL_AUXSRC_0  = 5;


  (* clk signal external monitoring *)
  (* on pin 21 using CLOCK GPOUT0 *)

  PROCEDURE Monitor*(which: INTEGER);
    CONST Pin = 21;
    VAR x: INTEGER;
  BEGIN
    (* set up clock GPOUT0 *)
    x := 0;
    BFI(x, CLK_GPOUT0_CTRL_AUXSRC_1, CLK_GPOUT0_CTRL_AUXSRC_0, which);
    SYSTEM.PUT(MCU.CLK_GPOUT0_CTRL, x);
    SYSTEM.PUT(MCU.CLK_GPOUT0_CTRL + MCU.ASET, {CLK_GPOUT0_CTRL_ENABLE});
    GPIO.SetFunction(Pin, MCU.IO_BANK0_Fclk)
  END Monitor;

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
