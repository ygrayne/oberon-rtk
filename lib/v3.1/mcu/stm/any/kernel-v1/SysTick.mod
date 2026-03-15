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

  IMPORT SYST, CLK, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER);
    CONST TwoBits = 2;
  BEGIN
    CLK.ConfigDevClock(SYST.CLK_HCLK, CLK.CLK_SYST_REG, CLK.CLK_SYST_POS, TwoBits);
    SYST.Configure(Clocks.HCLK_FRQ DIV 8, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYST.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYST.Enable
  END Enable;

END SysTick.
