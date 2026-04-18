MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Test program Secure5
  Main module, Non-secure
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    Startup, MemMap, Memory, Devices, Console,
    RuntimeErrors, RuntimeErrorsOut;

  PROCEDURE run;
  BEGIN
    ASSERT(Startup.Done);
    ASSERT(MemMap.Done);
    ASSERT(Memory.Done);
    Devices.Config;
    RuntimeErrors.Install;
    Console.Install;
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
  END run;

BEGIN
  run
END Main.
