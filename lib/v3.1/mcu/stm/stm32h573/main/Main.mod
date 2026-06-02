MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Main module
  Single image or Secure image
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    Startup, MemMap, Memory, Clocks, Console,
    RuntimeErrors, RuntimeErrorsOut, LED, FPU;

  PROCEDURE run;
  BEGIN
    ASSERT(Startup.Done);
    ASSERT(MemMap.Done);
    ASSERT(Memory.Done);
    Clocks.Config;
    LED.Config;
    RuntimeErrors.Install;
    Console.Install(Clocks.PLL2Q_FREQ);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    FPU.Enable
    (*Security.Config *) (* for S/NS programs, import Security is used *)
  END run;

BEGIN
  run
END Main.
