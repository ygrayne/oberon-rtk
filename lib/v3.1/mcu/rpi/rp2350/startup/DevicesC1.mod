MODULE DevicesC1;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program-specific peripheral device configuration.
  --
  For different configurations, copy to the project directory and adapt accordingly.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT FPU;

  PROCEDURE Config*;
  BEGIN
    FPU.Enable
  END Config;

END DevicesC1.
