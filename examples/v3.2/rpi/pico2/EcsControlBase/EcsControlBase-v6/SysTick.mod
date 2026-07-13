MODULE SysTick;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v6
  --
  MCU: RP2350
  Board: Pico2
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


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYSTK.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYSTK.EnableExc
  END Enable;

END SysTick.
