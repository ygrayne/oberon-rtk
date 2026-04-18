MODULE Security;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific Secure/Non-secure configuration.
  --
  For Secure programs, copy to the project directory and program accordingly.
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)


  PROCEDURE cfgSRAM;
  END cfgSRAM;

  PROCEDURE cfgSAU;
  END cfgSAU;

  PROCEDURE cfgExceptions;
  END cfgExceptions;

  PROCEDURE cfgPeripherals;
  END cfgPeripherals;


  PROCEDURE Config*;
  BEGIN
    cfgSRAM;
    cfgSAU;
    cfgExceptions;
    cfgPeripherals
  END Config;

END Security.
