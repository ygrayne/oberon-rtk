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
  MCU: STM32U585AI
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, DEV := TIM_DEV, RST, Errors;

  CONST
    (* handles *)
    (* do  not assume any specific value for these handles *)
    (* advanced *)
    TIM1* = DEV.TIM1;
    TIM8* = DEV.TIM8;
    (* general purpose 32 bit *)
    TIM2* = DEV.TIM2;
    TIM3* = DEV.TIM3;
    TIM4* = DEV.TIM4;
    TIM5* = DEV.TIM5;
    (* basic *)
    TIM6* = DEV.TIM6;
    TIM7* = DEV.TIM7;
    (* general purpose 16 bit *)
    TIM15* = DEV.TIM15;
    TIM16* = DEV.TIM16;
    TIM17* = DEV.TIM17;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      timId*: INTEGER;
      bcEnReg, bcEnPos: INTEGER; (* bus clock enable *)
      rstReg, rstPos: INTEGER; (* reset *)
      smReg, smPos: INTEGER; (* clock sleep mode *)
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
    ASSERT(timId IN DEV.TIM_all, Errors.PreCond);
    dev.timId := timId;
    IF timId IN DEV.TIM_adv THEN
      CASE timId OF
        DEV.TIM1:
          base := DEV.TIM1_BASE;
          dev.bcEnReg := DEV.TIM1_BC_reg; dev.bcEnPos := DEV.TIM1_BC_pos;
          dev.rstReg := DEV.TIM1_RST_reg; dev.rstPos := DEV.TIM1_RST_pos;
          dev.smReg := DEV.TIM1_SM_reg; dev.smPos := DEV.TIM1_SM_pos
      | DEV.TIM8:
          base := DEV.TIM8_BASE;
          dev.bcEnReg := DEV.TIM8_BC_reg; dev.bcEnPos := DEV.TIM8_BC_pos;
          dev.rstReg := DEV.TIM8_RST_reg; dev.rstPos := DEV.TIM8_RST_pos;
          dev.smReg := DEV.TIM8_SM_reg; dev.smPos := DEV.TIM8_SM_pos
      END
    ELSIF timId IN DEV.TIM_gp0 THEN
      CASE timId OF
        DEV.TIM2:
          base := DEV.TIM2_BASE;
          dev.bcEnReg := DEV.TIM2_BC_reg; dev.bcEnPos := DEV.TIM2_BC_pos;
          dev.rstReg := DEV.TIM2_RST_reg; dev.rstPos := DEV.TIM2_RST_pos;
          dev.smReg := DEV.TIM2_SM_reg; dev.smPos := DEV.TIM2_SM_pos
      | DEV.TIM3:
          base := DEV.TIM3_BASE;
          dev.bcEnReg := DEV.TIM3_BC_reg; dev.bcEnPos := DEV.TIM3_BC_pos;
          dev.rstReg := DEV.TIM3_RST_reg; dev.rstPos := DEV.TIM3_RST_pos;
          dev.smReg := DEV.TIM3_SM_reg; dev.smPos := DEV.TIM3_SM_pos
      | DEV.TIM4:
          base := DEV.TIM4_BASE;
          dev.bcEnReg := DEV.TIM4_BC_reg; dev.bcEnPos := DEV.TIM4_BC_pos;
          dev.rstReg := DEV.TIM4_RST_reg; dev.rstPos := DEV.TIM4_RST_pos;
          dev.smReg := DEV.TIM4_SM_reg; dev.smPos := DEV.TIM4_SM_pos
      | DEV.TIM5:
          base := DEV.TIM5_BASE;
          dev.bcEnReg := DEV.TIM5_BC_reg; dev.bcEnPos := DEV.TIM5_BC_pos;
          dev.rstReg := DEV.TIM5_RST_reg; dev.rstPos := DEV.TIM5_RST_pos;
          dev.smReg := DEV.TIM5_SM_reg; dev.smPos := DEV.TIM5_SM_pos
      END
    ELSIF timId IN DEV.TIM_basic THEN
      CASE timId OF
        DEV.TIM6:
          base := DEV.TIM6_BASE;
          dev.bcEnReg := DEV.TIM6_BC_reg; dev.bcEnPos := DEV.TIM6_BC_pos;
          dev.rstReg := DEV.TIM6_RST_reg; dev.rstPos := DEV.TIM6_RST_pos;
          dev.smReg := DEV.TIM6_SM_reg; dev.smPos := DEV.TIM6_SM_pos
      | DEV.TIM7:
          base := DEV.TIM7_BASE;
          dev.bcEnReg := DEV.TIM7_BC_reg; dev.bcEnPos := DEV.TIM7_BC_pos;
          dev.rstReg := DEV.TIM7_RST_reg; dev.rstPos := DEV.TIM7_RST_pos;
          dev.smReg := DEV.TIM7_SM_reg; dev.smPos := DEV.TIM7_SM_pos
      END
    ELSE
      CASE timId OF
        DEV.TIM15:
          base := DEV.TIM15_BASE;
          dev.bcEnReg := DEV.TIM15_BC_reg; dev.bcEnPos := DEV.TIM15_BC_pos;
          dev.rstReg := DEV.TIM15_RST_reg; dev.rstPos := DEV.TIM15_RST_pos;
          dev.smReg := DEV.TIM15_SM_reg; dev.smPos := DEV.TIM15_SM_pos
      | DEV.TIM16:
          base := DEV.TIM16_BASE;
          dev.bcEnReg := DEV.TIM16_BC_reg; dev.bcEnPos := DEV.TIM16_BC_pos;
          dev.rstReg := DEV.TIM16_RST_reg; dev.rstPos := DEV.TIM16_RST_pos;
          dev.smReg := DEV.TIM16_SM_reg; dev.smPos := DEV.TIM16_SM_pos
      | DEV.TIM17:
          base := DEV.TIM17_BASE;
          dev.bcEnReg := DEV.TIM17_BC_reg; dev.bcEnPos := DEV.TIM17_BC_pos;
          dev.rstReg := DEV.TIM17_RST_reg; dev.rstPos := DEV.TIM17_RST_pos;
          dev.smReg := DEV.TIM17_SM_reg; dev.smPos := DEV.TIM17_SM_pos
      END
    END;
    dev.CR1 := base + DEV.TIM_CR1_Offset;
    dev.CR2 := base + DEV.TIM_CR2_Offset;
    dev.DIER := base + DEV.TIM_DIER_Offset;
    dev.SR := base + DEV.TIM_SR_Offset;
    dev.EGR := base + DEV.TIM_EGR_Offset;
    dev.CNT := base + DEV.TIM_CNT_Offset;
    dev.PSC := base + DEV.TIM_PSC_Offset;
    dev.ARR := base + DEV.TIM_ARR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg);
  BEGIN
    RST.EnableBusClock(dev.bcEnReg, dev.bcEnPos);
    SYSTEM.PUT(dev.PSC, cfg.presc);
    SYSTEM.PUT(dev.ARR, cfg.reload);
    (* clear counter and prescale counter/issue update event *)
    (* prescaler value in dev.PSC is untouched *)
    SYSTEM.PUT(dev.EGR, {0})
  END Configure;


  PROCEDURE* Enable*(dev: Device);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(dev.CR1, val);
    SYSTEM.PUT(dev.CR1, val + {0})
  END Enable;


  PROCEDURE* Clear*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.EGR, {0})
  END Clear;


  PROCEDURE* Disable*(dev: Device);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(dev.CR1, val);
    SYSTEM.PUT(dev.CR1, val - {0})
  END Disable;


  PROCEDURE GetCount*(dev: Device; VAR cnt: INTEGER);
  BEGIN
    SYSTEM.GET(dev.CNT, cnt)
  END GetCount;


  PROCEDURE GetDevSec*(timId: INTEGER; VAR reg, pos: INTEGER);
  BEGIN
    ASSERT(timId IN DEV.TIM_all, Errors.PreCond);
    IF timId IN DEV.TIM_adv THEN
      CASE timId OF
        DEV.TIM1: reg := DEV.TIM1_SEC_reg; pos := DEV.TIM1_SEC_pos
      | DEV.TIM8: reg := DEV.TIM8_SEC_reg; pos := DEV.TIM8_SEC_pos
      END
    ELSIF timId IN DEV.TIM_gp0 THEN
      CASE timId OF
        DEV.TIM2: reg := DEV.TIM2_SEC_reg; pos := DEV.TIM2_SEC_pos
      | DEV.TIM3: reg := DEV.TIM3_SEC_reg; pos := DEV.TIM3_SEC_pos
      | DEV.TIM4: reg := DEV.TIM4_SEC_reg; pos := DEV.TIM4_SEC_pos
      | DEV.TIM5: reg := DEV.TIM5_SEC_reg; pos := DEV.TIM5_SEC_pos
      END
    ELSIF timId IN DEV.TIM_basic THEN
      CASE timId OF
        DEV.TIM6: reg := DEV.TIM6_SEC_reg; pos := DEV.TIM6_SEC_pos
      | DEV.TIM7: reg := DEV.TIM7_SEC_reg; pos := DEV.TIM7_SEC_pos
      END
    ELSE
      CASE timId OF
        DEV.TIM15: reg := DEV.TIM15_SEC_reg; pos := DEV.TIM15_SEC_pos
      | DEV.TIM16: reg := DEV.TIM16_SEC_reg; pos := DEV.TIM16_SEC_pos
      | DEV.TIM17: reg := DEV.TIM17_SEC_reg; pos := DEV.TIM17_SEC_pos
      END
    END
  END GetDevSec;

END TIM.
