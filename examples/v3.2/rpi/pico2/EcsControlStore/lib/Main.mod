MODULE Main;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Main module
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    Startup, MemMap, Memory, Clocks, Console,
    RuntimeErrors, RuntimeErrorsOut, FPU, LED;

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
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    FPU.Enable
    (*Security.Config *) (* for S/NS programs, import Security if used *)
  END run;


  PROCEDURE ConfigC1*;
  (* to be called from core 1 *)
  BEGIN
    RuntimeErrors.Install;
    Console.Install(Console.SYSTERM1);
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults;
    FPU.Enable
  END ConfigC1;

BEGIN
  run
END Main.
