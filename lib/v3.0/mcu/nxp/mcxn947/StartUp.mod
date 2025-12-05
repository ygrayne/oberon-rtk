MODULE StartUp;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Start-up control
  --
  MCU: MCXN947
  --
  Note: MCU starts with resets released.
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  PROCEDURE* ReleaseReset*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.SYSCON_PRESET_CTRL0_CLR + (reg * MCU.SYSCON_PRESET_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END ReleaseReset;


  PROCEDURE* ApplyReset*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.SYSCON_PRESET_CTRL0_SET + (reg * MCU.SYSCON_PRESET_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END ApplyReset;


  PROCEDURE* EnableClock*(device: INTEGER);
  (* bus clock *)
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.SYSCON_AHBCLK_CTRL0_SET + (reg * MCU.SYSCON_AHBCLK_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END EnableClock;


  PROCEDURE* DisableClock*(device: INTEGER);
  (* bus clock *)
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.SYSCON_AHBCLK_CTRL0_CLR + (reg * MCU.SYSCON_AHBCLK_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END DisableClock;

END StartUp.
