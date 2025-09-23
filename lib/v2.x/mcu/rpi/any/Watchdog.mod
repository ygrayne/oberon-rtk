MODULE Watchdog;
(**
  Oberon RTK Framework
  --
  Watchdog controller
  --
  MCU: RP2040, RP2350
  --
  Counting tick is set and initialised in module Clocks to 1 MHz.
  Note the necessary correction factor of 2 for the RP2040.
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
  --
  Reset behaviour, as read from code.

  Hardware reset:
  RP2040:                             RP2350:
  * WATCHDOG_CTRL   = 07000000H       = 07000000H
    * TRIGGER       = 0               = 0
    * ENABLE        = 0               = 0
    * PAUSE_DBG1    = 1               = 1
    * PAUSE_DBG0    = 1               = 1
    * PAUSE_JTAG    = 1               = 1
    * TIME          = 0               = 0
  * PSM_WDSEL       = 0H              = 0H
  * RESETS_WDSEL    = 0H              = 0H
  * WATCHDOG_REASON = 0H              = 0H

  But, out of reset after USB device mode:
  RP2040:                                       RP2350:
  * WATCHDOG_CTRL   = 400F4240H                 = 40000000H
    * TRIGGER       = 0                         = 0
    * ENABLE        = 1                         = 1
    * PAUSE_DBG1    = 0                         = 0
    * PAUSE_DBG0    = 0                         = 0
    * PAUSE_JTAG    = 0                         = 0
    * TIME          = 0F4240H = 1,000,000 [1]   = 0H
  * PSM_WDSEL       = 0001FFFCH [2]             = 1FFFFFFEH [3]
  * RESETS_WDSEL    = 0H                        = 0H
  * WATCHDOG_REASON = 1H (timer)                = 1H


  [1] ie. 500 ms with a 1 MHz timer tick
  [2] ie. all set but PSM_ROSC and PSM_XOSC. With bit PSM_RESETS in PSM_WDSEL set,
      all devices as per RESETS_WDSEL are also reset, even with RESETS_WDSEL = 0H
  [3] ie. all set but PSM_COLD

  So out of USB-reset, the watchdog is enabled, but does not fire. However,
  as soon as a time is loaded into WATCHDOG_LOAD, the watchdog triggers. If
  zero is written to WATCHDOG_LOAD, the watchdog does not fire. Hence it can
  be concluded that WATCHDOG_LOAD contains zero out of USB-reset, and consequently
  does not fire, even though it's enabled (WATCHDOG_LOAD is write-only).

  Proc 'init' initialises the watchdog to a common state for all resets.
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* WATCHDOG_CTRL bits *)
    CTRL_TRIGGER    = 31;
    CTRL_ENABLE     = 30;
    CTRL_PAUSE_DBG1 = 26;
    CTRL_PAUSE_DBG0 = 25;
    CTRL_PAUSE_JTAG = 24;
    CTRL_TIME_1     = 23;
    CTRL_TIME_0     = 0;

    (* WATCHDOG_REASON bits *)
    REASON_FORCE* = 1;
    REASON_TIMER* = 0;

    (* reset value = clear all *)
    CTRL_RESET = {CTRL_TRIGGER, CTRL_ENABLE, CTRL_PAUSE_DBG1, CTRL_PAUSE_DBG0, CTRL_PAUSE_JTAG};

    ScratchRegs = {0..7};

  VAR load: INTEGER;


  PROCEDURE* Enable*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ASET, {CTRL_ENABLE})
  END Enable;


  PROCEDURE* Disable*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ACLR, {CTRL_ENABLE})
  END Disable;


  PROCEDURE* SetLoadTime*(time: INTEGER); (* milliseconds *)
    CONST MaxLoad = 0FFFFFFH;
  BEGIN
    load := MCU.WATCHDOG_XLOADTIME * time * 1000;
    IF load > MaxLoad THEN load := MaxLoad END;
    SYSTEM.PUT(MCU.WATCHDOG_LOAD, load)
  END SetLoadTime;


  PROCEDURE* GetTime*(VAR time: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.WATCHDOG_CTRL, time);
    time := BFX(time, CTRL_TIME_1, CTRL_TIME_0)
  END GetTime;


  PROCEDURE* Reload*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_LOAD, load)
  END Reload;


  PROCEDURE* Trigger*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ASET, {CTRL_TRIGGER})
  END Trigger;


  PROCEDURE* GetResetReason*(VAR reason: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.WATCHDOG_REASON, reason)
  END GetResetReason;


  PROCEDURE* SetScratchReg*(regNo, value: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(regNo IN ScratchRegs);
    addr := MCU.WATCHDOG_SCRATCH0 + (regNo * MCU.WATCHDOG_SCRATCH_Offset);
    SYSTEM.PUT(addr, value)
  END SetScratchReg;


  PROCEDURE* GetScratchReg*(regNo: INTEGER; VAR value: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(regNo IN ScratchRegs);
    addr := MCU.WATCHDOG_SCRATCH0 + (regNo * MCU.WATCHDOG_SCRATCH_Offset);
    SYSTEM.GET(addr, value)
  END GetScratchReg;


  PROCEDURE init;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ACLR, CTRL_RESET);
    SYSTEM.PUT(MCU.PSM_WDSEL, 0);
    SYSTEM.PUT(MCU.RESETS_WDSEL, 0)
  END init;

BEGIN
  init
END Watchdog.
