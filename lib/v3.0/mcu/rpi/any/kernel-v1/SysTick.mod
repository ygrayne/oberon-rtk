MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  System tick for kernel-v1
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYST, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER);
  BEGIN
    SYST.Configure(Clocks.SYSTICK_FREQ, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYST.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYST.Enable
  END Enable;

END SysTick.
