MODULE CounterTimers;
(**
  Oberon RTK Framework v2
  --
  Counter timers CTIMER.
  Basic timer functionality only for now.
  --
  MCU: MCX-A346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors, StartUp, ClockCtrl;

  CONST
    CTIMER0* = 0;
    CTIMER1* = 1;
    CTIMER2* = 2;
    CTIMER3* = 3;
    CTIMER4* = 4;
    CounterTimers = {CTIMER0 .. CTIMER4};

    (* TCR bits and values *)
    TCR_CEN = 0;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      ctimerNo: INTEGER;
      devNo, clkNo: INTEGER;
      TCR, TC: INTEGER;
      PR, PC: INTEGER;
    END;


  PROCEDURE Init*(dev: Device; ctimNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(ctimNo IN CounterTimers, Errors.ProgError);
    base := MCU.CTIMER0_BASE + (ctimNo * MCU.CTIMER_Offset);
    dev.ctimerNo := ctimNo;
    dev.devNo := MCU.DEV_CTIMER0 + ctimNo;
    dev.clkNo := MCU.CLK_CTIMER0 + ctimNo;
    dev.TCR := base + MCU.CTIMER_TCR_Offset;
    dev.TC := base + MCU.CTIMER_TC_Offset;
    dev.PR := base + MCU.CTIMER_PR_Offset;
    dev.PC := base + MCU.CTIMER_PC_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; clkSel, clkDiv, pre: INTEGER);
  BEGIN
    (* release reset on CTIMER device, set clock *)
    StartUp.ReleaseReset(dev.devNo);
    ClockCtrl.ConfigDevClock(dev.clkNo, clkSel, clkDiv);
    StartUp.EnableClock(dev.devNo);

    (* reset cfg *)
    SYSTEM.PUT(dev.TCR, 0);

    (* set prescaler *)
    SYSTEM.PUT(dev.PR, pre)
  END Configure;


  PROCEDURE Enable*(dev: Device);
    VAR val: SET;
  BEGIN
    SYSTEM.GET(dev.TCR, val);
    SYSTEM.PUT(dev.TCR, val + {TCR_CEN})
  END Enable;


  PROCEDURE GetCount*(dev: Device; VAR cnt: INTEGER);
  BEGIN
    SYSTEM.GET(dev.TC, cnt)
  END GetCount;


END CounterTimers.
