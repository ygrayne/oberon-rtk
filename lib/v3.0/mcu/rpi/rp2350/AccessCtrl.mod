MODULE AccessCtrl;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Access control for devices
  --
  Type: MCU
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* bits *)
    DBG*    = 7;
    DMA*    = 6;
    CORE1*  = 5;
    CORE0*  = 4;
    SP*     = 3;
    SU*     = 2;
    NSP*    = 1;
    NSU*    = 0;


  PROCEDURE* SetDevAccess*(reg: INTEGER; value: SET);
  BEGIN
    SYSTEM.PUT(reg, value)
  END SetDevAccess;


  PROCEDURE* SetDevNonSecPriv*(reg: INTEGER);
  BEGIN
    SYSTEM.PUT(reg + MCU.ASET, {NSP});
    SYSTEM.PUT(reg + MCU.ACLR, {NSU})
  END SetDevNonSecPriv;


  PROCEDURE* SetGPIOnonSec*(reg: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(reg + MCU.ASET, pinMask)
  END SetGPIOnonSec;


END AccessCtrl.
