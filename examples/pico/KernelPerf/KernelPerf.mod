MODULE KernelPerf;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, one core
  Description: https://oberon-rtk.org/examples/kernelperf/
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Kernel, Terminals, Out, TextIO, UARTkstr, Errors;

  CONST
    MillisecsPerTick  = 8;
    ThreadStackSize = 1024;
    ThreadPeriod = MillisecsPerTick;
    ThreadZeroPeriod = MillisecsPerTick;
    NumThreads = 16;
    MaxCount0 = 4000;
    MaxCount1 = 5500;
    MaxCount2 = 7000;
    TestString30 = "123456789012345678901234567890";
    TestString40 = "1234567890123456789012345678901234567890";
    TestString50 = "12345678901234567890123456789012345678901234567890";

    TestCase = 12;

    ThreadRunningPinNo = 16;
    Th0RunningPioNo = 19;

  VAR
    t: ARRAY NumThreads OF Kernel.Thread;
    tid: ARRAY NumThreads OF INTEGER;
    maxCount: INTEGER;


  PROCEDURE t0c;
  BEGIN
    REPEAT
      IF TestCase IN {0 .. 3, 6, 9 .. 12} THEN
        Out.String(TestString30)
      ELSIF TestCase IN {4, 7} THEN
        Out.String(TestString40)
      ELSIF TestCase IN {5, 8} THEN
        Out.String(TestString50)
      ELSE
        ASSERT(FALSE)
      END;
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {ThreadRunningPinNo});
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Th0RunningPioNo});
      Kernel.Next;
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Th0RunningPioNo});
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {ThreadRunningPinNo})
    UNTIL FALSE
  END t0c;


  PROCEDURE tc;
    VAR cnt: INTEGER;
  BEGIN
    REPEAT
      cnt := 0;
      WHILE cnt < maxCount DO
        INC(cnt)
      END;
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {ThreadRunningPinNo});
      Kernel.Next;
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {ThreadRunningPinNo})
    UNTIL FALSE
  END tc;


  PROCEDURE setMaxCount;
  BEGIN
    IF TestCase IN {0, 3 .. 11} THEN
      maxCount := MaxCount0
    ELSIF TestCase IN {1} THEN
      maxCount := MaxCount1
    ELSIF TestCase IN {2} THEN
      maxCount := MaxCount2
    ELSIF TestCase IN {12} THEN
      maxCount := MaxCount0 DIV 2
    ELSE
      ASSERT(FALSE)
    END
  END setMaxCount;


  PROCEDURE getPeriod(tid, msPerTick: INTEGER): INTEGER;
    VAR period: INTEGER;
  BEGIN
    IF TestCase IN {0 .. 8, 10 .. 12} THEN
      period := msPerTick
    ELSIF TestCase IN {9} THEN
      IF ODD(tid) THEN
        period := msPerTick
      ELSE
        period := msPerTick * 2
      END
    ELSE
      ASSERT(FALSE)
    END
    RETURN period
  END getPeriod;


  PROCEDURE getNumThreads(VAR numThreads: INTEGER);
  BEGIN
    IF TestCase IN {0 .. 9, 11, 12} THEN
      numThreads := NumThreads
    ELSIF TestCase IN {10} THEN
      numThreads := NumThreads DIV 2
    ELSE
      ASSERT(FALSE)
    END
  END getNumThreads;


  PROCEDURE getPrio(tid: INTEGER): INTEGER;
    CONST MaxThreads = 16;
    VAR prio: INTEGER;
  BEGIN
    IF TestCase IN {0 .. 10, 12} THEN
      prio := Kernel.DefaultPrio
    ELSIF TestCase IN {11} THEN
      prio := MaxThreads - tid
    ELSE
      ASSERT(FALSE)
    END
    RETURN prio
  END getPrio;


  PROCEDURE run;
    VAR
      res, i: INTEGER;
      numThreads: INTEGER;
      uartDev0: TextIO.Device;
      msPerTick: INTEGER;
  BEGIN
    Out.String("init"); Out.Ln;
    IF TestCase IN {6, 7, 8} THEN
      Terminals.Close(Terminals.TERM0, uartDev0);
      Terminals.Open(Terminals.TERM0, uartDev0, UARTkstr.PutString, UARTkstr.GetString);
      Out.Open(Terminals.W[0], Terminals.W[1])
    END;
    IF TestCase IN {0 ..11} THEN
      msPerTick := MillisecsPerTick
    ELSIF TestCase IN {12} THEN
      msPerTick := MillisecsPerTick DIV 2
    END;
    setMaxCount;
    Kernel.Install(msPerTick);
    i := 0;
    Kernel.Allocate(t0c, ThreadStackSize, t[i], tid[i], res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t[i], ThreadZeroPeriod, 0);
    Kernel.SetPrio(t[i], getPrio(i));
    Kernel.Enable(t[i]);
    INC(i);
    getNumThreads(numThreads);
    WHILE i < numThreads DO
      Kernel.Allocate(tc, ThreadStackSize, t[i], tid[i], res); ASSERT(res = Kernel.OK, Errors.ProgError);
      Kernel.SetPeriod(t[i], getPeriod(i, msPerTick), 0);
      Kernel.SetPrio(t[i], getPrio(i));
      Kernel.Enable(t[i]);
      INC(i)
    END;
    Out.String("running..."); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END KernelPerf.
