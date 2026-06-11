MODULE SemaphoreSync;
(**
  Oberon RTK Framework v3.1
  --
  Example program, multi-threaded, kernel-v1
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02As
  --
  Copyright (c) 2023-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, Out, Cores, Semaphores, Errors, LED;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    ThreadPeriod = 500 DIV MillisecsPerTick; (* 500 ms *)

  VAR
    t0, t1, t2: Kernel.Thread;
    tid0, tid1, tid2: INTEGER;
    uart: Semaphores.Semaphore;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE heartbeat;
  BEGIN
    Kernel.SetPeriod(ThreadPeriod, 0);
    LED.Set({LED.Pico});
    REPEAT
      LED.Toggle({LED.Pico});
      Kernel.Next
    UNTIL FALSE
  END heartbeat;


  PROCEDURE writer;
    VAR tid, cid: INTEGER;
  BEGIN
    Kernel.SetPeriod(ThreadPeriod, 0);
    cid := Cores.CoreId();
    tid := Kernel.Tid();
    REPEAT
      Semaphores.Claim(uart);
      writeThreadInfo(tid, cid);
      Out.String(" semaphore claimed --");
      Out.String(" start of message => reschedule =>");
      Kernel.Next;
      Out.String(" end of message");
      Out.String(" -- semaphore released"); Out.Ln;
      Semaphores.Release(uart)
    UNTIL FALSE
  END writer;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    NEW(uart); ASSERT(uart # NIL, Errors.HeapOverflow);
    Semaphores.Init(uart);
    Kernel.Install(MillisecsPerTick);
    (* heartbeat blinker *)
    Kernel.Allocate(heartbeat, ThreadStackSize, t0, tid0, res);
    ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t0);
    (* two threads coordinating output, running the same code *)
    Kernel.Allocate(writer, ThreadStackSize, t1, tid1, res);
    ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t1);
    Kernel.Allocate(writer, ThreadStackSize, t2, tid2, res);
    ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t2);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  LED.Config;
  run
END SemaphoreSync.
