MODULE Watchdog;
(**
  Oberon RTK Framework
  Watchdog controller
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Counting tick is set and initialised in module Clocks to 1 MHz.
  Note the necessary factor of 2 for the time.
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
  --
  Reset behaviour, as read from code.
  Hardware reset:
  * WATCHDOG_CTRL = 07000000H
    * TRIGGER = 0
    * ENABLE = 0
    * PAUSE_DBG1 = 1
    * PAUSE_DBG0 = 1
    * PAUSE_JTAG = 1
    * TIME = 0
  * RESETS_WDSEL = 0H
  * PSM_WDSEL = 0H
  But, out of reset after USB device mode:
  * WATCHDOG_CTRL = 400F4240H
    * TRIGGER = 0
    * ENABLE = 1
    * PAUSE_DBG1 = 0
    * PAUSE_DBG0 = 0
    * PAUSE_JTAG = 0
    * TIME = 0F4240H = 1,000,000, ie. 500 ms with a 1 MHz timer tick
  * RESETS_WDSEL = 0H
  * PSM_WDSEL = 0001FFFCH, ie. all set but ROSC and XOSC
    With bit PSM_RESETS in PSM_WDSEL set, all devices as per RESETS_WDSEL
    are also reset, even with RESETS_WDSEL = 0H

  So out of USB-reset, the watchdog is enabled, but does not fire. However,
  as soon as a time is loaded into WATCHDOG_LOAD, the watchdog triggers. If
  zero is written to WATCHDOG_LOAD, the watchdog does not fire. Hence it can
  be concluded that WATCHDOG_LOAD contains zero out of USB-reset, and consequently
  does not fire, evne though it's enabled (WATCHDOG_LOAD is write-only).

  The above values suggest that the watchdog is used to supervise the
  processor-controlled boot sequence, and then disabled by writing zero
  to WATCHDOG_LOAD in lieu of disabling it.

  Hence, before any use of the watchdog in a program, it must be disabled,
  in order to cover the USB-reset case.

  Out of hw-reset, the watchdog is disabled via the corresponding bit in
  WATCHDOG_CTRL, see above.
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    ScratchMagic4* = 0B007C0D3H;
    ScratchMagic3* = 04FF83F2DH;

    (* reset reasons *)
    HardwareReset* = 0;
    WatchdogTimed* = 1;
    WatchdogForced* = 2;


    CTRL_TRIGGER = 31;
    CTRL_ENABLE = 30;
    CTRL_PAUSE_DBG1 = 26;
    CTRL_PAUSE_DBG0 = 25;
    CTRL_PAUSE_JTAG = 24;

    CTRL_RESET = {CTRL_TRIGGER, CTRL_ENABLE, CTRL_PAUSE_DBG1, CTRL_PAUSE_DBG0, CTRL_PAUSE_JTAG};

    ScratchRegs = {0..7};

  VAR load: INTEGER;


  PROCEDURE Init*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ACLR, CTRL_RESET);
    SYSTEM.PUT(MCU.PSM_WDSEL, 0);
    SYSTEM.PUT(MCU.RESETS_WDSEL, 0)
  END Init;


  PROCEDURE Enable*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ASET, {CTRL_ENABLE})
  END Enable;


  PROCEDURE Disable*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ACLR, {CTRL_ENABLE})
  END Disable;


  PROCEDURE SetTime*(time: INTEGER); (* milliseconds *)
  BEGIN
    load := 2 * time * 1000;
    SYSTEM.PUT(MCU.WATCHDOG_LOAD, load)
  END SetTime;


  PROCEDURE Reload*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_LOAD, load)
  END Reload;


  PROCEDURE Trigger*;
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_CTRL + MCU.ASET, {CTRL_TRIGGER})
  END Trigger;


  PROCEDURE GetResetReason*(VAR reason: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.WATCHDOG_REASON, reason)
  END GetResetReason;


  PROCEDURE SetPowerOnResets*(resets: SET);
  BEGIN
    SYSTEM.PUT(MCU.PSM_WDSEL, resets)
  END SetPowerOnResets;


  PROCEDURE SetResetResets*(resets: SET);
  BEGIN
    SYSTEM.PUT(MCU.RESETS_WDSEL, resets)
  END SetResetResets;


  PROCEDURE SetScratchReg*(regNo, value: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(regNo IN ScratchRegs);
    addr := MCU.WATCHDOG_SCRATCH + (regNo * MCU.WATCHDOG_SCRATCH_Offset);
    SYSTEM.PUT(addr, value)
  END SetScratchReg;

END Watchdog.
