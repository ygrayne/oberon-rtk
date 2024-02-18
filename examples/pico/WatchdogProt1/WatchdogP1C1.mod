MODULE WatchdogP1C1;
(**
  Oberon RTK Framework
  Example program, multi-threaded, dual-core
  Watchdog prototype
  Description: https://oberon-rtk.org/examples/watchdogprot1/
  Core 0 program: WatchdogP1C0
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, Out, MultiCore, SysMsg, Errors, GPIO, LED, Watchdog, MCU := MCU2;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE t0c;
    VAR tid, cid, cnt: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 3;
    Out.String("*** reset ***"); Out.Ln;
    REPEAT
      writeThreadInfo(tid, cid);
      Out.String(" watchdog in "); Out.Int(cnt, 0); Out.Ln;
      IF cnt = 0 THEN
        REPEAT UNTIL FALSE
      END;
      DEC(cnt);
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR tid, cid: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    REPEAT
      IF SysMsg.SendAvailable() THEN
        SysMsg.Send(SysMsg.MsgWatchdog, SysMsg.RecSystem, 0, 0)
      END;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE Run*;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.SetPeriod(t0, 1000, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.SetPeriod(t1, 20, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END Run;

BEGIN
  (* Run *)
END WatchdogP1C1.
