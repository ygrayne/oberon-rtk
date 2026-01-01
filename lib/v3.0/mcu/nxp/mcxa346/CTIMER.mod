MODULE CTIMER;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  CTIMER counter timer device driver.
  Basic timer functionality only for now.
  --
  Type: MCU
  --
  MCU: MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors, RST, CLK;

  CONST
    CTIMER0* = 0;
    CTIMER1* = 1;
    CTIMER2* = 2;
    CTIMER3* = 3;
    CTIMER4* = 4;
    CTIMER = {CTIMER0 .. CTIMER4};

    (* functional clocks *)
    CLK_FRO_LF_DIV* = 0;
    CLK_FRO_HF_GATED* = 1;
    CLK_CLKIN* = 3;
    CLK_CLK16K* = 4;
    CLK_CLK1M* = 5;
    CLK_SPLL_DIV* = 6;
    CLK_NONE* = 7; (* reset *)

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      ctimerNo: INTEGER;
      devNo, clkSelReg, clkDivReg: INTEGER;
      TCR, TC: INTEGER;
      PR, PC: INTEGER;
    END;

    DeviceCfg* = RECORD
      clkSel*: INTEGER;
      clkDiv*: INTEGER;
      presc*: INTEGER;
    END;


  PROCEDURE* Init*(dev: Device; ctimNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(ctimNo IN CTIMER, Errors.ProgError);
    base := MCU.CTIMER0_BASE + (ctimNo * MCU.CTIMER_Offset);
    dev.ctimerNo := ctimNo;
    dev.devNo := MCU.DEV_CTIMER0 + ctimNo;
    dev.clkSelReg := MCU.CLKSEL_CTIMER0 + (ctimNo * MCU.CLK_CTIMER_Offset);
    dev.clkDivReg := MCU.CLKDIV_CTIMER0 + (ctimNo * MCU.CLK_CTIMER_Offset);
    dev.TCR := base + MCU.CTIMER_TCR_Offset;
    dev.TC := base + MCU.CTIMER_TC_Offset;
    dev.PR := base + MCU.CTIMER_PR_Offset;
    dev.PC := base + MCU.CTIMER_PC_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg);
  BEGIN
    (* release reset on CTIMER device, set clock *)
    RST.ReleaseReset(dev.devNo);
    CLK.ConfigDevClock(cfg.clkSel, cfg.clkDiv, dev.clkSelReg, dev.clkDivReg);
    CLK.EnableBusClock(dev.devNo);

    (* reset *)
    SYSTEM.PUT(dev.TCR, 0);

    (* set prescaler *)
    SYSTEM.PUT(dev.PR, cfg.presc)
  END Configure;


  PROCEDURE* Enable*(dev: Device);
    CONST TCR_CEN = 0;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(dev.TCR, val);
    SYSTEM.PUT(dev.TCR, val + {TCR_CEN})
  END Enable;


  PROCEDURE* GetCount*(dev: Device; VAR cnt: INTEGER);
  BEGIN
    SYSTEM.GET(dev.TC, cnt)
  END GetCount;

END CTIMER.
