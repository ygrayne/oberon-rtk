MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  System tick for kernel-v4
  Kernel-v4
  --
  MCU: STM32U585AI, STM32H573II
  --
  Note the 24 bit limitation on the reload and counter registers. If SysTick is running off
  HCLK/8 with HCLK at 160 MHz, this limits the maximum achievable SysTick interval to
  about 800 ms.
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTK, RST, DEV := SYSTICK_DEV, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER; handler: PROCEDURE; prio: INTEGER);
  BEGIN
    RST.ConfigDevClock(SYSTK.CLK_HCLK, DEV.SYSTICK_FC_reg, DEV.SYSTICK_FC_pos, DEV.SYSTICK_FC_width);
    SYSTK.InstallExcHandler(handler, prio);
    SYSTK.Configure(Clocks.HCLK_FRQ DIV 8, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYSTK.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYSTK.EnableExc
  END Enable;

END SysTick.
