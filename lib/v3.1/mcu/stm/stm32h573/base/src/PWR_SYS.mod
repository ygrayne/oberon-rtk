MODULE PWR_SYS;
(**
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

   IMPORT BASE;

   CONST
      PWR_BASE* = BASE.PWR_BASE;

      PWR_PMCR*     = PWR_BASE + 0000H;
      PWR_PMSR*     = PWR_BASE + 0004H;
      PWR_VOSCR*    = PWR_BASE + 0010H;
      PWR_VOSSR*    = PWR_BASE + 0014H;
      PWR_BDCR*     = PWR_BASE + 0020H;
      PWR_DBPCR*    = PWR_BASE + 0024H;
      PWR_BDSR*     = PWR_BASE + 0028H;
      PWR_UCPDR*    = PWR_BASE + 002CH;
      PWR_SCCR*     = PWR_BASE + 0030H;
      PWR_VMCR*     = PWR_BASE + 0034H;
      PWR_USBSCR*   = PWR_BASE + 0038H;
      PWR_VMSR*     = PWR_BASE + 003CH;
      PWR_WUSCR*    = PWR_BASE + 0040H;
      PWR_WUSR*     = PWR_BASE + 0044H;
      PWR_WUCR*     = PWR_BASE + 0048H;
      PWR_IORETR*   = PWR_BASE + 0050H;
      PWR_SECCFGR*  = PWR_BASE + 0100H;
      PWR_PRIVCFGR* = PWR_BASE + 0104H;

      (* RCC: bus clock BC *)
      (* PWR is always on (SRD bus), no explicit clock enable *)

      (* Secure -- own SECCFGR register (TZ-aware) *)
      PWR_SEC* = PWR_SECCFGR;

      PWR_SEC_VUSB*    = 15;
      PWR_SEC_VB*      = 14;
      PWR_SEC_SCM*     = 13;
      PWR_SEC_LPM*     = 12;
      PWR_SEC_RET*     = 11;
      PWR_SEC_WUP8*    = 7;
      PWR_SEC_WUP7*    = 6;
      PWR_SEC_WUP6*    = 5;
      PWR_SEC_WUP5*    = 4;
      PWR_SEC_WUP4*    = 3;
      PWR_SEC_WUP3*    = 2;
      PWR_SEC_WUP2*    = 1;
      PWR_SEC_WUP1*    = 0;

      PWR_SEC_ALL* = {0 .. 7, 11 .. 15};

END PWR_SYS.
