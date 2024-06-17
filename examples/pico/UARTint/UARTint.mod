MODULE UARTint;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, one core
  Description: https://oberon-rtk.org/examples/uartint/
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Kernel, Out, Errors, GPIO, LEDext;

  CONST
    MillisecsPerTick  = 2;
    ThreadStackSize = 1024;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;
    ts: ARRAY 128 OF CHAR;


  PROCEDURE t0c;
  BEGIN
    GPIO.Set({LEDext.LEDpico});
    REPEAT
      GPIO.Toggle({LEDext.LEDpico});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE fill(VAR s: ARRAY OF CHAR; numChar: INTEGER; baseCh: CHAR);
    VAR i, numChar0: INTEGER;
  BEGIN
    numChar0 := numChar - 2;
    i := 0;
    WHILE i < numChar0 DO
      s[i] := CHR(i MOD 10 + ORD(baseCh));
      INC(i)
    END;
    s[i] := 0DX; INC(i);
    s[i] := 0AX; INC(i);
    s[i] := 0X;
  END fill;


  PROCEDURE t1c;
  BEGIN
    REPEAT
      IF Main.TestCase = 0 THEN
        fill(ts, 42, "0");
        Out.String(ts)
      ELSIF Main.TestCase IN {1, 2} THEN
        fill(ts, 60, "0");
        Out.String(ts)
      ELSIF Main.TestCase IN {3} THEN
        fill(ts, 42, "0");
        Out.String(ts);
        fill(ts, 42, "a");
        Out.String(ts);
      ELSIF Main.TestCase IN {4} THEN
        fill(ts, 42, "0");
        Out.String(ts);
        Kernel.DelayMe(1);
        fill(ts, 42, "a");
        Out.String(ts);
      ELSIF Main.TestCase IN {5} THEN
        fill(ts, 80, "0");
        Out.String(ts);
        Kernel.DelayMe(1);
        fill(ts, 80, "a");
        Out.String(ts);
      ELSE
        ASSERT(FALSE)
      END;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t0, 250, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END UARTint.

