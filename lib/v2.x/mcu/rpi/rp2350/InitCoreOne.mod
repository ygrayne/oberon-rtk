MODULE InitCoreOne;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Initialisation code that has to run on core 1.
  Complements module Main, which always runs on core 0.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT RuntimeErrors, FPUctrl;

  CONST
    FPUnonSecAccess = FALSE; (* enable for secure access only for now *)
    FPUtreatAsSec = FALSE;


  PROCEDURE Init*;
  BEGIN
    RuntimeErrors.EnableFaults;
    FPUctrl.Init(FPUnonSecAccess, FPUtreatAsSec)
  END Init;

END InitCoreOne.
