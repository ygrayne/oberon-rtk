MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Main module
  Single image or Secure image
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    StartupCfg, MemCfg, Memory, DevCfg, ClockCfg, ConsoleCfg, Clocks,
    RuntimeErrors, RuntimeErrorsOut, SecureCfg, FPUcfg;

  PROCEDURE init;
  BEGIN
    ASSERT(StartupCfg.Initialised);
    ASSERT(MemCfg.Initialised);
    ASSERT(Memory.Initialised);
    DevCfg.Init;
    ClockCfg.Init;
    ConsoleCfg.Init(Clocks.SYSCLK_FRQ);
    RuntimeErrors.Install;
    RuntimeErrorsOut.SetWriter(ConsoleCfg.Werr[0]);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    FPUcfg.Init;
    SecureCfg.Init
  END init;

BEGIN
  init
END Main.
