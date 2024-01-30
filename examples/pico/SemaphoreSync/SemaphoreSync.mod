MODULE SemaphoreSync;
(**
  Oberon RTK Framework
  Example program, multi-threaded, single-core
  Description: https://oberon-rtk.org/examples/semaphoresync/
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, Out, MultiCore, Semaphores, Error, GPIO, LED;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

  VAR
    t0, t1, t2: Kernel.Thread;
    tid0, tid1, tid2: INTEGER;
    uart: Semaphores.Semaphore;


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
    VAR tid, cid: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    REPEAT
      Semaphores.Claim(uart);
      writeThreadInfo(tid, cid);
      Out.String(" semaphore claimed --");
      Out.String(" start of message...");
      Kernel.Next;
      Out.String(" end of message");
      Out.String(" -- releasing semaphore"); Out.Ln;
      Semaphores.Release(uart)
    UNTIL FALSE
  END t1c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    NEW(uart); ASSERT(uart # NIL, Error.HeapOverflow);
    Semaphores.Init(uart);
    Kernel.Install(MillisecsPerTick);
    (* blinker *)
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Error.Config);
    Kernel.SetPeriod(t0, 500, 0); Kernel.Enable(t0);
    (* two threads coordinating output, running the same code *)
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Error.Config);
    Kernel.SetPeriod(t1, 500, 0); Kernel.Enable(t1);
    Kernel.Allocate(t1c, ThreadStackSize, t2, tid2, res); ASSERT(res = Kernel.NoError, Error.Config);
    Kernel.SetPeriod(t2, 500, 0); Kernel.Enable(t2);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END SemaphoreSync.

