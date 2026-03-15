MODULE PWR;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  POWMAN power controller
  --
  Type: MCU
  --
  MCU: RP2350
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    BootMagic0 = 0B007C0D3H;
    BootMagic1 = 04FF83F2DH;


  PROCEDURE* SetPowmanBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.POWMAN_BOOT0, BootMagic0);
    INCL(SYSTEM.VAL(SET, entryPoint), 0);
    SYSTEM.PUT(MCU.POWMAN_BOOT1, BITS(entryPoint) / BITS(BootMagic1));
    SYSTEM.PUT(MCU.POWMAN_BOOT2, stackPointer);
    SYSTEM.PUT(MCU.POWMAN_BOOT3, entryPoint)
  END SetPowmanBootVector;

END PWR.
