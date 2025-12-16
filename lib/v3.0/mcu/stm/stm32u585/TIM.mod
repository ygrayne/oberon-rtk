MODULE TIM;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Basic device driver for:
  TIM1, TIM8: advanced
  TIM2, TIM3, TIM4, TIM5: general purpose, 32 bits
  TIM6, TIM7: basic
  TIM15: general purpose
  TIM16, TIM17: general purpose
  --
  Note: advanced functionality for more capable timers is not yet implemented.
  --
  Type: MCU
  --
  MCU: STM32U585AI
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
    TIM15* = 8;
    TIM16* = 9;
    TIM17* = 10;
    TIMs* = {TIM1 .. TIM17};

    CR1_CEN = 0;
    EGR_UG = 0;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      timId: INTEGER;
      devNo: INTEGER;
      CR1, CR2: INTEGER;
      DIER, SR, EGR: INTEGER;
      CNT, PSC, ARR: INTEGER
    END;

    DeviceCfg* = RECORD
      presc*: INTEGER;
      reload*: INTEGER
    END;


  PROCEDURE* Init*(dev: Device; timId: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.HeapOverflow);
    ASSERT(timId IN TIMs, Errors.ProgError);
    dev.timId := timId;
    IF timId = TIM1 THEN
      base := MCU.TIM1_BASE;
      dev.devNo := MCU.DEV_TIM1
    ELSIF timId = TIM8 THEN
      base := MCU.TIM8_BASE;
      dev.devNo := MCU.DEV_TIM8
    ELSIF timId IN {TIM15, TIM16, TIM17} THEN
      base := MCU.TIM15_BASE + ((timId - TIM15) * MCU.TIM_Offset);
      dev.devNo := MCU.DEV_TIM15 + (timId - TIM15)
    ELSE
      base := MCU.TIM2_BASE + ((timId - TIM2) * MCU.TIM_Offset);
      dev.devNo := MCU.DEV_TIM2 + (timId - TIM2)
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
