MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Oscillator and clocks controller driver
  --
  MCU: RP2350
  --
  Run 'python -m vcocalc -h' for PLL calculations.
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, BASE, RST, SYS := CLK_SYS;

  CONST
    PLLsys* = SYS.PLLsys;
    PLLusb* = SYS.PLLusb;

    RefAuxSrc_PLLusb* = 0;
    RefAuxSrc_GPIO0* = 1;
    RefAuxSrc_GPIO1* = 2;
    RefSrc_ROSC* = 0;
    RefSrc_AUX* = 1;
    RefSrc_XOSC* = 2;
    RefSrc_LPO* = 3;

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
      periAuxSrc*, periDivInt*: INTEGER
    END;

    TicksCfg* = RECORD
      sysTickDiv0*, sysTickDiv1*: INTEGER;
      timerDiv0*, timerDiv1*: INTEGER;
      watchdogDiv*: INTEGER
    END;


  PROCEDURE* StartXOSC*;
  (* 12 MHz *)
    CONST XOSC_Enable = 0FABH; FREQ_RANGE_val_15 = 0AA0H; XOSC_STATUS_STABLE = 31;
    VAR val: INTEGER;
  BEGIN
    (* ensure register accessibility, ie. PSM done *)
    REPEAT UNTIL SYSTEM.BIT(SYS.XOSC_PSM_reg, SYS.XOSC_PSM_pos);
    (* set start-up delay *)
    SYSTEM.PUT(SYS.XOSC_STARTUP, 94); (* about 2 ms *)
    (* enable *)
    SYSTEM.GET(SYS.XOSC_CTRL, val);
    BFI(val, 11, 0, FREQ_RANGE_val_15);
    BFI(val, 23, 12, XOSC_Enable);
    SYSTEM.PUT(SYS.XOSC_CTRL, val);
    (* wait for osc to stabilize *)
    REPEAT UNTIL SYSTEM.BIT(SYS.XOSC_STATUS, XOSC_STATUS_STABLE)
  END StartXOSC;


  PROCEDURE* ConfigPLL*(pll: INTEGER; cfg: PLLcfg);
    CONST
      CS_LOCK = 31;
      PLL_PWR_VCOPD = 5;
      PLL_PWR_POSTDIVPD = 3;
      PLL_PWR_PD = 0;
    VAR addr, val: INTEGER;
  BEGIN
    addr := SYS.PLL_SYS_BASE + (pll * SYS.PLL_Offset);
    (* set multiplier *)
    SYSTEM.PUT(addr + SYS.PLL_FBDIV_INT_Offset, cfg.fbDiv);
    (* power up VCO and PLL (note: clear bits) *)
    SYSTEM.PUT(addr + SYS.PLL_PWR_Offset + BASE.ACLR, {PLL_PWR_VCOPD, PLL_PWR_PD});
    SYSTEM.PUT(addr + SYS.PLL_CS_Offset, cfg.refDiv);
    REPEAT UNTIL SYSTEM.BIT(addr + SYS.PLL_CS_Offset, CS_LOCK);
    (* set post dividers *)
    val := 0;
    BFI(val, 18, 16, cfg.postDiv1);
    BFI(val, 14, 12, cfg.postDiv2);
    SYSTEM.PUT(addr + SYS.PLL_PRIM_Offset, val);
    (* power up post dividers (note: clear bits) *)
    SYSTEM.PUT(addr + SYS.PLL_PWR_Offset + BASE.ACLR, {PLL_PWR_POSTDIVPD})
  END ConfigPLL;


  PROCEDURE* GetPLLcfg*(pll: INTEGER; VAR cfg: PLLcfg);
    VAR addr, val: INTEGER;
  BEGIN
    addr := SYS.PLL_SYS_BASE + (pll * SYS.PLL_Offset);
    SYSTEM.GET(addr + SYS.PLL_FBDIV_INT_Offset, cfg.fbDiv);
    SYSTEM.GET(addr + SYS.PLL_PRIM_Offset, val);
    cfg.postDiv1 := BFX(val, 18, 16);
    cfg.postDiv2 := BFX(val, 14, 12)
  END GetPLLcfg;


  PROCEDURE EnablePLL*(pll: INTEGER);
  BEGIN
    IF pll = PLLsys THEN
      RST.ReleaseReset(SYS.PLL_SYS_RST_reg, SYS.PLL_SYS_RST_pos)
    ELSE
      RST.ReleaseReset(SYS.PLL_USB_RST_reg, SYS.PLL_USB_RST_pos)
    END
  END EnablePLL;


  PROCEDURE* ConfigClocks*(cfg: ClocksCfg);
    CONST CLK_PERI_CTRL_ENABLE    = 11;
    VAR val: INTEGER; vals: SET;
  BEGIN
    (* always enabled *)
    SYSTEM.GET(SYS.CLK_SYS_CTRL, val);
    BFI(val, 7, 5, cfg.sysAuxSrc);
    BFI(val, 0, cfg.sysSrc);
    SYSTEM.PUT(SYS.CLK_SYS_CTRL, val);
    REPEAT
      SYSTEM.GET(SYS.CLK_SYS_SELECTED, vals)
    UNTIL cfg.sysSrc IN vals;
    SYSTEM.PUT(SYS.CLK_SYS_DIV, LSL(cfg.sysDivInt, 16));

    (* always enabled *)
    SYSTEM.GET(SYS.CLK_REF_CTRL, val);
    BFI(val, 6, 5, cfg.refAuxSrc);
    BFI(val, 1, 0, cfg.refSrc);
    SYSTEM.PUT(SYS.CLK_REF_CTRL, val);
    REPEAT
      SYSTEM.GET(SYS.CLK_REF_SELECTED, vals)
    UNTIL cfg.refSrc IN vals;
    SYSTEM.PUT(SYS.CLK_REF_DIV, LSL(cfg.refDivInt, 16));

    SYSTEM.GET(SYS.CLK_PERI_CTRL, val);
    BFI(val, 7, 5, cfg.periAuxSrc);
    SYSTEM.PUT(SYS.CLK_PERI_CTRL, val);
    val := 0;
    BFI(val, 17, 16, cfg.periDivInt);
    SYSTEM.PUT(SYS.CLK_PERI_DIV, val);
    SYSTEM.PUT(SYS.CLK_PERI_CTRL + BASE.ASET, {CLK_PERI_CTRL_ENABLE})
  END ConfigClocks;


  PROCEDURE* GetClocksCfg*(VAR cfg: ClocksCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(SYS.CLK_SYS_CTRL, val);
    cfg.sysAuxSrc := BFX(val, 7, 5);
    cfg.sysSrc := BFX(val, 0);
    SYSTEM.GET(SYS.CLK_SYS_DIV, val);
    cfg.sysDivInt := BFX(val, 31, 16);

    SYSTEM.GET(SYS.CLK_REF_CTRL, val);
    cfg.refAuxSrc := BFX(val, 7, 5);
    cfg.refSrc := BFX(val, 0);
    SYSTEM.GET(SYS.CLK_SYS_DIV, val);
    cfg.refDivInt := BFX(val, 23, 16);

    SYSTEM.GET(SYS.CLK_PERI_CTRL, val);
    cfg.periAuxSrc := BFX(val, 7, 5);
    SYSTEM.GET(SYS.CLK_PERI_DIV, val);
    cfg.periDivInt := BFX(val, 31, 16)
  END GetClocksCfg;


  PROCEDURE* ConfigTicks*(cfg: TicksCfg);
    CONST TICKS_CTRL_EN = 0;
  BEGIN
    SYSTEM.PUT(SYS.TICKS_PROC0_CYCLES, cfg.sysTickDiv0);
    SYSTEM.PUT(SYS.TICKS_PROC1_CYCLES, cfg.sysTickDiv0);
    SYSTEM.PUT(SYS.TICKS_TIMER0_CYCLES, cfg.timerDiv0);
    SYSTEM.PUT(SYS.TICKS_TIMER1_CYCLES, cfg.timerDiv1);
    SYSTEM.PUT(SYS.TICKS_WATCHDOG_CYCLES, cfg.watchdogDiv);

    SYSTEM.PUT(SYS.TICKS_PROC0_CTRL + BASE.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(SYS.TICKS_PROC1_CTRL + BASE.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(SYS.TICKS_TIMER0_CTRL + BASE.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(SYS.TICKS_TIMER1_CTRL + BASE.ASET, {TICKS_CTRL_EN});
    SYSTEM.PUT(SYS.TICKS_WATCHDOG_CTRL + BASE.ASET, {TICKS_CTRL_EN})
  END ConfigTicks;


  PROCEDURE* GetTicksCfg*(VAR cfg: TicksCfg);
  BEGIN
    SYSTEM.GET(SYS.TICKS_PROC0_CYCLES, cfg.sysTickDiv0);
    SYSTEM.GET(SYS.TICKS_PROC1_CYCLES, cfg.sysTickDiv0);
    SYSTEM.GET(SYS.TICKS_TIMER0_CYCLES, cfg.timerDiv0);
    SYSTEM.GET(SYS.TICKS_TIMER1_CYCLES, cfg.timerDiv1);
    SYSTEM.GET(SYS.TICKS_WATCHDOG_CYCLES, cfg.watchdogDiv);
  END GetTicksCfg;


  (* Secure/Non-secure, RP2350 only *)

  PROCEDURE GetDevSec*(VAR clk, pllSys, pllUSB, ticks, xosc, rosc: INTEGER);
  BEGIN
    clk := SYS.CLK_SEC_reg;
    pllSys := SYS.PLL_SYS_SEC_reg;
    pllUSB := SYS.PLL_USB_SEC_reg;
    ticks := SYS.TICKS_SEC_reg;
    xosc := SYS.XOSC_SEC_reg;
    rosc := SYS.ROSC_SEC_reg
  END GetDevSec;

END CLK.
