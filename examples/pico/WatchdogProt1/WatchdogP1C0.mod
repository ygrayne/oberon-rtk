MODULE WatchdogP1C0;
(**
  Oberon RTK Framework
  Example program, multi-threaded, dual-core
  Watchdog prototype/proof of concept
  Description: https://oberon-rtk.org/examples/watchdogprot1/
  Core 1 program: WatchdogP1C1
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, Out, MultiCore, SysMsg, Memory, Errors, GPIO, LED, Watchdog, MCU := MCU2, CoreOne := WatchdogP1C1;

  CONST
    Core1 = 1;
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

  VAR
    t0, t1, t2: Kernel.Thread;
    tid0, tid1, tid2: INTEGER;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE t0c;
  BEGIN
    GPIO.Set({LED.Green});
    REPEAT
      GPIO.Toggle({LED.Green});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR tid, cid, cnt: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 3;
    Out.String("*** reset ***"); Out.Ln;
    REPEAT
      writeThreadInfo(tid, cid);
      Out.String(" waiting for core 1 watchdog trigger"); Out.Int(cnt, 3); Out.Ln;
      (*
      Out.String(" watchdog in "); Out.Int(cnt, 0); Out.Ln;
      IF cnt = 0 THEN
        REPEAT UNTIL FALSE
      END;
      *)
      DEC(cnt);
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE t2c;
    CONST Core0Failed = 3;
    VAR tid, cid, core0missing: INTEGER; msgType, toTh, fromTh, msgData: BYTE;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    core0missing := 0;
    REPEAT
      IF SysMsg.ReceiveAvailable() THEN
        SysMsg.Receive(msgType, toTh, fromTh, msgData);
        core0missing := 0
      ELSE
        INC(core0missing)
      END;
      IF core0missing = Core0Failed THEN
        Watchdog.Trigger
      END;
      Watchdog.Reload;
      Kernel.Next
    UNTIL FALSE
  END t2c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    MultiCore.InitCoreOne(CoreOne.Run, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);

    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Errors.Config);
    Kernel.SetPeriod(t0, 500, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Errors.Config);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Allocate(t2c, ThreadStackSize, t2, tid2, res); ASSERT(res = Kernel.NoError, Errors.Config);
    Kernel.SetPeriod(t2, 20, 0); Kernel.Enable(t2);

    Watchdog.Init;
    Watchdog.SetTime(100);
    Watchdog.SetPowerOnResets(MCU.PSM_ALL - {MCU.PSM_ROSC, MCU.PSM_XOSC});
    Watchdog.Enable;

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END WatchdogP1C0.

