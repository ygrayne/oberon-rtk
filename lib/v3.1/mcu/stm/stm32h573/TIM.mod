MODULE TIM;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Basic device driver for:
  TIM1, TIM8: advanced
  TIM2, TIM3, TIM4, TIM5: general purpose, 32 bits
  TIM6, TIM7: basic
  TIM12: general purpose
  TIM13, TIM4: general purpose
  TIM15: general purpose
  TIM16, TIM17: general purpose
  --
  Note: Advanced functionality for more capable timers is not yet implemented.
  --
  Type: MCU
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, CLK, Errors;

  CONST
    TIM1* = 0;
    TIM2* = 1;
    TIM3* = 2;
    TIM4* = 3;
    TIM5* = 4;
    TIM6* = 5;
    TIM7* = 6;
    TIM8* = 7;
    TIM12* = 8;
    TIM13* = 9;
    TIM14* = 10;
    TIM15* = 11;
    TIM16* = 12;
    TIM17* = 13;
    TIMs* = {TIM1 .. TIM17};

    CR1_CEN = 0;
    EGR_UG = 0;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      timId*: INTEGER;
      devNo: INTEGER;
      CR1, CR2: INTEGER;
      DIER, SR, EGR: INTEGER;
      CNT*, PSC, ARR: INTEGER
    END;

    DeviceCfg* = RECORD
      presc*: INTEGER;
      reload*: INTEGER
    END;


  PROCEDURE* Init*(dev: Device; timId: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.ProgError);
    ASSERT(timId IN TIMs, Errors.ProgError);
    dev.timId := timId;
    CASE timId OF
      TIM1: base := MCU.TIM1_BASE; dev.devNo := MCU.DEV_TIM1
    | TIM2: base := MCU.TIM2_BASE; dev.devNo := MCU.DEV_TIM2
    | TIM3: base := MCU.TIM3_BASE; dev.devNo := MCU.DEV_TIM3
    | TIM4: base := MCU.TIM4_BASE; dev.devNo := MCU.DEV_TIM4
    | TIM5: base := MCU.TIM5_BASE; dev.devNo := MCU.DEV_TIM5
    | TIM6: base := MCU.TIM6_BASE; dev.devNo := MCU.DEV_TIM6
    | TIM7: base := MCU.TIM7_BASE; dev.devNo := MCU.DEV_TIM7
    | TIM8: base := MCU.TIM8_BASE; dev.devNo := MCU.DEV_TIM8
    | TIM12: base := MCU.TIM12_BASE; dev.devNo := MCU.DEV_TIM12
    | TIM13: base := MCU.TIM12_BASE; dev.devNo := MCU.DEV_TIM13
    | TIM14: base := MCU.TIM14_BASE; dev.devNo := MCU.DEV_TIM14
    | TIM15: base := MCU.TIM15_BASE; dev.devNo := MCU.DEV_TIM15
    | TIM16: base := MCU.TIM16_BASE; dev.devNo := MCU.DEV_TIM16
    | TIM17: base := MCU.TIM17_BASE; dev.devNo := MCU.DEV_TIM17
    END;
    dev.CR1 := base + MCU.TIM_CR1_Offset;
    dev.CR2 := base + MCU.TIM_CR2_Offset;
    dev.DIER := base + MCU.TIM_DIER_Offset;
    dev.SR := base + MCU.TIM_SR_Offset;
    dev.EGR := base + MCU.TIM_EGR_Offset;
    dev.CNT := base + MCU.TIM_CNT_Offset;
    dev.PSC := base + MCU.TIM_PSC_Offset;
    dev.ARR := base + MCU.TIM_ARR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg);
  BEGIN
    ASSERT(dev # NIL, Errors.ProgError);
    CLK.EnableBusClock(dev.devNo);
    SYSTEM.PUT(dev.PSC, cfg.presc);
    SYSTEM.PUT(dev.ARR, cfg.reload);
    (* clear counter and prescale counter/issue update event *)
    (* prescaler value in dev.PSC is untouched *)
    SYSTEM.PUT(dev.EGR, {EGR_UG})
  END Configure;


  PROCEDURE* Enable*(dev: Device);
    VAR val: SET;
  BEGIN
    ASSERT(dev # NIL, Errors.ProgError);
    SYSTEM.GET(dev.CR1, val);
    SYSTEM.PUT(dev.CR1, val + {CR1_CEN})
  END Enable;


  PROCEDURE* Clear*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.EGR, {EGR_UG})
  END Clear;


  PROCEDURE* Disable*(dev: Device);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(dev.CR1, val);
    SYSTEM.PUT(dev.CR1, val - {CR1_CEN})
  END Disable;


  PROCEDURE GetCount*(dev: Device; VAR cnt: INTEGER);
  BEGIN
    SYSTEM.GET(dev.CNT, cnt)
  END GetCount;

END TIM.
