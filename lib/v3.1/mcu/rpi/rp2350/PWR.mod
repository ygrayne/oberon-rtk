MODULE PWR;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  POWMAN power controller
  --
  MCU: RP2350
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := POWMAN_SYS;

  CONST
    BootMagic0 = 0B007C0D3H;
    BootMagic1 = 04FF83F2DH;


  PROCEDURE* SetPowmanBootVector*(stackPointer, entryPoint: INTEGER);
  BEGIN
    SYSTEM.PUT(SYS.POWMAN_BOOT0, BootMagic0);
    INCL(SYSTEM.VAL(SET, entryPoint), 0);
    SYSTEM.PUT(SYS.POWMAN_BOOT1, BITS(entryPoint) / BITS(BootMagic1));
    SYSTEM.PUT(SYS.POWMAN_BOOT2, stackPointer);
    SYSTEM.PUT(SYS.POWMAN_BOOT3, entryPoint)
  END SetPowmanBootVector;


  (* Secure/Non-secure, RP2350 only *)

  PROCEDURE GetDevSec*(VAR reg: INTEGER);
  BEGIN
    reg := SYS.POWMAN_SEC_reg
  END GetDevSec;

END PWR.
