MODULE FPUcfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific FPU configuration.
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT FPU;

  PROCEDURE Init*;
  BEGIN
    FPU.Init
  END Init;

END FPUcfg.
