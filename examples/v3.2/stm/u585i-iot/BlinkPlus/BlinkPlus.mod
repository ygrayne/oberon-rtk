MODULE BlinkPlus;
(**
  Oberon RTK Framework v3.1
  --
  Example/test program, multi-threaded, kernel-v1
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2024-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, Out, Cores, Errors, LED, TIM, Clocks;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    HeartbeatPeriod = 500 DIV MillisecsPerTick;  (* 500 ms *)
    Period0 = 980 DIV MillisecsPerTick;  (* 980 ms *)
    Period1 = 1440 DIV MillisecsPerTick; (* 1440 ms *)

    TimerFreq = Clocks.PCLK1_FRQ;

  VAR
    t0, t1, t2: Kernel.Thread;
    tid0, tid1, tid2: INTEGER;
    timer: TIM.Device;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0)
  END writeThreadInfo;


  PROCEDURE heartbeat;
  BEGIN
    LED.Set({LED.Green});
    Kernel.SetPeriod(HeartbeatPeriod, 0);
    REPEAT
      LED.Toggle({LED.Green});
      Kernel.Next
    UNTIL FALSE
  END heartbeat;


  PROCEDURE periodic;
    VAR tid, cid, before, now: INTEGER;
  BEGIN
    cid := Cores.CoreId();
    tid := Kernel.Tid();
    IF tid = tid1 THEN
      Kernel.SetPeriod(Period0, 0)
    ELSE
      Kernel.SetPeriod(Period1, 0)
    END;
    TIM.GetCount(timer, before);
    REPEAT
      Kernel.Next;
      TIM.GetCount(timer, now);
      writeThreadInfo(tid, cid); Out.Int(now - before, 12); Out.Ln;
      before := now
    UNTIL FALSE
  END periodic;


  PROCEDURE startTimer(timerNo: INTEGER);
    CONST ARR32 = 0FFF13D7FH; Presc = (TimerFreq DIV 1000000) - 1;
    VAR cfg: TIM.DeviceCfg;
  BEGIN
    NEW(timer); ASSERT(timer # NIL, Errors.HeapOverflow);
    TIM.Init(timer, timerNo);
    cfg.presc :=  Presc; (* microseconds *)
    cfg.reload := ARR32;
    TIM.Configure(timer, cfg);
    TIM.Enable(timer)
  END startTimer;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    (* heartbeat blinker thread *)
    Kernel.Allocate(heartbeat, ThreadStackSize, t0, tid0, res);
    ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t0);
    (* two worker threads, running the same code *)
    Kernel.Allocate(periodic, ThreadStackSize, t1, tid1, res);
    ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t1);
    Kernel.Allocate(periodic, ThreadStackSize, t2, tid2, res);
    ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.Enable(t2);
    Out.String("start"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  LED.Config;
  startTimer(TIM.TIM2);
  run
END BlinkPlus.
