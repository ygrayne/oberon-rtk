MODULE SysTick;
(**
  Oberon RTK Framework
  Version v4.0
  --
  SysTick for ECS kernel.
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTK, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER; handler: PROCEDURE; prio: INTEGER);
  BEGIN
    SYSTK.InstallExcHandler(handler, prio);
    SYSTK.Configure(Clocks.SYSTICK_FREQ, msPerTick)
  END Config;

  PROCEDURE Enable*;
  BEGIN
    SYSTK.EnableExc
  END Enable;

END SysTick.
