MODULE DebugEval;
(**
  Oberon RTK Framework
  Example program, multi-threaded, single-core
  Description: https://oberon-rtk.org/examples/debugeval/
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, Kernel, Out, LEDext, Timers, DebugEvalImp;

  CONST
  (* the (*constants*) *)
    MillisecsPerTick = 10;
    ThreadStackSize (* crazy comment *) = 1024;
    Big0 = 0F0000000H;
    Big1 = 00E000000H;
    Neg = -42;

  TYPE
    R0 = RECORD(DebugEvalImp.R0)
      i, j: INTEGER
    END;
    R1 = RECORD(R0)
      x, y: INTEGER
    END;
    R2 = RECORD(R1)
      a, b: INTEGER
    END;

  VAR
  (* the variables *)
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;
    x: INTEGER;
    unused: INTEGER; (* gets a memory slot anyway *)
    y: INTEGER;
    r1: R1;


  PROCEDURE    writeThreadInfo(tid, cid: INTEGER);
  (* print thread info *)
  BEGIN(*really crazy comment*)Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;

(*
  PROCEDURE commentedOut;
  BEGIN
  (* some (* and even (* and more *) more *) nesting *)
  END commentedOut;
*)

  PROCEDURE testType(r: R1);
  BEGIN
    IF r IS R2 THEN
    END
  END testType;

  PROCEDURE t0c;
  (* thread 0 code *)
    CONST Big2 = 0D00001H;
    VAR ledNo: INTEGER;
  BEGIN
    SYSTEM.PUT(LEDext.SET, {LEDext.LEDpico});
    ledNo := 0;
    x := Big0;
    x := x + Big1;
    x := x + Big2;
    y := Neg;
    REPEAT
      LEDext.SetValue(ledNo);
      INC(ledNo);
      SYSTEM.PUT(LEDext.XOR, {LEDext.LEDpico});
      Kernel.Next
    UNTIL FALSE
  END t0c;

  PROCEDURE t1c;
  (* thread 1 code *)
    VAR tid, cid, cnt, before, timeL: INTEGER;
  BEGIN
    tid := Kernel.Tid();
    cnt := 0;
    Timers.GetTimeL(before);
    REPEAT
      Kernel.Next;
      Timers.GetTimeL(timeL);
      writeThreadInfo(tid, cid);
      Out.Int(cnt, 8); Out.Int(timeL - before, 8); Out.Ln;
      before := timeL;
      INC(cnt)
    UNTIL FALSE
  END t1c;


  PROCEDURE run;
  (* let's get running *)
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t0, 250, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END DebugEval.
