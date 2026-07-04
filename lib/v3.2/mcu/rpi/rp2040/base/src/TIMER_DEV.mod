MODULE TIMER_DEV;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  TIMER
  datasheet 4.6.5, p541
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

    IMPORT BASE, RESETS_SYS;

  CONST
    A0* = 0;
    A1* = 1;
    A2* = 2;
    A3* = 3;
    T0* = 0;
    TIMER0* = 0;

    Alarms_all* = {0 .. 3};
    Timers_all* = {0};
    NumTimers* = 1;
    NumAlarms* = 4;

    TIMER0_BASE* = BASE.TIMER0_BASE;

    TIMER_Offset*           = 0; (* for RP2350 code compatibility *)
    TIMER_TIMEHW_Offset*    = 000H;
    TIMER_TIMELW_Offset*    = 004H;
    TIMER_TIMEHR_Offset*    = 008H;
    TIMER_TIMELR_Offset*    = 00CH;
    TIMER_ALARM0_Offset*    = 010H;
    TIMER_ALARM1_Offset*    = 014H;
    TIMER_ALARM2_Offset*    = 018H;
    TIMER_ALARM3_Offset*    = 01CH;
    TIMER_ARMED_Offset*     = 020H;
    TIMER_TIMERAWH_Offset*  = 024H;
    TIMER_TIMERAWL_Offset*  = 028H;
    TIMER_DBGPAUSE_Offset*  = 02CH;
    TIMER_PAUSE_Offset*     = 030H;
    TIMER_INTR_Offset*      = 034H;
    TIMER_INTE_Offset*      = 038H;
    TIMER_INTF_Offset*      = 03CH;
    TIMER_INTS_Offset*      = 040H;

    (* resets *)
    TIMER_RST_reg* = RESETS_SYS.RESETS_RESET;
    TIMER0_RST_pos* = RESETS_SYS.RESETS_TIMER0;


END TIMER_DEV.
