MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  RCC clocks device driver.
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    PLL1* = 0;
    PLL2* = 1;
    PLL3* = 2;
    PLL = {0 .. 2};

    MCO1* = 0;
    MCO2* = 1;
    MCO = {0 .. 1};

    (* for 'PLLcfg' *)
    PLLsrc_None* = 0;
    PLLsrc_HSI* = 1;
    PLLsrc_CSI* = 2;
    PLLsrc_HSE* = 3;

    PLLsrc_Frq_1_2* = 0;  (* 1 to 2 MHz *)
    PLLsrc_Frq_2_4* = 1;  (* 2 to 4 MHz *)
    PLLsrc_Frq_4_8* = 2;  (* 4 to 8 MHz *)
    PLLsrc_Frq_8_16* = 3; (* 8 to 16 MHz *)

    (* for 'SetSysClk' *)
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

    (* for EnableOsc *)
    HSIen* = 0;
    CSIen* = 8;
    HSI48en* = 12;
    HSEen* = 16;

    (* MCO clock out *)
    (* for 'SetClkOut' *)
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

    (* oscillators, if enabled *)
    CSI_FREQ* = 4 * 1000000;
    HSI48_FREQ* = 48 * 1000000;
    HSI_FREQ* = 32 * 1000000; (* with HSIDIV = 2, default *)

    (* functional/kernel clock parameters *)
    (* for 'ConfigDevClock' *)
    CLK_SYST_REG*  = MCU.RCC_CCIPR4;
    CLK_SYST_POS*  = 2;


  TYPE
    PLLcfg* = RECORD
      src*, range*: INTEGER;
      pen*, qen*, ren*: INTEGER;    (* P, Q, R output enable *)
      mdiv*: INTEGER;               (* src pre-divider *)
      pdiv*: INTEGER;               (* P output divider, pdiv must be an odd value on PLL1 *)
      qdiv*, rdiv*: INTEGER;        (* Q, R output dividers *)
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
    ASSERT(pllId IN PLL);
    addr := MCU.RCC_PLL1CFGR + (pllId * 4);
    SYSTEM.GET(addr, val);
    BFI(val, 18, cfg.ren);
    BFI(val, 17, cfg.qen);
    BFI(val, 16, cfg.pen);
    BFI(val, 13, 8, cfg.mdiv);
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
    ASSERT(pllId IN PLL);
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


  PROCEDURE* StartPLL*(pllId: INTEGER);
    VAR val: SET; en, lk: INTEGER;
  BEGIN
    ASSERT(pllId IN PLL);
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
    UNTIL BFX(val, 4, 3) = sysClk
  END SetSysClk;


  PROCEDURE SetBusPresc*(cfg: BusPrescCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.RCC_CFGR2, val);
    BFI(val, 14, 12, cfg.apb3Presc);
    BFI(val, 10, 8, cfg.apb2Presc);
    BFI(val, 6, 4, cfg.apb1Presc);
    BFI(val, 3, 0, cfg.ahbPresc);
    SYSTEM.PUT(MCU.RCC_CFGR2, val)
  END SetBusPresc;


  PROCEDURE* GetBusPresc*(VAR cfg: BusPrescCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.RCC_CFGR2, val);
    cfg.apb3Presc := BFX(val, 14, 12);
    cfg.apb2Presc := BFX(val, 10, 8);
    cfg.apb1Presc := BFX(val, 6, 4);
    cfg.ahbPresc := BFX(val, 3, 0)
  END GetBusPresc;


  PROCEDURE* EnableOsc*(oscMask: SET);
    CONST
      MaskEn = {0, 8, 12, 16}; MaskRdy = {1, 9, 13, 17};
    VAR val, rdyMask: SET;
  BEGIN
    oscMask := oscMask * MaskEn;
    SYSTEM.GET(MCU.RCC_CR, val);
    SYSTEM.PUT(MCU.RCC_CR, val - MaskEn + oscMask);
    (* create the ready check mask *)
    rdyMask := BITS(LSL(ORD(oscMask), 1));
    REPEAT
      SYSTEM.GET(MCU.RCC_CR, val)
    UNTIL val * MaskRdy = rdyMask
  END EnableOsc;


  PROCEDURE* SetClkOut*(mcoId, mcoSel, mcoPre: INTEGER);
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


  PROCEDURE* EnableBusClock*(device: INTEGER);
  (* MCU.DEV_* device values *)
    VAR reg, devNo: INTEGER; val: SET;
  BEGIN
    reg := device DIV 32;
    reg := MCU.RCC_AHB1ENR + (reg * 4);
    devNo := device MOD 32;
    SYSTEM.GET(reg, val);
    INCL(val, devNo);
    SYSTEM.PUT(reg, val)
  END EnableBusClock;


  PROCEDURE* DisableBusClock*(device: INTEGER);
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
  END DisableBusClock;


  PROCEDURE* ConfigDevClock*(clkSelReg, clkSelVal, posSel, numBits: INTEGER);
  (* set functional/kernel clock *)
  (* use with clock disabled *)
    VAR mask, val, sel: SET;
  BEGIN
    clkSelVal := LSR(LSL(clkSelVal, 32 - numBits), 32 - numBits);
    mask := {posSel, posSel + numBits - 1};
    sel := BITS(LSL(clkSelVal, posSel));
    SYSTEM.GET(clkSelReg, val);
    val := val - mask + sel;
    SYSTEM.PUT(clkSelReg, val)
  END ConfigDevClock;

END CLK.

