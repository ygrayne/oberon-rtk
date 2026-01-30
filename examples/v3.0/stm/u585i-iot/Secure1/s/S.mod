(*! SEC *)
MODULE S;
(**
  Oberon RTK Framework v3.0
  --
  Experimental program Secure1
  https://oberon-rtk.org/docs/examples/v3/secure1/
  Secure program
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, MCU := MCU2, S0, GTZC, SAU, TZ;

  CONST
    (* Secure GPIOH registers *)
    GPIOH_BSSR = MCU.GPIOH_BASE + MCU.GPIO_BSRR_Offset + MCU.PERI_S_Offset;
    GPIOH_MODER = MCU.GPIOH_BASE + MCU.GPIO_MODER_Offset + MCU.PERI_S_Offset;
    GPIOH_OSPEEDR = MCU.GPIOH_BASE + MCU.GPIO_OSPEEDR_Offset + MCU.PERI_S_Offset;
    GPIOH_SECCFGR = MCU.PORTH + MCU.GPIO_SECCFGR_Offset + MCU.PERI_S_Offset;

    (* Non-secure program flash address *)
    NSimageAddr = 08100000H;

    LEDred   = 6; (* GPIOH *)
    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE cfgSRAM;
  BEGIN
    (* set all super-blocks of SRAM1 to Secure *)
    GTZC.ConfigSRAMsecRange(GTZC.SRAM1, 0, 12, GTZC.AllBlocksSecure);
    (* set all super-blocks of SRAM3 to Non-secure *)
    GTZC.ConfigSRAMsecRange(GTZC.SRAM3, 0, 32, GTZC.AllBlocksNonSecure)
  END cfgSRAM;


  PROCEDURE cfgGPIO; (* Secure part *)
    VAR val: SET; reg, devNo: INTEGER;
  BEGIN
    (* enable GPIOH clock, module CLK style *)
    reg := MCU.DEV_GPIOH DIV 32;
    reg := MCU.RCC_AHB1ENR + MCU.PERI_S_Offset + (reg * 4);
    devNo := MCU.DEV_GPIOH MOD 32;
    SYSTEM.GET(reg, val);
    val := val + {devNo};
    SYSTEM.PUT(reg, val);

    (* set all GPIOH pins no Non-secure, apart from LEDred *)
    SYSTEM.PUT(GPIOH_SECCFGR, {LEDred});

    (* config Secure LEDred pin *)
    S0.SetBits2(LEDred, GPIOH_MODER, MODER_Out);
    S0.SetBits2(LEDred, GPIOH_OSPEEDR, OSPEED_High);

    (* LEDred off *)
    SYSTEM.PUT(GPIOH_BSSR, {LEDred});
  END cfgGPIO;


  PROCEDURE enableFaults;
  (* useful in debugger *)
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_SHCSR, val);
    val := val + {16, 17, 18, 19};
    SYSTEM.PUT(MCU.PPB_SHCSR, val)
  END enableFaults;


  PROCEDURE configSAU;
    CONST Enabled = 1; Disabled = 0;
    VAR cfg: SAU.RegionCfg; r: INTEGER;
  BEGIN
    SAU.Enable;
    r := 0;
    (* flash NSC, top 128k of block1  *)
    cfg.baseAddr := 0C0FE000H;
    cfg.limitAddr := 0C0FFFFFH;
    cfg.nsc := Enabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    (* flash NS, all block2 *)
    cfg.baseAddr := 08100000H;
    cfg.limitAddr := 081FFFFFH;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    (* sram3 NS, all blocks *)
    cfg.baseAddr := 020040000H;
    cfg.limitAddr := 0200BFFFFH;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    (* peripheral devices NS, all devices *)
    cfg.baseAddr := 40000000H;
    cfg.limitAddr := 4FFFFFFFH;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    WHILE r < SAU.NumRegions DO
      SAU.DisableRegion(r);
      INC(r)
    END
  END configSAU;

BEGIN
  enableFaults;
  configSAU;
  cfgSRAM;
  cfgGPIO;
  TZ.StartNonSecure(NSimageAddr)
END S.
