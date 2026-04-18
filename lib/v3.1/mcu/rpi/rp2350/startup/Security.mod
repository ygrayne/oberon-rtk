MODULE SecureCfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific Secure/Non-secure configuration.
  --
  For Secure programs, copy to the project directory and program accordingly.
  --
  MCU: RP2350A
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)


  PROCEDURE cfgSRAM;
  END cfgSRAM;


  PROCEDURE cfgSAU;
  END cfgSAU;


  PROCEDURE cfgPeripherals;
  END cfgPeripherals;


  PROCEDURE Init*;
  BEGIN
    cfgSRAM;
    cfgSAU;
    cfgPeripherals
  END Init;

END SecureCfg.
