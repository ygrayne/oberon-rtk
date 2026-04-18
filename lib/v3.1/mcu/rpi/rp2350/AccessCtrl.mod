MODULE AccessCtrl;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Access control for devices
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, SYS := ACCESSCTRL_SYS;

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

    Key = BITS(LSL(0ACCEH, 16));


  PROCEDURE* SetAccess*(reg: INTEGER; value: SET);
  BEGIN
    SYSTEM.PUT(reg, value + Key)
  END SetAccess;


  PROCEDURE* SetNonsecPriv*(reg: INTEGER);
  BEGIN
    SYSTEM.PUT(reg + BASE.ASET, {NSP} + Key);
    SYSTEM.PUT(reg + BASE.ACLR, {NSU} + Key)
  END SetNonsecPriv;


  PROCEDURE* SetNonsecNonpriv*(reg: INTEGER);
  BEGIN
    SYSTEM.PUT(reg + BASE.ASET, {NSP, NSU} + Key)
  END SetNonsecNonpriv;


  PROCEDURE* SetGPIOnonsec*(nonsecPinsLow, nonsecPinsHigh: SET);
    CONST GPIOpinsHigh = {0 .. 15};
  BEGIN
    SYSTEM.PUT(SYS.ACCESSCTRL_GPIO_NSMASK0 + BASE.ASET, nonsecPinsLow);
    SYSTEM.PUT(SYS.ACCESSCTRL_GPIO_NSMASK1 + BASE.ASET, nonsecPinsHigh * GPIOpinsHigh)
  END SetGPIOnonsec;


END AccessCtrl.
