MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  System tick for kernel-v1
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYST, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER);
  BEGIN
    SYST.Configure(SYST.CLK_HCLK, Clocks.HCLK_FRQ DIV 8, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYST.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYST.Enable
  END Enable;

END SysTick.
