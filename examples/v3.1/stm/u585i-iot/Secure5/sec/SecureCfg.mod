MODULE SecureCfg;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Program Secure5
  Program-specific Secure/Non-secure configuration.
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, GTZC, SAU, RCC, PWR, UART, UARTdef;


  PROCEDURE cfgSRAM;
  BEGIN
    (* set all super-blocks of SRAM1 to Secure *)
    GTZC.ConfigSRAMsecRange(GTZC.SRAM1, 0, 12, GTZC.AllBlocksSecure);
    (* set all super-blocks of SRAM3 to Non-secure *)
    GTZC.ConfigSRAMsecRange(GTZC.SRAM3, 0, 32, GTZC.AllBlocksNonSecure)
  END cfgSRAM;


  PROCEDURE cfgSAU;
    CONST Enabled = 1; Disabled = 0;
    VAR cfg: SAU.RegionCfg; r: INTEGER;
  BEGIN
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
    (* we're cutting out FLASH from NS access, since the *)
    (* device does not have reasonable S/NS protection mechanisms *)
    (* neither in itself, or via GTZC *)
    (* 1. peripheral devices NS, all devices below FLASH *)
    cfg.baseAddr := 40000000H;
    cfg.limitAddr := 40021FFFH;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    (* 2. peripheral devices NS, all devices above FLASH *)
    cfg.baseAddr := 40023000H;
    cfg.limitAddr := 4FFFFFFFH;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    WHILE r < SAU.NumRegions DO
      SAU.DisableRegion(r);
      INC(r)
    END;
    SAU.Enable
  END cfgSAU;


  PROCEDURE* cfgExceptions;
    CONST BFHFNMINS = 13;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(PPB.AIRCR, val);
    val := val - {16 .. 31} + BITS(LSL(PPB.AIRCR_VECTKEY, 16)) + {BFHFNMINS};
    SYSTEM.PUT(PPB.AIRCR, val)
  END cfgExceptions;


  PROCEDURE cfgPeripherals;
  (* note: S.mod handles GPIO *)
    VAR reg, pos: INTEGER;
  BEGIN
    RCC.SecureAll;
    PWR.SecureAll;
    GTZC.SetDevSecAll;
    UART.GetDevSec(UARTdef.USART1, reg, pos);
    GTZC.ReleaseDevSec(reg, pos)
  END cfgPeripherals;


  PROCEDURE Init*;
  BEGIN
    cfgSRAM;
    cfgSAU;
    cfgExceptions;
    cfgPeripherals
  END Init;

END SecureCfg.
