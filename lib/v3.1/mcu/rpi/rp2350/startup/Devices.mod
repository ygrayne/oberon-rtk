MODULE Devices;
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

  IMPORT LED, FPU;

  PROCEDURE Config*;
  BEGIN
    LED.Config;
    FPU.Enable
  END Config;

END Devices.
