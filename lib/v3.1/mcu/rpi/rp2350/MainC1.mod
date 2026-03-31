MODULE MainC1;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Main module, core1
  Call Init from core0 when starting core1 program:
    Cores.StartCoreOne(CoreOne.Run, MainC1.Init)
  --
  Type: MCU + board
  --
  MCU: RP2350A
  Board: Pico2
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    ConsoleCfg, RuntimeErrors, RuntimeErrorsOut, SecureCfg, FPUcfg;

  PROCEDURE Init*;
  BEGIN
    ConsoleCfg.Init;
    RuntimeErrors.Install;
    RuntimeErrorsOut.SetWriter(ConsoleCfg.Werr[1]);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    FPUcfg.Init;
    SecureCfg.Init
  END Init;

END MainC1.
