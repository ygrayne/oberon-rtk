MODULE StartUp;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Start-up control
  --
  MCU: MCXA346
  --
  Note: MCU starts with resets applied.
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
    reg := MCU.MRCC_GLB_RST0_SET + (reg * MCU.MRCC_GLB_RST_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END ReleaseReset;


  PROCEDURE* ApplyReset*(device: INTEGER);
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.MRCC_GLB_RST0_CLR + (reg * MCU.MRCC_GLB_RST_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END ApplyReset;


  PROCEDURE* EnableClock*(device: INTEGER);
  (* bus clock *)
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.MRCC_GLB_CC0_SET + (reg * MCU.MRCC_GLB_CC_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END EnableClock;


  PROCEDURE* DisableClock*(device: INTEGER);
  (* bus clock *)
  (* MCU.DEV_* devices *)
    VAR reg, devNo: INTEGER;
  BEGIN
    reg := device DIV 32;
    reg := MCU.MRCC_GLB_CC0_CLR + (reg * MCU.MRCC_GLB_CC_Offset);
    devNo := device MOD 32;
    SYSTEM.PUT(reg, {devNo})
  END DisableClock;

END StartUp.
