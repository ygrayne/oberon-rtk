MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Main module
  Single image or Secure image
  --
  Always runs on core 0.
  See module MainC1 for core 1.
  --
  MCU: RP2350 (A, B)
  Board: Pico2
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT (* keep first three imports in this order  *)
    Startup, MemMap, Memory, Devices, DevicesC1, Clocks, Console,
    RuntimeErrors, RuntimeErrorsOut;

  PROCEDURE run;
  (* runs on core 0 *)
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
    (*Security.Config *) (* for S/NS programs, import Security is used *)
  END run;


  PROCEDURE ConfigC1*;
  (* to be called from core 1 *)
  BEGIN
    DevicesC1.Config;
    RuntimeErrors.Install;
    Console.Install;
    RuntimeErrors.InstallErrorHandler(RuntimeErrorsOut.ErrorHandler);
    RuntimeErrors.EnableFaults
  END ConfigC1;

BEGIN
  run
END Main.
