MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  System tick for kernel-v4.
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTK, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER; handler: PROCEDURE; prio: INTEGER);
  BEGIN
    SYSTK.InstallExcHandler(handler, prio);
    SYSTK.Configure(Clocks.SYSTICK_FREQ, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYSTK.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYSTK.EnableExc
  END Enable;

END SysTick.
