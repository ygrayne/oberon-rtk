MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Kernel-v4
  System tick
  Enable interrupt and install an interrupt handler
  so we can use WFE/WFI in kernel loop.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYST, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER; handler: PROCEDURE; prio: INTEGER);
  BEGIN
    SYST.InstallExcHandler(handler, prio);
    SYST.Configure(Clocks.SYSTICK_FREQ, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYST.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYST.EnableExc
  END Enable;

END SysTick.
