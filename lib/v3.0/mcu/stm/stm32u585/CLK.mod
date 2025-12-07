MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  RCC clocks device driver.
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    PLL1* = 0;
    PLL2* = 1;
    PLL3* = 2;

    PLLsrc_None* = 0;
    PLLsrc_MSIS* = 1;
    PLLsrc_HSI16* = 2;
    PLLsrc_HSE* = 3;

    PLLsrc_Frq_4_8* = 0;   (* 4 to 8 MHz *)
    PLLsrc_Frq_8_16* = 1;  (* 8 to 16 MHz *)

    SysClk_MSIS* = 0;
    SysClk_HSI16* = 1;
    SysClk_HSE* = 2;
    SysClk_PLL* = 3; (* PLL1, output R *)

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

    (* for EnableOsc *)
    MSISen* = 0;
    MSIKen* = 4;
    HSIen* = 8;
    HSI48en* = 12;
    HSEen* = 16;

    (* MCO clock out *)
    MCOsel_None* = 0;
    MCOsel_SYSCLK* = 1;
    MCOsel_MSIS* = 2;
    MCOsel_HSI16* = 3;
    MCOsel_HSE* = 4;
    MCOsel_PLL1R* = 5;
    MCOsel_LSI* = 6;
    MCOsel_LSE* = 7;
    MCOsel_HSI48* = 8;
    MCOsel_MSIK* = 9;

    MCOpre_1* = 0; (* divide by 1 *)
    MCOpre_2* = 1;
    MCOpre_4* = 2;
    MCOpre_8* = 3;
    MCOpre_16* = 4; (* divide by 16 *)

    (* oscillators, if enabled *)
    MSIS_FREQ* = 4 * 1000000;
    MSIK_FREQ* = 4 * 1000000;
    HSI16_FREQ* = 16 * 1000000;
    HSI48_FREQ* = 48 * 1000000;

  TYPE
    PLLcfg* = RECORD
      src*, range*: INTEGER;
      pen*, qen*, ren*: INTEGER;    (* P, Q, R output enable *)
      mdiv*: INTEGER;               (* src pre-divider *)
      pdiv*, qdiv*: INTEGER;        (* P, Q output dividers *)
      rdiv*: INTEGER;               (* R output divider, cannot have value 2 on PLL1 *)
      ndiv*: INTEGER                (* feeback devider = multiplier *)
    END;

    BusPrescCfg* = RECORD
      ahbPresc*: INTEGER;
      apb1Presc*: INTEGER;
      apb2Presc*: INTEGER;
      apb3Presc*: INTEGER
    END;


  PROCEDURE* ConfigPLL*(pllId: INTEGER; cfg: PLLcfg);
    VAR addr, val: INTEGER;
  BEGIN
    addr := MCU.RCC_PLL1CFGR + (pllId * 4);
    SYSTEM.GET(addr, val);
    BFI(val, 18, cfg.ren);
    BFI(val, 17, cfg.qen);
    BFI(val, 16, cfg.pen);
    BFI(val, 11, 8, cfg.mdiv);
    BFI(val, 3, 2, cfg.range);
    BFI(val, 1, 0, cfg.src);
    SYSTEM.PUT(addr, val);
    addr := MCU.RCC_PLL1DIVR + (pllId * 8);
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
    addr := MCU.RCC_PLL1CFGR + (pllId * 4);
    SYSTEM.GET(addr, val);
    cfg.ren := BFX(val, 18);
    cfg.qen := BFX(val, 17);
    cfg.pen := BFX(val, 16);
    cfg.mdiv := BFX(val, 11, 8);
    cfg.range := BFX(val, 3, 2);
    cfg.src := BFX(val, 1, 0);
    addr := MCU.RCC_PLL1DIVR + (pllId * 8);
    SYSTEM.GET(addr, val);
    cfg.rdiv := BFX(val, 30, 24);
    cfg.qdiv := BFX(val, 22, 16);
    cfg.pdiv := BFX(val, 15, 9);
    cfg.ndiv := BFX(val, 8, 0)
  END GetPLLcfg;


  PROCEDURE* SetEPODboost*(div: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.RCC_PLL1CFGR, val);
    BFI(val, 15, 12, div);
    SYSTEM.GET(MCU.RCC_PLL1CFGR, val)
  END SetEPODboost;


  PROCEDURE* StartPLL*(pllId: INTEGER);
    VAR val: SET; en, lk: INTEGER;
  BEGIN
    en := 24 + pllId * 2;
    lk := 25 + pllId * 2;
    SYSTEM.GET(MCU.RCC_CR, val);
    SYSTEM.PUT(MCU.RCC_CR, val + {en});
    REPEAT
      SYSTEM.GET(MCU.RCC_CR, val)
    UNTIL lk IN val
  END StartPLL;


  PROCEDURE* SetSysClk*(sysClk: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.RCC_CFGR1, val);
    BFI(val, 1, 0, sysClk);
    SYSTEM.PUT(MCU.RCC_CFGR1, val);
    REPEAT
      SYSTEM.GET(MCU.RCC_CFGR1, val)
    UNTIL BFX(val, 3, 2) = sysClk
  END SetSysClk;


  PROCEDURE SetBusPresc*(cfg: BusPrescCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.RCC_CFGR2, val);
    BFI(val, 10, 8, cfg.apb2Presc);
    BFI(val, 6, 4, cfg.apb1Presc);
    BFI(val, 3, 0, cfg.ahbPresc);
    SYSTEM.PUT(MCU.RCC_CFGR2, val);
    SYSTEM.GET(MCU.RCC_CFGR3, val);
    BFI(val, 6, 4, cfg.apb3Presc);
    SYSTEM.PUT(MCU.RCC_CFGR3, val)
  END SetBusPresc;


  PROCEDURE* GetBusPresc*(VAR cfg: BusPrescCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.RCC_CFGR2, val);
    cfg.apb2Presc := BFX(val, 10, 8);
    cfg.apb1Presc := BFX(val, 6, 4);
    cfg.ahbPresc := BFX(val, 3, 0);
    SYSTEM.GET(MCU.RCC_CFGR3, val);
    cfg.apb3Presc := BFX(val, 6, 4)
  END GetBusPresc;


  PROCEDURE* EnableOsc*(oscMask: SET);
    CONST
      MaskEn = {0, 4, 8, 12, 16}; MaskRdy = {2, 5, 10, 13, 17};
      MaskEn2 = {0, 8}; MaskEn1 = {4, 12, 17};
    VAR val, rdyMask: SET;
  BEGIN
    oscMask := oscMask * MaskEn;
    SYSTEM.GET(MCU.RCC_CR, val);
    SYSTEM.PUT(MCU.RCC_CR, val - MaskEn + oscMask);
    (* create the ready check mask *)
    rdyMask := BITS(LSL(ORD(oscMask * MaskEn1), 1));
    rdyMask := rdyMask + BITS(LSL(ORD(oscMask * MaskEn2), 2));
    REPEAT
      SYSTEM.GET(MCU.RCC_CR, val)
    UNTIL val * MaskRdy = rdyMask
  END EnableOsc;


  PROCEDURE* SetClkOut*(mcoSel, mcoPre: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.RCC_CFGR1, val);
    BFI(val, 27, 24, mcoSel);
    BFI(val, 30, 28, mcoPre);
    SYSTEM.PUT(MCU.RCC_CFGR1, val)
  END SetClkOut;


  PROCEDURE* EnableClock*(device: INTEGER);
  (* bus clock *)
  (* MCU.DEV_* device values *)
    VAR reg, devNo: INTEGER; val: SET;
  BEGIN
    reg := device DIV 32;
    reg := MCU.RCC_AHB1ENR + (reg * 4);
    IF reg > MCU.RCC_AHB3ENR THEN INC(reg, 4) END;
    devNo := device MOD 32;
    SYSTEM.GET(reg, val);
    INCL(val, devNo);
    SYSTEM.PUT(reg, val)
  END EnableClock;


  PROCEDURE* DisableClock*(device: INTEGER);
  (* bus clock *)
  (* MCU.DEV_* device values *)
    VAR reg, devNo: INTEGER; val: SET;
  BEGIN
    reg := device DIV 32;
    reg := MCU.RCC_AHB1ENR + (reg * 4);
    devNo := device MOD 32;
    SYSTEM.GET(reg, val);
    EXCL(val, devNo);
    SYSTEM.PUT(reg, val)
  END DisableClock;


  PROCEDURE* ConfigDevClock*(clkSelReg, clkSelVal, posSel, numBits: INTEGER);
  (* set functional/kernel clock *)
  (* use with clock disabled *)
    VAR mask, val, sel0: SET;
  BEGIN
    clkSelVal := LSR(LSL(clkSelVal, 32 - numBits), 32 - numBits);
    mask := {posSel, posSel + numBits - 1};
    sel0 := BITS(LSL(clkSelVal, posSel));
    SYSTEM.GET(clkSelReg, val);
    val := val - mask + sel0;
    SYSTEM.PUT(clkSelReg, val)
  END ConfigDevClock;

END CLK.

