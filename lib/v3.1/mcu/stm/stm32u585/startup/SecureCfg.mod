MODULE SecureCfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific Secure/Non-secure configuration.
  --
  For Secure programs, copy to the project directory and program accordingly.
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
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


  PROCEDURE Init*;
  BEGIN
    cfgSRAM;
    cfgSAU;
    cfgExceptions;
    cfgPeripherals
  END Init;

END SecureCfg.
