MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Main module, Secure
  Test program Secure5
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    Startup, MemMap, Memory, Devices, Clocks, Console,
    RuntimeErrors, RuntimeErrorsOut, Security;

  PROCEDURE run;
  BEGIN
    ASSERT(Startup.Done);
    ASSERT(MemMap.Done);
    ASSERT(Memory.Done);
    Devices.Config;
    Clocks.Config;
    RuntimeErrors.Install;
    Console.Install;
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    Security.Config
  END run;

BEGIN
  run
END Main.
