MODULE TIM;
(**
  Oberon RTK Framework
  Version: v3.1
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
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV3, DEF := TIMdef, RST, Errors;

  CONST
    TIM = {DEF.TIM1 .. DEF.TIM17};

    CR1_CEN = 0;
    EGR_UG = 0;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      timId*: INTEGER;
      bcEnReg, bcEnPos: INTEGER; (* bus clock enable *)
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
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(timId IN TIM, Errors.PreCond);
    dev.timId := timId;
    CASE timId OF
      DEF.TIM1:
        base := CFG.TIM1_BASE;
        dev.bcEnReg := CFG.TIM1_BC_reg; dev.bcEnPos := CFG.TIM1_BC_pos;
    | DEF.TIM2:
        base := CFG.TIM2_BASE;
        dev.bcEnReg := CFG.TIM2_BC_reg; dev.bcEnPos := CFG.TIM2_BC_pos;
    | DEF.TIM3:
        base := CFG.TIM3_BASE;
        dev.bcEnReg := CFG.TIM3_BC_reg; dev.bcEnPos := CFG.TIM3_BC_pos;
    | DEF.TIM4:
        base := CFG.TIM4_BASE;
        dev.bcEnReg := CFG.TIM4_BC_reg; dev.bcEnPos := CFG.TIM4_BC_pos;
    | DEF.TIM5:
        base := CFG.TIM5_BASE;
        dev.bcEnReg := CFG.TIM5_BC_reg; dev.bcEnPos := CFG.TIM5_BC_pos;
    | DEF.TIM6:
        base := CFG.TIM6_BASE;
        dev.bcEnReg := CFG.TIM6_BC_reg; dev.bcEnPos := CFG.TIM6_BC_pos;
    | DEF.TIM7:
        base := CFG.TIM7_BASE;
        dev.bcEnReg := CFG.TIM7_BC_reg; dev.bcEnPos := CFG.TIM7_BC_pos;
    | DEF.TIM8:
        base := CFG.TIM8_BASE;
        dev.bcEnReg := CFG.TIM8_BC_reg; dev.bcEnPos := CFG.TIM8_BC_pos;
    | DEF.TIM15:
        base := CFG.TIM15_BASE;
        dev.bcEnReg := CFG.TIM15_BC_reg; dev.bcEnPos := CFG.TIM15_BC_pos;
    | DEF.TIM16:
        base := CFG.TIM16_BASE;
        dev.bcEnReg := CFG.TIM16_BC_reg; dev.bcEnPos := CFG.TIM16_BC_pos;
    | DEF.TIM17:
        base := CFG.TIM17_BASE;
        dev.bcEnReg := CFG.TIM17_BC_reg; dev.bcEnPos := CFG.TIM17_BC_pos;
    END;
    dev.CR1 := base + CFG.TIM_CR1_Offset;
    dev.CR2 := base + CFG.TIM_CR2_Offset;
    dev.DIER := base + CFG.TIM_DIER_Offset;
    dev.SR := base + CFG.TIM_SR_Offset;
    dev.EGR := base + CFG.TIM_EGR_Offset;
    dev.CNT := base + CFG.TIM_CNT_Offset;
    dev.PSC := base + CFG.TIM_PSC_Offset;
    dev.ARR := base + CFG.TIM_ARR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg);
  BEGIN
    RST.EnableBusClock(dev.bcEnReg, dev.bcEnPos);
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


  PROCEDURE GetDevSec*(timId: INTEGER; VAR reg, pos: INTEGER);
  BEGIN
    ASSERT(timId IN TIM, Errors.PreCond);
    CASE timId OF
      DEF.TIM1: reg := CFG.TIM1_SEC_reg; pos := CFG.TIM1_SEC_pos
    | DEF.TIM2: reg := CFG.TIM2_SEC_reg; pos := CFG.TIM2_SEC_pos
    | DEF.TIM3: reg := CFG.TIM3_SEC_reg; pos := CFG.TIM3_SEC_pos
    | DEF.TIM4: reg := CFG.TIM4_SEC_reg; pos := CFG.TIM4_SEC_pos
    | DEF.TIM5: reg := CFG.TIM5_SEC_reg; pos := CFG.TIM5_SEC_pos
    | DEF.TIM6: reg := CFG.TIM6_SEC_reg; pos := CFG.TIM6_SEC_pos
    | DEF.TIM7: reg := CFG.TIM7_SEC_reg; pos := CFG.TIM7_SEC_pos
    | DEF.TIM8: reg := CFG.TIM8_SEC_reg; pos := CFG.TIM8_SEC_pos
    | DEF.TIM15: reg := CFG.TIM15_SEC_reg; pos := CFG.TIM15_SEC_pos
    | DEF.TIM16: reg := CFG.TIM16_SEC_reg; pos := CFG.TIM16_SEC_pos
    | DEF.TIM17: reg := CFG.TIM17_SEC_reg; pos := CFG.TIM17_SEC_pos
    END
  END GetDevSec;

END TIM.
