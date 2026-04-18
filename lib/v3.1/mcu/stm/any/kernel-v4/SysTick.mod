MODULE SysTick;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  System tick for kernel-v4
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

  IMPORT SYST, RST, DEV := SYSTICK_DEV, Clocks;


  PROCEDURE Config*(msPerTick: INTEGER; handler: PROCEDURE; prio: INTEGER);
  BEGIN
    RST.ConfigDevClock(SYST.CLK_HCLK, DEV.SYSTICK_FC_reg, DEV.SYSTICK_FC_pos, DEV.SYSTICK_FC_width);
    SYST.InstallExcHandler(handler, prio);
    SYST.Configure(Clocks.HCLK_FRQ DIV 8, msPerTick)
  END Config;


  PROCEDURE Tick*(): BOOLEAN;
    RETURN SYST.Tick()
  END Tick;


  PROCEDURE Enable*;
  BEGIN
    SYST.EnableExc
  END Enable;

END SysTick.
