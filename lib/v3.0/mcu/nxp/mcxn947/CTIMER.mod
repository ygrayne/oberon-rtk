MODULE CTIMER;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  CTIMER counter timer device driver.
  Basic timer functionality only for now.
  --
  MCU: MCXN947
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors, CLK;

  CONST
    CTIMER0* = 0;
    CTIMER1* = 1;
    CTIMER2* = 2;
    CTIMER3* = 3;
    CTIMER4* = 4;
    CTIMER = {CTIMER0 .. CTIMER4};

    (* functional clocks *)
    CLK_CLK1M* = 0;
    CLK_APLL* = 1; (* pll0 *)
    CLK_SPLL* = 2; (* pll1 *)
    CLK_CLKHF* = 3;
    CLK_CLK12M* = 4;
    CLK_SAI0_MCLK*  = 5;
    CLK_CLK16K* = 6;
    CLK_SAI1_MCLK* = 8;
    CLK_SAI0_TX* = 9;
    CLK_SAI0_RX* = 10;
    CLK_SAI1_TX* = 11;
    CLK_SAI1_RX* = 12;
    CLK_NONE* = 15; (* reset *)


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
    CASE ctimNo OF
      CTIMER0, CTIMER1: dev.devNo := MCU.DEV_CTIMER0 + ctimNo
    | CTIMER2: dev.devNo := MCU.DEV_CTIMER2
    | CTIMER3, CTIMER4: dev.devNo := MCU.DEV_CTIMER3 + ctimNo - 3
    END;
    dev.clkSelReg := MCU.CLKSEL_CTIMER0 + (ctimNo * MCU.CLK_CTIMER_Offset);
    dev.clkDivReg := MCU.CLKDIV_CTIMER0 + (ctimNo * MCU.CLK_CTIMER_Offset);
    dev.TCR := base + MCU.CTIMER_TCR_Offset;
    dev.TC := base + MCU.CTIMER_TC_Offset;
    dev.PR := base + MCU.CTIMER_PR_Offset;
    dev.PC := base + MCU.CTIMER_PC_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg);
  BEGIN
    (* set clock, enable clock *)
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
