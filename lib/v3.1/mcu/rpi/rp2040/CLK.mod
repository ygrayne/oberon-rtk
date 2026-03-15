MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Oscillator and clocks controller driver
  --
  Type: MCU
  --
  MCU: RP2040
  --
  Run 'python -m vcocalc -h' for PLL calculations.
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    PLLsys* = 0;
    PLLusb* = 1;

    (* XOSC_CTRL bits & values *)
    XOSC_Enable  = 0FABH;

    (* XOSC_STATUS bits *)
    XOSC_STATUS_STABLE = 31;

    (* PLL_SYS_CS, PLL_USB_CS bits *)
    CS_LOCK = 31;

    (* PLL_SYS_PWR bits *)
    PLL_PWR_VCOPD = 5;
    PLL_PWR_POSTDIVPD = 3;
    PLL_PWR_PD = 0;

    (* CLK_PERI_CTRL bits *)
    CLK_PERI_CTRL_ENABLE    = 11;

    (* WATCHDOG_TICK bits *)
    WATCHDOG_TICK_EN  = 9;

    RefAuxSrc_PLLusb* = 0;
    RefAuxSrc_GPIO0* = 1;
    RefAuxSrc_GPIO1* = 2;
    RefSrc_ROSC* = 0;
    RefSrc_AUX* = 1;
    RefSrc_XOSC* = 2;

    SysAuxSrc_PLLsys* = 0;
    SysAuxSrc_PLLusb* = 1;
    SysAuxSrc_ROSC* = 2;
    SysAuxSrc_XOSC* = 3;
    SysAuxSrc_GPIO0* = 4;
    SysAuxSrc_GPIO1* = 5;
    SysSrc_REF* = 0;
    SysSrc_AUX* = 1;

    PeriAuxSrc_SYS* = 0;
    PeriAuxSrc_PLLsys* = 1;
    PeriAuxSrc_PLLusb* = 2;
    PeriAuxSrc_ROSC* = 3;
    PeriAuxSrc_XOSC* = 4;
    PeriAuxSrc_GPIO0* = 5;
    PeriAuxSrc_GPIO1* = 6;


  TYPE
    PLLcfg* = RECORD
      refDiv*: INTEGER;
      fbDiv*: INTEGER;
      postDiv1*, postDiv2*: INTEGER
    END;

    ClocksCfg* = RECORD
      sysAuxSrc*, sysSrc*, sysDivInt*: INTEGER;
      refAuxSrc*, refSrc*, refDivInt*: INTEGER;
      periAuxSrc*: INTEGER
    END;

    TicksCfg* = RECORD
      watchdogDiv*: INTEGER
    END;


  PROCEDURE* StartXOSC*;
  (* 12 MHz *)
    VAR val: INTEGER;
  BEGIN
    (* ensure register accessibility, ie. PSM done *)
    REPEAT UNTIL SYSTEM.BIT(MCU.PSM_DONE, MCU.PSM_XOSC);
    (* set start-up delay *)
    SYSTEM.PUT(MCU.XOSC_STARTUP, 94); (* about 2 ms *)
    (* enable *)
    SYSTEM.GET(MCU.XOSC_CTRL, val);
    BFI(val, 23, 12, XOSC_Enable);
    SYSTEM.PUT(MCU.XOSC_CTRL, val);
    (* wait for osc to stabilize *)
    REPEAT UNTIL SYSTEM.BIT(MCU.XOSC_STATUS, XOSC_STATUS_STABLE)
  END StartXOSC;


  PROCEDURE* ConfigPLL*(pll: INTEGER; cfg: PLLcfg);
    VAR addr, val: INTEGER;
  BEGIN
    addr := MCU.PLL_SYS_BASE + (pll * MCU.PLL_Offset);
    (* set multiplier *)
    SYSTEM.PUT(addr + MCU.PLL_FBDIV_INT_Offset, cfg.fbDiv);
    (* power up VCO and PLL (note: clear bits) *)
    SYSTEM.PUT(addr + MCU.PLL_PWR_Offset + MCU.ACLR, {PLL_PWR_VCOPD, PLL_PWR_PD});
    SYSTEM.PUT(addr + MCU.PLL_CS_Offset, cfg.refDiv);
    REPEAT UNTIL SYSTEM.BIT(addr + MCU.PLL_CS_Offset, CS_LOCK);
    (* set post dividers *)
    val := 0;
    BFI(val, 18, 16, cfg.postDiv1);
    BFI(val, 14, 12, cfg.postDiv2);
    SYSTEM.PUT(addr + MCU.PLL_PRIM_Offset, val);
    (* power up post dividers (note: clear bits) *)
    SYSTEM.PUT(addr + MCU.PLL_PWR_Offset + MCU.ACLR, {PLL_PWR_POSTDIVPD})
  END ConfigPLL;


  PROCEDURE* GetPLLcfg*(pll: INTEGER; VAR cfg: PLLcfg);
    VAR addr, val: INTEGER;
  BEGIN
    addr := MCU.PLL_SYS_BASE + (pll * MCU.PLL_Offset);
    SYSTEM.GET(addr + MCU.PLL_FBDIV_INT_Offset, cfg.fbDiv);
    SYSTEM.GET(addr + MCU.PLL_PRIM_Offset, val);
    cfg.postDiv1 := BFX(val, 18, 16);
    cfg.postDiv2 := BFX(val, 14, 12)
  END GetPLLcfg;


  PROCEDURE* ConfigClocks*(cfg: ClocksCfg);
    VAR val: INTEGER; vals: SET;
  BEGIN
    (* always enabled *)
    SYSTEM.GET(MCU.CLK_SYS_CTRL, val);
    BFI(val, 7, 5, cfg.sysAuxSrc);
    BFI(val, 0, cfg.sysSrc);
    SYSTEM.PUT(MCU.CLK_SYS_CTRL, val);
    REPEAT
      SYSTEM.GET(MCU.CLK_SYS_SELECTED, vals)
    UNTIL cfg.sysSrc IN vals;
    val := 0;
    BFI(val, 31, 8, cfg.sysDivInt);
    SYSTEM.PUT(MCU.CLK_SYS_DIV, val);

    (* always enabled *)
    SYSTEM.GET(MCU.CLK_REF_CTRL, val);
    BFI(val, 6, 5, cfg.refAuxSrc);
    BFI(val, 1, 0, cfg.refSrc);
    SYSTEM.PUT(MCU.CLK_REF_CTRL, val);
    REPEAT
      SYSTEM.GET(MCU.CLK_REF_SELECTED, vals)
    UNTIL cfg.refSrc IN vals;
    val := 0;
    BFI(val, 9, 8, cfg.refDivInt);
    SYSTEM.PUT(MCU.CLK_REF_DIV, val);

    SYSTEM.GET(MCU.CLK_PERI_CTRL, val);
    BFI(val, 7, 5, cfg.periAuxSrc);
    SYSTEM.PUT(MCU.CLK_PERI_CTRL, val);
    SYSTEM.PUT(MCU.CLK_PERI_CTRL + MCU.ASET, {CLK_PERI_CTRL_ENABLE})
  END ConfigClocks;


  PROCEDURE* GetClocksCfg*(VAR cfg: ClocksCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.CLK_SYS_CTRL, val);
    cfg.sysAuxSrc := BFX(val, 7, 5);
    cfg.sysSrc := BFX(val, 0);
    SYSTEM.GET(MCU.CLK_SYS_DIV, val);
    cfg.sysDivInt := BFX(val, 31, 16);

    SYSTEM.GET(MCU.CLK_REF_CTRL, val);
    cfg.refAuxSrc := BFX(val, 7, 5);
    cfg.refSrc := BFX(val, 0);
    SYSTEM.GET(MCU.CLK_SYS_DIV, val);
    cfg.refDivInt := BFX(val, 23, 16);

    SYSTEM.GET(MCU.CLK_PERI_CTRL, val);
    cfg.periAuxSrc := BFX(val, 7, 5)
  END GetClocksCfg;


  PROCEDURE* ConfigTicks*(cfg: TicksCfg);
  (* applies to watchdog, systick, timer *)
  BEGIN
    SYSTEM.PUT(MCU.WATCHDOG_TICK, cfg.watchdogDiv);
    SYSTEM.PUT(MCU.WATCHDOG_TICK + MCU.ASET, {WATCHDOG_TICK_EN})
  END ConfigTicks;


  PROCEDURE* GetTicksCfg*(VAR cfg: TicksCfg);
  BEGIN
    SYSTEM.GET(MCU.WATCHDOG_TICK, cfg.watchdogDiv)
  END GetTicksCfg;

END CLK.
