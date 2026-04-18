MODULE DevicesC1;
(**
  Oberon RTK Framework v3.1
  --
  Example program, multi-threaded, dual-core
  Simple dual-core watchdog
  See https://oberon-rtk.org/docs/examples/v2/watchdog
  --
  Config devices for core 1
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
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
