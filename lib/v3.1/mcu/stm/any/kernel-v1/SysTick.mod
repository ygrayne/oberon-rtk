MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  System tick
  Kernel v1
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTK, RST, DEV := SYSTICK_DEV, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER);
  BEGIN
    RST.ConfigDevClock(SYSTK.CLK_HCLK, DEV.SYSTICK_FC_reg, DEV.SYSTICK_FC_pos, DEV.SYSTICK_FC_width);
    SYSTK.Configure(Clocks.HCLK_FRQ DIV 8, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYSTK.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYSTK.Enable
  END Enable;

END SysTick.
