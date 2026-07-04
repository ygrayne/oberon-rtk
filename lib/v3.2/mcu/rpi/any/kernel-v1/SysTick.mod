MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  System tick for kernel-v1
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTK, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER);
  BEGIN
    SYSTK.Configure(Clocks.SYSTICK_FREQ, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYSTK.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYSTK.Enable
  END Enable;

END SysTick.
