MODULE PWR;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Power management
  --
  Notes:
  - should/will be equipped with more targeted procedures for the various control
    functions such as wake-up and pullup/down
  - the pin-oriented control registers auto-follow the GPIO_SECCFGR settings
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV0, RST;

  CONST
    Range1* = 3;  (* 1.2 V, 160 MHz *)
    Range2* = 2;  (* 1.1 V, 110 MHz *)
    Range3* = 1;  (* 1.0 V, 55 MHz *)
    Range4* = 0;  (* 0.9 V, 25 MHz, reset *)

    KeepSecure* = 0;
    ReleaseSecure* = 1;

    (* PWR_VOSR bits and values *)
    PWR_VOSR_BOOSTEN = 18;
    PWR_VOSR_VOSRDY = 15;
    PWR_VOSR_BOOSTRDY = 14;


  TYPE
    ReleaseSecCfg* = RECORD
      lpMode*: INTEGER;     (* LPMSEC: CR1, CR2, CSSF *)
      voltDet*: INTEGER;    (* VDMSEC: CR3, SVMCR *)
      bkupDom*: INTEGER;    (* VBSEC: BDCR1, BDCR2, DBPR *)
      pullCfg*: INTEGER;    (* APCSEC: APCR *)
      wakeUp*: SET          (* WUP1SEC..WUP8SEC, bits 0..7 *)
    END;


  PROCEDURE* SetVoltageRange*(range: INTEGER);
  (* is S-restricted if RCC_SECCFGR.SYSCLKSEC = 1 *)
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(CFG.PWR_VOSR, val);
    BFI(val, 17, 16, range);
    SYSTEM.PUT(CFG.PWR_VOSR, val);
    REPEAT UNTIL SYSTEM.BIT(CFG.PWR_VOSR, PWR_VOSR_VOSRDY);
    SYSTEM.GET(CFG.PWR_VOSR, val);
    IF range > 1 THEN
      BFI(val, PWR_VOSR_BOOSTEN, 1);
      SYSTEM.PUT(CFG.PWR_VOSR, val);
      REPEAT UNTIL SYSTEM.BIT(CFG.PWR_VOSR, PWR_VOSR_BOOSTRDY)
    ELSE
      BFI(val, PWR_VOSR_BOOSTEN, 0);
      SYSTEM.PUT(CFG.PWR_VOSR, val)
    END
  END SetVoltageRange;


  PROCEDURE* SecureAll*;
  BEGIN
    SYSTEM.PUT(CFG.PWR_SEC, CFG.PWR_SEC_ALL)
  END SecureAll;


  PROCEDURE* GetBaseReleaseSecCfg*(VAR cfg: ReleaseSecCfg);
  BEGIN
    CLEAR(cfg)
  END GetBaseReleaseSecCfg;


  PROCEDURE* ReleaseSec*(cfg: ReleaseSecCfg);
    VAR val: INTEGER; currentVal: SET;
  BEGIN
    val := 0;
    BFI(val, CFG.PWR_SEC_APC, cfg.pullCfg);
    BFI(val, CFG.PWR_SEC_VB, cfg.bkupDom);
    BFI(val, CFG.PWR_SEC_VDM, cfg.voltDet);
    BFI(val, CFG.PWR_SEC_LPM, cfg.lpMode);
    SYSTEM.GET(CFG.PWR_SEC, currentVal);
    currentVal := (currentVal * (-BITS(val))) * (-cfg.wakeUp);
    SYSTEM.PUT(CFG.PWR_SEC, currentVal)
  END ReleaseSec;


  PROCEDURE init;
  BEGIN
    RST.EnableBusClock(CFG.PWR_BC_reg, CFG.PWR_BC_pos)
  END init;

BEGIN
  init
END PWR.
