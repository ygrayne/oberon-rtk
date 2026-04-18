MODULE Security;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Test program Secure6
  Program-specific Secure/Non-secure configuration.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, SAU, FPU, UART, LED, AccessCtrl;


  PROCEDURE cfgSRAM;
  BEGIN
  END cfgSRAM;


  PROCEDURE cfgSAU;
    CONST Enabled = 1; Disabled = 0;
    VAR cfg: SAU.RegionCfg; r: INTEGER;
  BEGIN
    r := 0;
    (* flash NSC *)
    cfg.baseAddr := 01007E000H;
    cfg.limitAddr := 010080000H - 1;
    cfg.nsc := Enabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    (* flash NS *)
    cfg.baseAddr := 010080000H;
    cfg.limitAddr := 010100000H - 1;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(r, cfg);
    INC(r);
    (* SRAM4-7 *)
    cfg.baseAddr := 020040000H;
    cfg.limitAddr := 020080000H - 1;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(r, cfg);
    (* leave reserved region 7 alone, even though it's not used here *)
    INC(r);
    WHILE r < SAU.NumRegions - 1 DO
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
    VAR reg: INTEGER;
  BEGIN
    FPU.EnableNSaccess;
    UART.GetDevSec(UART.UART0, reg);
    AccessCtrl.SetNonsecPriv(reg);
    AccessCtrl.SetGPIOnonsec({LED.Pico}, {})
  END cfgPeripherals;


  PROCEDURE Config*;
  BEGIN
    cfgSRAM;
    cfgSAU;
    cfgExceptions;
    cfgPeripherals
  END Config;

END Security.
