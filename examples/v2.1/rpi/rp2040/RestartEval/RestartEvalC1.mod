MODULE RestartEvalC1;
(**
  Oberon RTK Framework v2.x
  --
  Example program, multi-threaded, multi-core
  Evaluate different restart options and conditions.
  Description: https://oberon-rtk.org/examples/v2.1/restarteval/
  --
  Core 0 program: RestartEvalC0
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Main, Kernel,MultiCore, Out;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;
    ThreadOnePeriod = 100;


  VAR
    t1: Kernel.Thread;
    tid1: INTEGER;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0)
  END writeThreadInfo;


  PROCEDURE t1c;
    VAR tid, cid, cnt: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    Kernel.SetPeriod(ThreadOnePeriod, 0);
    cnt := 0;
    REPEAT
      Kernel.Next;
      writeThreadInfo(tid, cid);
      Out.Int(cnt, 8); Out.Ln;
      INC(cnt)
    UNTIL FALSE
  END t1c;


  PROCEDURE Run*;
    VAR scratch0, res: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.WATCHDOG_SCRATCH0, scratch0);
    IF scratch0 = 0 THEN (* scratch regs are zeroed by chip reset, incl. flash programming *)
      Out.String("*** start-up reset ***"); Out.Ln;
    ELSE
      Out.String("*** reset ***"); Out.Ln;
    END;
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t1);

    Kernel.Run
    (* we'll not return here *)
  END Run;

END RestartEvalC1.
