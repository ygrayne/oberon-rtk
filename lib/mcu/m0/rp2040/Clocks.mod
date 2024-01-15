MODULE Clocks;
(**
  Oberon RTK Framework
  Clocks:
  * initialisation at start-up (auto)
  * clock monitor on pin 21
  * clock-gating: enabling and disabling of specific clocks for power-savings
  * more to come: resus, freq counters
  Remark: maybe split the clock init from other functions, so these can
  only be loaded when needed.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  Datasheet: 2.15.7, p195
  --
  Current configuration:
  * clk_sys: 125 Mhz
  * clk_ref: 48 Mhz
  * clk_peri: 48 Mhz
  * clk_tick: 1 Mhz
  --
  Run 'python -m vcocalc -h' for PLL calculations.
  --
  Copyright (c) 2023 Gray gray@grayraven.org
**)

  IMPORT SYSTEM, MCU := MCU2, Resets, GPIO, PowerOn;

  CONST
    (* CLK_GPOUT0_CTRL *)
    PLLsys* = 00H; (* reset value *)
    PLLusb* = 03H;
    ROSC*   = 04H;
    XOSC*   = 05H;
    ClkSys* = 06H;
    ClkUSB* = 07H;
    ClkADC* = 08H;
    ClkRTC* = 09H;
    ClkRef* = 0AH;

    (* XOSC_CTRL[23:12] *)
    XOSC_CTRL_DISABLE* = 0D1EH;
    XOSC_CTRL_ENABLE*  = 0FABH;

    XOSC_STATUS_STABLE = 31;

    PLL_SYS_PWR_VCOPD = 5;
    PLL_SYS_PWR_POSTDIVPD = 3;
    PLL_SYS_PWR_PD = 0;

    PLL_USB_PWR_VCOPD = 5;
    PLL_USB_PWR_POSTDIVPD = 3;
    PLL_USB_PWR_PD = 0;

    PLL_SYS_CS_LOCK = 31;
    PLL_USB_CS_LOCK = 31;

    CLK_GPOUT0_CTRL_ENABLE = 11;
    CLK_PERI_CTRL_ENABLE = 11;


  (* clk signal external monitoring *)
  (* oscilloscopes rock! *)

  PROCEDURE Monitor*(which: INTEGER);
  (* on pin 21 using CLOCK GPOUT0 *)
    CONST Pin = 21;
    VAR x: INTEGER;
  BEGIN
    (* set up clock GPOUT0 *)
    x := 0;
    BFI(x, 8, 5, which);
    SYSTEM.PUT(MCU.CLK_GPOUT0_CTRL, x);
    SYSTEM.PUT(MCU.CLK_GPOUT0_CTRL + MCU.ASET, {CLK_GPOUT0_CTRL_ENABLE});
    GPIO.SetFunction(Pin, GPIO.Fclk)
  END Monitor;


  (* clock gating *)
  (* note: all clocks are enabled upon reset *)

  PROCEDURE EnableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_WAKE_EN0 + MCU.ASET, en0);
    SYSTEM.PUT(MCU.CLK_WAKE_EN1 + MCU.ASET, en1)
  END EnableClockWake;

  PROCEDURE DisableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_WAKE_EN0 + MCU.ACLR, en0);
    SYSTEM.PUT(MCU.CLK_WAKE_EN1 + MCU.ACLR, en1)
  END DisableClockWake;

  PROCEDURE EnableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_SLEEP_EN0 + MCU.ASET, en0);
    SYSTEM.PUT(MCU.CLK_SLEEP_EN1 + MCU.ASET, en1)
  END EnableClockSleep;

  PROCEDURE DisableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_SLEEP_EN0 + MCU.ACLR, en0);
    SYSTEM.PUT(MCU.CLK_SLEEP_EN1 + MCU.ACLR, en1)
  END DisableClockSleep;

  PROCEDURE GetEnabled*(VAR en0, en1: SET);
  BEGIN
    SYSTEM.GET(MCU.CLK_ENABLED0, en0);
    SYSTEM.GET(MCU.CLK_ENABLED1, en1)
  END GetEnabled;

  (* start-up *)

  PROCEDURE startXOSC;
    VAR x: INTEGER;
  BEGIN
    (* ensure register accessibility *)
    PowerOn.AwaitResetDone(MCU.PSM_XOSC);
    (* set start-up delay *)
    SYSTEM.PUT(MCU.XOSC_STARTUP, 94); (* about 2 ms *)
    (* enable *)
    SYSTEM.GET(MCU.XOSC_CTRL, x);
    BFI(x, 23, 12, XOSC_CTRL_ENABLE);
    SYSTEM.PUT(MCU.XOSC_CTRL, x);
    (* wait for osc to stabilize *)
    (* compiler issue, reported => confirmed
    REPEAT UNTIL SYSTEM.BIT(MCU.XOSC_STATUS, STABLE);
    *)
    REPEAT (* workaround *)
      SYSTEM.GET(MCU.XOSC_STATUS, x)
    UNTIL XOSC_STATUS_STABLE IN BITS(x)
  END startXOSC;


  PROCEDURE startSysPLL;
  (* at 48 MHz *)
    VAR x: INTEGER;
  BEGIN
    Resets.Release(MCU.RESETS_PLL_SYS);
    Resets.AwaitReleaseDone(MCU.RESETS_PLL_SYS);
    (* set freq 125 MHz *)
    SYSTEM.PUT(MCU.PLL_SYS_FBDIV_INT, 125);
    (* power up VCO and PLL *)
    SYSTEM.PUT(MCU.PLL_SYS_PWR + MCU.ACLR, {PLL_SYS_PWR_VCOPD, PLL_SYS_PWR_PD}); (* clear bits *)
    (* compiler issue, reported => confirmed
    REPEAT UNTIL SYSTEM.BIT(MCU.PLL_SYS_CS, LOCK);
    *)
    REPEAT (* workaround *)
      SYSTEM.GET(MCU.PLL_SYS_CS, x)
    UNTIL PLL_SYS_CS_LOCK IN BITS(x);
    (* set post dividers *)
    (* 125 Mhz, note: high VCO freq *)
    x := 0;
    BFI(x, 18, 16, 6);
    BFI(x, 14, 12, 2);
    SYSTEM.PUT(MCU.PLL_SYS_PRIM, x);
    (* power up post dividers *)
    SYSTEM.PUT(MCU.PLL_SYS_PWR + MCU.ACLR, {PLL_SYS_PWR_POSTDIVPD})
  END startSysPLL;


  PROCEDURE startUsbPLL;
  (* 48 MHz *)
  (* required for peripheral clock *)
  (* if we want to keep it independent of the system clock *)
  (* we'll also feed the reference clock with this PLL *)
    VAR x: INTEGER;
  BEGIN
    Resets.Release(MCU.RESETS_PLL_USB);
    Resets.AwaitReleaseDone(MCU.RESETS_PLL_USB);
    (* set freq 48 MHz *)
    SYSTEM.PUT(MCU.PLL_USB_FBDIV_INT, 64);
    (* power up VCO and PLL *)
    SYSTEM.PUT(MCU.PLL_USB_PWR + MCU.ACLR, {PLL_USB_PWR_VCOPD, PLL_USB_PWR_PD}); (* clear bits *)
    (* compiler issue, reported
    REPEAT UNTIL SYSTEM.BIT(MCU.PLL_USB_CS, LOCK);
    *)
    REPEAT (* workaround *)
      SYSTEM.GET(MCU.PLL_USB_CS, x)
    UNTIL PLL_USB_CS_LOCK IN BITS(x);
    (* set post dividers *)
    x := 0;
    BFI(x, 18, 16, 4);
    BFI(x, 14, 12, 4);
    SYSTEM.PUT(MCU.PLL_USB_PRIM, x);
    (* power up post dividers *)
    SYSTEM.PUT(MCU.PLL_USB_PWR + MCU.ACLR, {PLL_USB_PWR_POSTDIVPD})
  END startUsbPLL;


  PROCEDURE connectClocks;
    VAR x: INTEGER;
  BEGIN
    (* system clock *)
    (* reset status: clk_sys AUXSRC set to pll_sys *)
    (* switch clk_sys SRC to aux *)
    SYSTEM.PUT(MCU.CLK_SYS_CTRL + MCU.ASET, {0});
    REPEAT UNTIL SYSTEM.BIT(MCU.CLK_SYS_SELECTED, 1);

    (* reference clock *)
    (* reset status: clk_ref AUXSRC set to pll_usb *)
    (* switch clk_ref AUXSRC to pll_usb *)
    (* switch clk_ref SRC to aux *)
    SYSTEM.PUT(MCU.CLK_REF_CTRL + MCU.ASET, {0});
    REPEAT UNTIL SYSTEM.BIT(MCU.CLK_REF_SELECTED, 1);

    (* peripheral clock *)
    (* reset status: clk_peri AUXSRC set to clk_sys *)
    (* connect clk_peri AUXSRC to pll_usb *)
    x := 0;
    BFI(x, 7, 5, 2);
    SYSTEM.PUT(MCU.CLK_PERI_CTRL, x);
    (* enable clk_peri *)
    SYSTEM.PUT(MCU.CLK_PERI_CTRL + MCU.ASET, {CLK_PERI_CTRL_ENABLE})
  END connectClocks;


  PROCEDURE startTickClock;
  (* 1 MHz, used for sys tick, timer, watchdog *)
  (* derived from clk_ref => divider = 48 *)
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_TICK, 48);
    SYSTEM.PUT(MCU.WATCHDOG_TICK + MCU.ASET, {MCU.WATCHDOG_TICK_EN})
  END startTickClock;


  PROCEDURE init;
  BEGIN
    startXOSC;
    startSysPLL;
    startUsbPLL;
    connectClocks;
    startTickClock
  END init;

BEGIN
  init
END Clocks.
