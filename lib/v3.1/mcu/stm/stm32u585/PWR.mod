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
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := PWR_SYS, RST;

  CONST
    Range1* = 3;  (* 1.2 V, 160 MHz *)
    Range2* = 2;  (* 1.1 V, 110 MHz *)
    Range3* = 1;  (* 1.0 V, 55 MHz *)
    Range4* = 0;  (* 0.9 V, 25 MHz, reset *)

    KeepSecure* = 0;
    ReleaseSecure* = 1;

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
    SYSTEM.GET(SYS.PWR_VOSR, val);
    BFI(val, 17, 16, range);
    SYSTEM.PUT(SYS.PWR_VOSR, val);
    REPEAT UNTIL SYSTEM.BIT(SYS.PWR_VOSR, 15);
    SYSTEM.GET(SYS.PWR_VOSR, val);
    IF range > 1 THEN
      BFI(val, 18, 1);
      SYSTEM.PUT(SYS.PWR_VOSR, val);
      REPEAT UNTIL SYSTEM.BIT(SYS.PWR_VOSR, 14)
    ELSE
      BFI(val, 18, 0);
      SYSTEM.PUT(SYS.PWR_VOSR, val)
    END
  END SetVoltageRange;


  PROCEDURE* SecureAll*;
  BEGIN
    SYSTEM.PUT(SYS.PWR_SEC, SYS.PWR_SEC_ALL)
  END SecureAll;


  PROCEDURE* GetBaseReleaseSecCfg*(VAR cfg: ReleaseSecCfg);
  BEGIN
    CLEAR(cfg)
  END GetBaseReleaseSecCfg;


  PROCEDURE* ReleaseSec*(cfg: ReleaseSecCfg);
    VAR val: INTEGER; currentVal: SET;
  BEGIN
    val := 0;
    BFI(val, SYS.PWR_SEC_APC, cfg.pullCfg);
    BFI(val, SYS.PWR_SEC_VB, cfg.bkupDom);
    BFI(val, SYS.PWR_SEC_VDM, cfg.voltDet);
    BFI(val, SYS.PWR_SEC_LPM, cfg.lpMode);
    SYSTEM.GET(SYS.PWR_SEC, currentVal);
    currentVal := (currentVal * (-BITS(val))) * (-cfg.wakeUp);
    SYSTEM.PUT(SYS.PWR_SEC, currentVal)
  END ReleaseSec;


  PROCEDURE enable;
  BEGIN
    RST.EnableBusClock(SYS.PWR_BC_reg, SYS.PWR_BC_pos)
  END enable;

BEGIN
  enable
END PWR.
