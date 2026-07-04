MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Main module
  --
  MCU: RP2040
  Board: Pico2
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    Startup, MemMap, Memory, Clocks, Console,
    RuntimeErrors, RuntimeErrorsOut, LED;

  PROCEDURE run;
  (* runs on core 0 *)
  BEGIN
    ASSERT(Startup.Done);
    ASSERT(MemMap.Done);
    ASSERT(Memory.Done);
    Clocks.Config;
    LED.Config;
    RuntimeErrors.Install;
    Console.Install(Console.SYSTERM0);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler)
  END run;


  PROCEDURE ConfigC1*;
  (* to be called from core 1 *)
  BEGIN
    RuntimeErrors.Install;
    Console.Install(Console.SYSTERM1);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
  END ConfigC1;

BEGIN
  run
END Main.
