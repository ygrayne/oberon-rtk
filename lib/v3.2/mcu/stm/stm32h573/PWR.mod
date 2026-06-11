MODULE PWR;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Power management
  Bus clock always on
  --
  Notes:
  - should/will be equipped with more targeted procedures for the various control
    functions such as wake-up
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := PWR_SYS;

  CONST
    Range0* = 3;  (* 1.30 - 1.40 V, 250 MHz *)
    Range1* = 2;  (* 1.15 - 1.26 V, 200 MHz *)
    Range2* = 1;  (* 1.05 - 1.15 V, 150 MHz *)
    Range3* = 0;  (* 0.95 - 1.05 V, 100 MHz, reset *)

    KeepSecure* = 0;
    ReleaseSecure* = 1;

  TYPE
    ReleaseSecCfg* = RECORD
      lpMode*: INTEGER;     (* LPMSEC bit 12: PWR_PMCR *)
      scm*: INTEGER;        (* SCMSEC bit 13: PWR_SCCR, PWR_VMCR *)
      bkupDom*: INTEGER;    (* VBSEC bit 14: PWR_BDCR, PWR_DBPCR *)
      vusb*: INTEGER;       (* VUSBSEC bit 15: PWR_USBSCR *)
      retention*: INTEGER;  (* RETSEC bit 11: PWR_IORETR *)
      wakeUp*: SET          (* WUP1SEC..WUP8SEC, bits 0..7 *)
    END;


  PROCEDURE* SetVoltageRange*(range: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(SYS.PWR_VOSCR, val);
    BFI(val, 5, 4, range);
    SYSTEM.PUT(SYS.PWR_VOSCR, val);
    REPEAT UNTIL SYSTEM.BIT(SYS.PWR_VOSSR, 13)
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
    BFI(val, SYS.PWR_SEC_VUSB, cfg.vusb);
    BFI(val, SYS.PWR_SEC_VB, cfg.bkupDom);
    BFI(val, SYS.PWR_SEC_SCM, cfg.scm);
    BFI(val, SYS.PWR_SEC_LPM, cfg.lpMode);
    BFI(val, SYS.PWR_SEC_RET, cfg.retention);
    SYSTEM.GET(SYS.PWR_SEC, currentVal);
    currentVal := (currentVal * (-BITS(val))) * (-cfg.wakeUp);
    SYSTEM.PUT(SYS.PWR_SEC, currentVal)
  END ReleaseSec;

END PWR.
