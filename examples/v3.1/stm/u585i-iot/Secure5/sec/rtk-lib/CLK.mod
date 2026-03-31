MODULE CLK;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  RCC clocks device driver (RCC)
  Bus clock is enabled after reset.
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV0;

  CONST
    PLL1* = 0;
    PLL2* = 1;
    PLL3* = 2;
    PLL = {0 .. 2};

    (* for 'PLLcfg' *)
    PLLsrc_None* = 0;
    PLLsrc_MSIS* = 1;
    PLLsrc_HSI16* = 2;
    PLLsrc_HSE* = 3;

    PLLsrc_Frq_4_8* = 0;   (* 4 to 8 MHz *)
    PLLsrc_Frq_8_16* = 1;  (* 8 to 16 MHz *)

    (* for 'SetSysClk' *)
    SysClk_MSIS* = 0;
    SysClk_HSI16* = 1;
    SysClk_HSE* = 2;
    SysClk_PLL* = 3; (* PLL1, output R *)

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
    (* for 'SetClkOut' *)
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
      ndiv*: INTEGER                (* feedback devider = multiplier *)
    END;

    BusPrescCfg* = RECORD
      ahbPresc*: INTEGER;
      apb1Presc*: INTEGER;
      apb2Presc*: INTEGER;
      apb3Presc*: INTEGER
    END;

    OscCfg* = RECORD
      msisEn*, msikEn*: INTEGER;
      hsiEn*, hsi48En*: INTEGER;
      hseEn*: INTEGER
    END;

    LsOscCfg* = RECORD
      lsiEn*, lseEn*: INTEGER
    END;

  (* -- PLL -- *)

  PROCEDURE* ConfigPLL*(pllId: INTEGER; cfg: PLLcfg);
    VAR addr, val: INTEGER;
  BEGIN
    ASSERT(pllId IN PLL);
    addr := CFG.RCC_PLL1CFGR + (pllId * 4);
    SYSTEM.GET(addr, val);
    BFI(val, 18, cfg.ren);
    BFI(val, 17, cfg.qen);
    BFI(val, 16, cfg.pen);
    BFI(val, 11, 8, cfg.mdiv);
    BFI(val, 3, 2, cfg.range);
    BFI(val, 1, 0, cfg.src);
    SYSTEM.PUT(addr, val);
    addr := CFG.RCC_PLL1DIVR + (pllId * 8);
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
    addr := CFG.RCC_PLL1CFGR + (pllId * 4);
    SYSTEM.GET(addr, val);
    cfg.ren := BFX(val, 18);
    cfg.qen := BFX(val, 17);
    cfg.pen := BFX(val, 16);
    cfg.mdiv := BFX(val, 11, 8);
    cfg.range := BFX(val, 3, 2);
    cfg.src := BFX(val, 1, 0);
    addr := CFG.RCC_PLL1DIVR + (pllId * 8);
    SYSTEM.GET(addr, val);
    cfg.rdiv := BFX(val, 30, 24);
    cfg.qdiv := BFX(val, 22, 16);
    cfg.pdiv := BFX(val, 15, 9);
    cfg.ndiv := BFX(val, 8, 0)
  END GetPLLcfg;


  PROCEDURE* StartPLL*(pllId: INTEGER);
    VAR val: SET; en, lk, RCC_CR: INTEGER;
  BEGIN
    RCC_CR := CFG.RCC_CR;
    en := 24 + pllId * 2;
    lk := 25 + pllId * 2;
    SYSTEM.GET(RCC_CR, val);
    SYSTEM.PUT(RCC_CR, val + {en});
    REPEAT
      SYSTEM.GET(RCC_CR, val)
    UNTIL lk IN val
  END StartPLL;

  PROCEDURE* SetEPODboost*(div: INTEGER);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(CFG.RCC_PLL1CFGR, val);
    BFI(val, 15, 12, div);
    SYSTEM.PUT(CFG.RCC_PLL1CFGR, val)
  END SetEPODboost;

(*
  PROCEDURE* GetPLLsec*(pllId: INTEGER; VAR secCfg: SET);
  BEGIN
    secCfg := {LSL(1, pllId + CFG.RCC_SEC_PLL1_pos)}
  END GetPLLsec;
*)

  (* -- system clock -- *)

  PROCEDURE* ConfigSysClk*(sysClk: INTEGER);
    VAR val, RCC_CFGR1: INTEGER;
  BEGIN
    RCC_CFGR1 := CFG.RCC_CFGR1;
    SYSTEM.GET(RCC_CFGR1, val);
    BFI(val, 1, 0, sysClk);
    SYSTEM.PUT(RCC_CFGR1, val);
    REPEAT
      SYSTEM.GET(RCC_CFGR1, val)
    UNTIL BFX(val, 3, 2) = sysClk
  END ConfigSysClk;

