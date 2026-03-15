MODULE InitCoreOne;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Initialisation code that has to run on core 1.
  Complements module Main, which always runs on core 0.
  --
  Type: MCU
  --
  MCU: RP2040
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  PROCEDURE Init*;
  BEGIN
    (* none for now *)
  END Init;

END InitCoreOne.
