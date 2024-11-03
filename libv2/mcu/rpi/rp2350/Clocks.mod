MODULE Clocks;
(**
  Oberon RTK Framework
  --
  Clocks:
  * initialisation at start-up (auto)
  * clock monitor on pin 21
  * clock-gating: enabling and disabling of specific clocks for power-savings
  Remark: maybe split the clock init from other functions, so these can
  only be loaded when needed.
  --
  MCU: RP2350
  --
  Current configuration:
  * clk_sys: 125 Mhz
  * clk_ref: 12 Mhz
  * clk_peri: 48 Mhz
  * clk_tick: 1 Mhz
  --
  Run 'python -m vcocalc -h' for PLL calculations.
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, GPIO, StartUp;

  CONST
    (* CLK_GPOUT0_CTRL *)
    CLK_GPOUT0_CTRL_ENABLE    = 11;
    CLK_GPOUT0_CTRL_AUXSRC_1  = 8;
    CLK_GPOUT0_CTRL_AUXSRC_0  = 5;
      GPOUT_PLLsys*   = 00H; (* reset value *)
      GPOUT_PLLusb*   = 03H;
      GPOUT_ROSC*     = 05H;
      GPOUT_XOSC*     = 06H;
      GPOUT_LPO*      = 07H;
      GPOUT_ClkSys*   = 08H;
      GPOUT_ClkUSB*   = 09H;
      GPOUT_ClkADC*   = 0AH;
      GPOUT_ClkRef*   = 0BH;
      GPOUT_ClkPeri*  = 0CH;
      GPOUT_ClkHSTX*  = 0DH;

    (* XOSC_CTRL bits & values *)
    XOSC_CTRL_ENABLE_1     = 23;
    XOSC_CTRL_ENABLE_0     = 12;
      XOSC_Disable = 0D1EH;
      XOSC_Enable  = 0FABH;
    XOSC_CTRL_FREQ_RANGE_1 = 11;
    XOSC_CTRL_FREQ_RANGE_0 = 0;
      FREQ_RANGE_val_15 = 0AA0H;
      FREQ_RANGE_val_30 = 0AA1H;
      FREQ_RANGE_val_60 = 0AA2H;
      FREQ_RANGE_val_100 = 0AA3H;

    (* XOSC_STATUS bits *)
    XOSC_STATUS_STABLE = 31;

    (* PLL_SYS_CS bits *)
    PLL_SYS_CS_LOCK = 31;

    (* PLL_SYS_PWR bits *)
    PLL_SYS_PWR_VCOPD = 5;
    PLL_SYS_PWR_POSTDIVPD = 3;
    PLL_SYS_PWR_PD = 0;

    (* PLL_SYS_PRIM bits *)
    PLL_SYS_PRIM_POSTDIV1_1  = 18;
    PLL_SYS_PRIM_POSTDIV1_0  = 16;
    PLL_SYS_PRIM_POSTDIV2_1  = 14;
    PLL_SYS_PRIM_POSTDIV2_0  = 12;

    (* PLL_USB_CS bits *)
    PLL_USB_CS_LOCK = 31;

    (* PLL_USB_PWR bits *)
    PLL_USB_PWR_VCOPD = 5;
    PLL_USB_PWR_POSTDIVPD = 3;
    PLL_USB_PWR_PD = 0;

    (* PLL_USB_PRIM bits *)
    PLL_USB_PRIM_POSTDIV1_1  = 18;
    PLL_USB_PRIM_POSTDIV1_0  = 16;
    PLL_USB_PRIM_POSTDIV2_1  = 14;
    PLL_USB_PRIM_POSTDIV2_0  = 12;

    (* CLK_PERI_CTRL bits *)
    CLK_PERI_CTRL_ENABLED   = 28;
    CLK_PERI_CTRL_ENABLE    = 11;
    CLK_PERI_CTRL_AUXSRC_1  = 7;
    CLK_PERI_CTRL_AUXSRC_0  = 5;
      PERI_AUXSRC_PLL_USB = 02H;

    (* CLK_REF_DIV bits *)
    CLK_REF_DIV_INT_1 = 23;
    CLK_REF_DIV_INT_0 = 16;

    (* TICKS_CTRL bits *)
    TICKS_CTRL_EN = 0;


  (* clk signal external monitoring *)
  (* oscilloscopes rock! *)

  PROCEDURE Monitor*(which: INTEGER);
  (* on pin 21 using CLOCK GPOUT0 *)
    CONST Pin = 21;
    VAR x: INTEGER;
  BEGIN
    (* set up clock GPOUT0 *)
    x := 0;
    BFI(x, CLK_GPOUT0_CTRL_AUXSRC_1, CLK_GPOUT0_CTRL_AUXSRC_0, which);
    SYSTEM.PUT(MCU.CLK_GPOUT0_CTRL, x);
    SYSTEM.PUT(MCU.CLK_GPOUT0_CTRL + MCU.ASET, {CLK_GPOUT0_CTRL_ENABLE});
    GPIO.SetFunction(Pin, MCU.IO_BANK0_Fclk);
    GPIO.DisableIsolation(Pin)
  END Monitor;


  (* clock gating *)
  (* note: all clocks are enabled upon reset *)

  PROCEDURE* EnableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_WAKE_EN0 + MCU.ASET, en0);
    SYSTEM.PUT(MCU.CLK_WAKE_EN1 + MCU.ASET, en1)
  END EnableClockWake;

  PROCEDURE* DisableClockWake*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_WAKE_EN0 + MCU.ACLR, en0);
    SYSTEM.PUT(MCU.CLK_WAKE_EN1 + MCU.ACLR, en1)
  END DisableClockWake;

  PROCEDURE* EnableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_SLEEP_EN0 + MCU.ASET, en0);
    SYSTEM.PUT(MCU.CLK_SLEEP_EN1 + MCU.ASET, en1)
  END EnableClockSleep;

  PROCEDURE* DisableClockSleep*(en0, en1: SET);
  BEGIN
    SYSTEM.PUT(MCU.CLK_SLEEP_EN0 + MCU.ACLR, en0);
    SYSTEM.PUT(MCU.CLK_SLEEP_EN1 + MCU.ACLR, en1)
  END DisableClockSleep;

  PROCEDURE* GetEnabled*(VAR en0, en1: SET);
  BEGIN
    SYSTEM.GET(MCU.CLK_ENABLED0, en0);
    SYSTEM.GET(MCU.CLK_ENABLED1, en1)
  END GetEnabled;

  (* start-up *)

  PROCEDURE startXOSC;
    VAR x: INTEGER;
  BEGIN
    (* ensure register accessibility *)
    StartUp.AwaitPowerOnResetDone(MCU.PSM_XOSC);
    (* set start-up delay *)
    SYSTEM.PUT(MCU.XOSC_STARTUP, 94); (* about 2 ms *)
    (* enable *)
    SYSTEM.GET(MCU.XOSC_CTRL, x);
    BFI(x, XOSC_CTRL_FREQ_RANGE_1, XOSC_CTRL_FREQ_RANGE_0, FREQ_RANGE_val_15);
    BFI(x, XOSC_CTRL_ENABLE_1, XOSC_CTRL_ENABLE_0, XOSC_Enable);
    SYSTEM.PUT(MCU.XOSC_CTRL, x);
    (* wait for osc to stabilize *)
    REPEAT UNTIL SYSTEM.BIT(MCU.XOSC_STATUS, XOSC_STATUS_STABLE)
  END startXOSC;


  PROCEDURE startSysPLL;
  (* 125 MHz *)
    VAR x: INTEGER;
  BEGIN
    StartUp.ReleaseReset(MCU.RESETS_PLL_SYS);
    (* set freq 125 MHz *)
    SYSTEM.PUT(MCU.PLL_SYS_FBDIV_INT, 125);
    (* power up VCO and PLL (note: clear bits) *)
    SYSTEM.PUT(MCU.PLL_SYS_PWR + MCU.ACLR, {PLL_SYS_PWR_VCOPD, PLL_SYS_PWR_PD});
    REPEAT UNTIL SYSTEM.BIT(MCU.PLL_SYS_CS, PLL_SYS_CS_LOCK);
    (* set post dividers *)
    (* 125 Mhz, note: high VCO freq *)
    x := 0;
    BFI(x, PLL_SYS_PRIM_POSTDIV1_1, PLL_SYS_PRIM_POSTDIV1_0, 6);
    BFI(x, PLL_SYS_PRIM_POSTDIV2_1, PLL_SYS_PRIM_POSTDIV2_0, 2);
    SYSTEM.PUT(MCU.PLL_SYS_PRIM, x);
    (* power up post dividers (note: clear bits) *)
    SYSTEM.PUT(MCU.PLL_SYS_PWR + MCU.ACLR, {PLL_SYS_PWR_POSTDIVPD})
  END startSysPLL;


  PROCEDURE startUsbPLL;
  (* 48 MHz *)
  (* required for peripheral clock *)
  (* if we want to keep it independent of the system clock *)
  (* we'll also feed the reference clock with this PLL *)
    VAR x: INTEGER;
  BEGIN
    StartUp.ReleaseReset(MCU.RESETS_PLL_USB);
    (* set freq 48 MHz *)
    SYSTEM.PUT(MCU.PLL_USB_FBDIV_INT, 64);
    (* power up VCO and PLL (note: clear bits) *)
    SYSTEM.PUT(MCU.PLL_USB_PWR + MCU.ACLR, {PLL_USB_PWR_VCOPD, PLL_USB_PWR_PD});
    REPEAT UNTIL SYSTEM.BIT(MCU.PLL_USB_CS, PLL_USB_CS_LOCK);
    (* set post dividers *)
    x := 0;
    BFI(x, PLL_USB_PRIM_POSTDIV1_1, PLL_USB_PRIM_POSTDIV1_0, 4);
    BFI(x, PLL_USB_PRIM_POSTDIV2_1, PLL_USB_PRIM_POSTDIV2_0, 4);
    SYSTEM.PUT(MCU.PLL_USB_PRIM, x);
    (* power up post dividers (note: clear bits) *)
    SYSTEM.PUT(MCU.PLL_USB_PWR + MCU.ACLR, {PLL_USB_PWR_POSTDIVPD})
  END startUsbPLL;


  PROCEDURE* connectClocks;
    VAR x: INTEGER;
  BEGIN
    (* system clock, always enabled *)
    (* reset status: clk_sys AUXSRC set to pll_sys *)
    (* switch clk_sys SRC to aux *)
    SYSTEM.PUT(MCU.CLK_SYS_CTRL + MCU.ASET, {0});
    REPEAT UNTIL SYSTEM.BIT(MCU.CLK_SYS_SELECTED, 1);

    (* reference clock, always enabled *)
    (* from pll_usb = 48 MHz, divide by 4 (max clk_ref = 25 MHz for RP2350) *)
    x := 0;
    BFI(x, CLK_REF_DIV_INT_1, CLK_REF_DIV_INT_0, 4);
    SYSTEM.PUT(MCU.CLK_REF_DIV, x);
    (* reset status: clk_ref AUXSRC set to pll_usb *)
    (* switch clk_ref SRC to aux *)
    SYSTEM.PUT(MCU.CLK_REF_CTRL + MCU.ASET, {0});
    REPEAT UNTIL SYSTEM.BIT(MCU.CLK_REF_SELECTED, 1);

    (* peripheral clock *)
    (* reset status: clk_peri AUXSRC set to clk_sys *)
    (* connect clk_peri AUXSRC to pll_usb *)
    x := 0;
    BFI(x, CLK_PERI_CTRL_AUXSRC_1, CLK_PERI_CTRL_AUXSRC_0, PERI_AUXSRC_PLL_USB);
    SYSTEM.PUT(MCU.CLK_PERI_CTRL, x);
    (* enable clk_peri *)
    SYSTEM.PUT(MCU.CLK_PERI_CTRL + MCU.ASET, {CLK_PERI_CTRL_ENABLE})
  END connectClocks;


  PROCEDURE* startTicks;
  (* 1 MHz, used for sys tick, timer, watchdog *)
  (* derived from clk_ref => divider = 12 *)
  CONST Divider = 12;
  BEGIN
    SYSTEM.PUT(MCU.TICKS_PROC0_CYCLES, Divider);
    SYSTEM.PUT(MCU.TICKS_PROC1_CYCLES, Divider);
    SYSTEM.PUT(MCU.TICKS_TIMER0_CYCLES, Divider);
    SYSTEM.PUT(MCU.TICKS_TIMER1_CYCLES, Divider);
    SYSTEM.PUT(MCU.TICKS_WATCHDOG_CYCLES, Divider);
    SYSTEM.PUT(MCU.TICKS_PROC0_CTRL + MCU.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(MCU.TICKS_PROC1_CTRL + MCU.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(MCU.TICKS_TIMER0_CTRL + MCU.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(MCU.TICKS_TIMER1_CTRL + MCU.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(MCU.TICKS_WATCHDOG_CTRL + MCU.ASET, {TICKS_CTRL_EN})
  END startTicks;

  PROCEDURE init;
  BEGIN
    startXOSC;
    startSysPLL;
    startUsbPLL;
    connectClocks;
    startTicks
  END init;

BEGIN
  init
END Clocks.
