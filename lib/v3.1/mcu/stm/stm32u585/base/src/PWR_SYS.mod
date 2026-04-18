MODULE PWR_SYS;
(**
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RCC_SYS;

  CONST
    PWR_BASE* = BASE.PWR_BASE;

    PWR_CR1*      = PWR_BASE + 000H;
    PWR_CR2*      = PWR_BASE + 004H;
    PWR_CR3*      = PWR_BASE + 008H;
    PWR_VOSR*     = PWR_BASE + 00CH;
    PWR_SVMCR*    = PWR_BASE + 010H;
    PWR_WUCR1*    = PWR_BASE + 014H;
    PWR_WUCR2*    = PWR_BASE + 018H;
    PWR_WUCR3*    = PWR_BASE + 01CH;
    PWR_BDCR1*    = PWR_BASE + 020H;
    PWR_BDCR2*    = PWR_BASE + 024H;
    PWR_DBPR*     = PWR_BASE + 028H;
    PWR_UCPDR*    = PWR_BASE + 02CH;
    PWR_SECCFGR*  = PWR_BASE + 030H;
    PWR_PRIVCFGR* = PWR_BASE + 034H;
    PWR_SR*       = PWR_BASE + 038H;
    PWR_SVMSR*    = PWR_BASE + 03CH;
    PWR_BDSR*     = PWR_BASE + 040H;
    PWR_WUSR*     = PWR_BASE + 044H;
    PWR_WUSCR*    = PWR_BASE + 048H;
    PWR_APCR*     = PWR_BASE + 04CH;

    (* RCC: bus clock BC *)
    PWR_BC_reg* = RCC_SYS.RCC_AHB3ENR;
    PWR_BC_pos* = 2;

    (* Secure *)
    PWR_SEC* = PWR_SECCFGR;

    PWR_SEC_APC*  = 15;
    PWR_SEC_VB*   = 14;
    PWR_SEC_VDM*  = 13;
    PWR_SEC_LPM*  = 12;
    PWR_SEC_WUP8* = 7;
    PWR_SEC_WUP7* = 6;
    PWR_SEC_WUP6* = 5;
    PWR_SEC_WUP5* = 4;
    PWR_SEC_WUP4* = 3;
    PWR_SEC_WUP3* = 2;
    PWR_SEC_WUP2* = 1;
    PWR_SEC_WUP1* = 0;

    PWR_SEC_ALL* = {0 .. 7, 12 .. 15};

    (* own SECCFGR register *)
    (* module PWR should be equipped with more targeted procedures *)
    (* for the various control functions such as wake-up and pullup/down *)
    (* to note: the pin-oriented control registers auto-follow the GPIO_SECCFGR settings *)
    (* PWR.SetVoltageRange is S only if  RCC_SECCFGR.SYSCLKSEC = 1 *)

END PWR_SYS.
