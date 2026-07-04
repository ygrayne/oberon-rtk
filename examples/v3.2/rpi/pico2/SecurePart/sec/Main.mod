MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Test program SecurePart
  Main module, Secure
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    Startup, MemMap, Memory, Clocks, Console,
    RuntimeErrors, RuntimeErrorsOut, Security, LED, FPU;

  PROCEDURE run;
  BEGIN
    ASSERT(Startup.Done);
    ASSERT(MemMap.Done);
    ASSERT(Memory.Done);
    Clocks.Config;
    LED.Config;
    RuntimeErrors.Install;
    Console.Install(Console.SYSTERM0);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    FPU.Enable;
    Security.Config
  END run;

BEGIN
  run
END Main.