(*
  PROCEDURE* GetSysClkSec*(VAR secCfg: SET);
  BEGIN
    secCfg := {CFG.RCC_SEC_SYSCLK_pos}
  END GetSysClkSec;
*)

  (* -- bus prescalers -- *)

  PROCEDURE* ConfigBusPresc*(cfg: BusPrescCfg);
    VAR val, RCC_CFGR2, RCC_CFGR3: INTEGER;
  BEGIN
    RCC_CFGR2 := CFG.RCC_CFGR2;
    RCC_CFGR3 := CFG.RCC_CFGR3;
    SYSTEM.GET(RCC_CFGR2, val);
    BFI(val, 10, 8, cfg.apb2Presc);
    BFI(val, 6, 4, cfg.apb1Presc);
    BFI(val, 3, 0, cfg.ahbPresc);
    SYSTEM.PUT(RCC_CFGR2, val);
    SYSTEM.GET(RCC_CFGR3, val);
    BFI(val, 6, 4, cfg.apb3Presc);
    SYSTEM.PUT(RCC_CFGR3, val)
  END ConfigBusPresc;


  PROCEDURE* GetBusPresc*(VAR cfg: BusPrescCfg);
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(CFG.RCC_CFGR2, val);
    cfg.apb2Presc := BFX(val, 10, 8);
    cfg.apb1Presc := BFX(val, 6, 4);
    cfg.ahbPresc := BFX(val, 3, 0);
    SYSTEM.GET(CFG.RCC_CFGR3, val);
    cfg.apb3Presc := BFX(val, 6, 4)
  END GetBusPresc;

(*
  PROCEDURE* GetBusPrescSec*(VAR secCfg: SET);
  BEGIN
    secCfg := {CFG.RCC_SEC_PRESC_pos}
  END GetBusPrescSec;
*)

  (* -- oscillators -- *)

  PROCEDURE* ConfigOsc*(cfg: OscCfg);
    CONST
      MaskRdy = {2, 5, 10, 13, 17};
      MaskEn2 = {0, 8}; MaskEn1 = {4, 12, 17};
    VAR oscMask, RCC_CR: INTEGER; val, rdyMask: SET;
  BEGIN
    RCC_CR := CFG.RCC_CR;
    oscMask := 0;
    BFI(oscMask, 0, cfg.msisEn);
    BFI(oscMask, 4, cfg.msikEn);
    BFI(oscMask, 8, cfg.hsiEn);
    BFI(oscMask, 12, cfg.hsi48En);
    BFI(oscMask, 16, cfg.hseEn);
    SYSTEM.GET(RCC_CR, val);
    SYSTEM.PUT(RCC_CR, val + BITS(oscMask));
    rdyMask := BITS(LSL(ORD(BITS(oscMask) * MaskEn1), 1));
    rdyMask := rdyMask + BITS(LSL(ORD(BITS(oscMask) * MaskEn2), 2));
    REPEAT
      SYSTEM.GET(RCC_CR, val)
    UNTIL val * MaskRdy = rdyMask
  END ConfigOsc;

(*
  PROCEDURE* GetOscSec*(cfg: OscCfg; VAR secCfg: SET);
  BEGIN
    secCfg := {};
    secCfg := secCfg + {LSL(ORD(BITS(cfg.msisEn) * {0}), CFG.RCC_SEC_MSI_pos)};
    secCfg := secCfg + {LSL(ORD(BITS(cfg.msikEn) * {0}), CFG.RCC_SEC_MSI_pos)};
    secCfg := secCfg + {LSL(ORD(BITS(cfg.hsiEn) * {0}), CFG.RCC_SEC_HSI_pos)};
    secCfg := secCfg + {LSL(ORD(BITS(cfg.hsi48En) * {0}), CFG.RCC_SEC_HSI48_pos)};
    secCfg := secCfg + {LSL(ORD(BITS(cfg.hseEn) * {0}), CFG.RCC_SEC_HSE_pos)}
  END GetOscSec;
*)

  (* -- LS oscillators -- *)

  PROCEDURE* ConfigLsOsc*(cfg: LsOscCfg);
  (* requires PWR to be clocked *)
    CONST LsMaskRdy = {1, 27};
    VAR oscMask, RCC_BDCR, PWR_DBPR: INTEGER; val, rdyMask: SET;
  BEGIN
    RCC_BDCR := CFG.RCC_BDCR;
    PWR_DBPR := CFG.PWR_DBPR;
    oscMask := 0;
    BFI(oscMask, 0, cfg.lseEn);
    BFI(oscMask, 26, cfg.lsiEn);
    IF oscMask # 0 THEN
      SYSTEM.PUT(PWR_DBPR, {0}); (* write enable RCC_BDCR *)
      SYSTEM.GET(RCC_BDCR, val);
      SYSTEM.PUT(RCC_BDCR, val + BITS(oscMask));
      SYSTEM.PUT(PWR_DBPR, {}); (* write disable RCC_BDCR *)
      rdyMask := BITS(LSL(oscMask, 1));
      REPEAT
        SYSTEM.GET(RCC_BDCR, val)
      UNTIL val * LsMaskRdy = rdyMask
    END
  END ConfigLsOsc;

(*
  PROCEDURE* GetLsOscSec*(cfg: LsOscCfg; VAR secCfg: SET);
  BEGIN
    secCfg := {};
    secCfg := secCfg + {LSL(ORD(BITS(cfg.lseEn) * {0}), CFG.RCC_SEC_LSE_pos)};
    secCfg := secCfg + {LSL(ORD(BITS(cfg.lsiEn) * {0}), CFG.RCC_SEC_LSI_pos)}
  END GetLsOscSec;
*)


END CLK.

