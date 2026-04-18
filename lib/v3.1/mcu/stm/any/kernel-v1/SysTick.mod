MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  System tick for kernel-v1
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYST, RST, DEV := SYSTICK_DEV, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER);
  BEGIN
    RST.ConfigDevClock(SYST.CLK_HCLK, DEV.SYSTICK_FC_reg, DEV.SYSTICK_FC_pos, DEV.SYSTICK_FC_width);
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
