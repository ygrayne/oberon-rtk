MODULE TIMERS_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  TIMER
  datasheet 12.8.5, p1173
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, ACCESSCTRL_SYS;

  CONST
    A0* = 0;
    A1* = 1;
    A2* = 2;
    A3* = 3;
    T0* = 0;
    T1* = 1;
    TIMER0* = 0;
    TIMER1* = 1;

    Alarms_all* = {0 .. 3};
    Timers_all* = {0, 1};
    NumTimers* = 2;
    NumAlarms* = 4;


    TIMER0_BASE* = BASE.TIMER0_BASE;
    TIMER1_BASE* = BASE.TIMER1_BASE;

    TIMER_Offset*           = TIMER1_BASE - TIMER0_BASE;
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
    TIMER_LOCKED_Offset*    = 034H;
    TIMER_SOURCE_Offset*    = 038H;
    TIMER_INTR_Offset*      = 03CH;
    TIMER_INTE_Offset*      = 040H;
    TIMER_INTF_Offset*      = 044H;
    TIMER_INTS_Offset*      = 048H;

    (* resets *)
    TIMER_RST_reg* = RESETS_SYS.RESETS_RESET;
    TIMER0_RST_pos* = RESETS_SYS.RESETS_TIMER0;
    TIMER1_RST_pos* = RESETS_SYS.RESETS_TIMER1;

    (* secure *)
    TIMER0_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_TIMER0;
    TIMER1_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_TIMER1;

END TIMERS_DEV.
