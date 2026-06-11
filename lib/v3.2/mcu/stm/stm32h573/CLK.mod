MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  RCC clocks device driver.
  Bus clock is enabled after reset.
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SYS := RCC_SYS;

  CONST
    (* handles *)
    (* do  not assume any specific value for these handles *)
    PLL1* = SYS.PLL1;
    PLL2* = SYS.PLL2;
    PLL3* = SYS.PLL3;

    MCO1* = 0;
    MCO2* = 1;

    (* for 'PLLcfg' *)
    PLLsrc_None* = 0;
    PLLsrc_HSI* = 1;
    PLLsrc_CSI* = 2;
    PLLsrc_HSE* = 3;

    PLLsrc_Frq_1_2* = 0;  (* 1 to 2 MHz *)
    PLLsrc_Frq_2_4* = 1;  (* 2 to 4 MHz *)
    PLLsrc_Frq_4_8* = 2;  (* 4 to 8 MHz *)
    PLLsrc_Frq_8_16* = 3; (* 8 to 16 MHz *)

    (* for 'ConfigSysClk' *)
    SysClk_HSI* = 0;
    SysClk_CSI* = 1;
    SysClk_HSE* = 2;
    SysClk_PLL* = 3;  (* PLL1, output P *)

    (* for 'BusPrescCfg' *)
    AHBpresc_1* = 7; (* divide by 1 *)
    AHBpresc_2* = 8;
    AHBpresc_4* = 9;
    AHBpresc_8* = 10;
    AHBpresc_16* = 11;
    AHBpresc_64* = 12;
    AHBpresc_128* = 13;
    AHBpresc_256* = 14;
    AHBpresc_512* = 15; (* divide by 512 *)

    ABPpresc_1* = 3; (* divide by 1 *)
    ABPpresc_2* = 4;
    ABPpresc_4* = 5;
    ABPpresc_8* = 6;
    ABPpresc_16* = 7; (* divide by 16 *)

    (* MCO clock out *)
    MCO1sel_HSI* = 0;
    MCO1sel_LSE* = 1;
    MCO1sel_HSE* = 2;
    MCO1sel_PLL1Q* = 3;
    MCO1sel_HSI48* = 4;

    MCO2sel_SYSCLK* = 0;
    MCO2sel_PLL2P* = 1;
    MCO2sel_HSE* = 2;
    MCO2sel_PLL1P* = 3;
    MCO2sel_CSI* = 4;
    MCO2sel_LSI* = 5;

    MCOpre_Off* = 0;
    MCOpre_1* = 1; (* divide by 1 *)
    (* actual prescale values *)
    MCOpre_15* = 15;


  TYPE
    PLLcfg* = RECORD
      src*, range*: INTEGER;
      pen*, qen*, ren*: INTEGER;    (* P, Q, R output enable *)
      mdiv*: INTEGER;               (* src pre-divider *)
      pdiv*: INTEGER;               (* P output divider, pdiv must be an odd value on PLL1 *)
      qdiv*, rdiv*: INTEGER;        (* Q, R output dividers *)
      ndiv*: INTEGER;               (* feeback devider = multiplier *)
      vcoSel*: INTEGER
    END;

    BusPrescCfg* = RECORD
      ahbPresc*: INTEGER;
      apb1Presc*: INTEGER;
      apb2Presc*: INTEGER;
      apb3Presc*: INTEGER
    END;

    OscCfg* = RECORD
      hsiEn*, csiEn*: INTEGER;
      hsi48En*: INTEGER;
      hseEn*: INTEGER
    END;

    LsOscCfg* = RECORD
      lsiEn*, lseEn*: INTEGER
    END;


  (* -- PLL -- *)

  PROCEDURE* ConfigPLL*(pllId: INTEGER; cfg: PLLcfg);
    VAR addr, val: INTEGER;
  BEGIN
    ASSERT(pllId IN SYS.PLL_all);
    addr := SYS.RCC_PLL1CFGR + (pllId * 4);
    SYSTEM.GET(addr, val);
    BFI(val, 18, cfg.ren);
    BFI(val, 17, cfg.qen);
    BFI(val, 16, cfg.pen);
    BFI(val, 13, 8, cfg.mdiv);
    BFI(val, 5, cfg.vcoSel);
    BFI(val, 3, 2, cfg.range);
    BFI(val, 1, 0, cfg.src);
    SYSTEM.PUT(addr, val);
    addr := SYS.RCC_PLL1DIVR + (pllId * 8);
    SYSTEM.GET(addr, val);
    BFI(val, 30, 24, cfg.rdiv);
    BFI(val, 22, 16, cfg.qdiv);
    BFI(val, 15, 9, cfg.pdiv);
    BFI(val, 8, 0, cfg.ndiv);
    SYSTEM.PUT(addr, val)
  END ConfigPLL;


  PROCEDURE* GetPLLcfg*(pllId: INTEGER; VAR cfg: PLLcfg);
    VAR addr, val: INTEGER;
  BEGIN
    ASSERT(pllId IN SYS.PLL_all);
    addr := SYS.RCC_PLL1CFGR + (pllId * 4);
    SYSTEM.GET(addr, val);
    cfg.ren := BFX(val, 18);
    cfg.qen := BFX(val, 17);
    cfg.pen := BFX(val, 16);
    cfg.mdiv := BFX(val, 11, 8);
    cfg.range := BFX(val, 3, 2);
    cfg.src := BFX(val, 1, 0);
    addr := SYS.RCC_PLL1DIVR + (pllId * 8);
    SYSTEM.GET(addr, val);
    cfg.rdiv := BFX(val, 30, 24);
    cfg.qdiv := BFX(val, 22, 16);
    cfg.pdiv := BFX(val, 15, 9);
    cfg.ndiv := BFX(val, 8, 0)
  END GetPLLcfg;


  PROCEDURE* StartPLL*(pllId: INTEGER);
    VAR val: SET; en, lk: INTEGER;
  BEGIN
    ASSERT(pllId IN SYS.PLL_all);
    en := 24 + pllId * 2;
    lk := 25 + pllId * 2;
    SYSTEM.GET(SYS.RCC_CR, val);
    SYSTEM.PUT(SYS.RCC_CR, val + {en});
    REPEAT
      SYSTEM.GET(SYS.RCC_CR, val)
    UNTIL lk IN val
  END StartPLL;

  (* -- system clock -- *)

  PROCEDURE* ConfigSysClk*(sysClk: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(SYS.RCC_CFGR1, val);
    BFI(val, 1, 0, sysClk);
    SYSTEM.PUT(SYS.RCC_CFGR1, val);
    REPEAT
      SYSTEM.GET(SYS.RCC_CFGR1, val)
    UNTIL BFX(val, 4, 3) = sysClk
  END ConfigSysClk;

  (* -- bus prescalers -- *)

  PROCEDURE ConfigBusPresc*(cfg: BusPrescCfg);
    VAR val, RCC_CFGR2: INTEGER;
  BEGIN
    RCC_CFGR2 := SYS.RCC_CFGR2;
    SYSTEM.GET(RCC_CFGR2, val);
    BFI(val, 14, 12, cfg.apb3Presc);
    BFI(val, 10, 8, cfg.apb2Presc);
    BFI(val, 6, 4, cfg.apb1Presc);
    BFI(val, 3, 0, cfg.ahbPresc);
    SYSTEM.PUT(RCC_CFGR2, val)
  END ConfigBusPresc;


  PROCEDURE* GetBusPresc*(VAR cfg: BusPrescCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(SYS.RCC_CFGR2, val);
    cfg.apb3Presc := BFX(val, 14, 12);
    cfg.apb2Presc := BFX(val, 10, 8);
    cfg.apb1Presc := BFX(val, 6, 4);
    cfg.ahbPresc := BFX(val, 3, 0)
  END GetBusPresc;

  (* -- oscillators -- *)

  PROCEDURE* ConfigOsc*(cfg: OscCfg);
    CONST
      MaskEn = {0, 8, 12, 16}; MaskRdy = {1, 9, 13, 17};
    VAR oscMask, RCC_CR: INTEGER; val, rdyMask: SET;
  BEGIN
    RCC_CR := SYS.RCC_CR;
    oscMask := 0;
    BFI(oscMask, 0, cfg.hsiEn);
    BFI(oscMask, 8, cfg.csiEn);
    BFI(oscMask, 12, cfg.hsi48En);
    BFI(oscMask, 16, cfg.hseEn);
    SYSTEM.GET(RCC_CR, val);
    SYSTEM.PUT(RCC_CR, val - MaskEn + BITS(oscMask));
    rdyMask := BITS(LSL(oscMask, 1));
    REPEAT
      SYSTEM.GET(RCC_CR, val)
    UNTIL val * MaskRdy = rdyMask
  END ConfigOsc;

  (* -- LS oscillators -- *)

  PROCEDURE* ConfigLsOsc*(cfg: LsOscCfg);
  (* requires PWR to be clocked *)
    CONST LsMaskEn = {0, 26}; LsMaskRdy = {1, 27};
    VAR oscMask, RCC_BDCR, PWR_DBPCR: INTEGER; val, rdyMask: SET;
  BEGIN
    RCC_BDCR := SYS.RCC_BDCR;
    PWR_DBPCR := SYS.RCC_PWR_DBPCR;
    oscMask := 0;
    BFI(oscMask, 0, cfg.lseEn);
    BFI(oscMask, 26, cfg.lsiEn);
    IF oscMask # 0 THEN
      SYSTEM.PUT(PWR_DBPCR, {0}); (* write enable RCC_BDCR *)
      SYSTEM.GET(RCC_BDCR, val);
      SYSTEM.PUT(RCC_BDCR, val - LsMaskEn + BITS(oscMask));
      SYSTEM.PUT(PWR_DBPCR, {}); (* write disable RCC_BDCR *)
      rdyMask := BITS(LSL(oscMask, 1));
      REPEAT
        SYSTEM.GET(RCC_BDCR, val)
      UNTIL val * LsMaskRdy = rdyMask
    END
  END ConfigLsOsc;

  (* #todo *)
  (*
  PROCEDURE* SetClkOut*(mcoId, mcoSel, mcoPre: INTEGER);
  (* modify only after reset, before enabling external oscillators and PLLs *)
    VAR val: INTEGER;
  BEGIN
    ASSERT(mcoId IN MCO);
    SYSTEM.GET(MCU.RCC_CFGR1, val);
    IF mcoId = MCO1 THEN
      BFI(val, 24, 22, mcoSel);
      BFI(val, 21, 18, mcoPre)
    ELSE
      BFI(val, 31, 29, mcoSel);
      BFI(val, 28, 25, mcoPre)
    END;
    SYSTEM.PUT(MCU.RCC_CFGR1, val)
  END SetClkOut;
  *)

END CLK.

