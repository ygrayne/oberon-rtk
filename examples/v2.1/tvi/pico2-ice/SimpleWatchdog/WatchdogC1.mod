MODULE WatchdogC1;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, dual-core
  Simple dual-core watchdog
  See https://oberon-rtk.org/examples/v2/watchdog
  --
  Core 0 program: WatchdogC0
  --
  MCU: RP2350B
  Board: Pico2-ICE
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, Main, Kernel, Out, MultiCore, Errors, MCU := MCU2;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    T0period = 100;
    T1period = 2;

    Core1OkFlag = 0;

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
    Kernel.SetPeriod(T0period, T0period);
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 5;
    Out.Ln; Out.String("*** reset ***"); Out.Ln;
    REPEAT
      writeThreadInfo(tid, cid);
      Out.String(" core 1 watchdog in "); Out.Int(cnt, 0); Out.Ln;
      IF cnt = 0 THEN
        REPEAT UNTIL FALSE
      END;
      DEC(cnt);
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
  BEGIN
    Kernel.SetPeriod(T1period, T1period);
    REPEAT
      SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0 + MCU.ASET, {Core1OkFlag});
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE Run*;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END Run;

BEGIN
  (* Run *)
END WatchdogC1.
