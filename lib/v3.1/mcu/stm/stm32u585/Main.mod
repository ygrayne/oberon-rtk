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
    Startup, MemMap, Memory, Devices, Clocks, Console,
    RuntimeErrors, RuntimeErrorsOut;

  PROCEDURE run;
  BEGIN
    ASSERT(Startup.Done);
    ASSERT(MemMap.Done);
    ASSERT(Memory.Done);
    Devices.Config;
    Clocks.Config;
    RuntimeErrors.Install;
    Console.Install(Clocks.SYSCLK_FRQ);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    (*Security.Config *) (* for S/NS programs, import Security is used *)
  END run;

BEGIN
  run
END Main.
