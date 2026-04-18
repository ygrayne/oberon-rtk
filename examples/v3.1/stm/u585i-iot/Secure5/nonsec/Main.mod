MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Main module, Non-secure
  Test program Secure5
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
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
    RuntimeErrors.Install;
    Console.Install;
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults
  END run;

BEGIN
  run
END Main.
