MODULE ReadTerminal;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, single-core
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, Out, In, GPIO, LED;

  CONST
    MillisecsPerTick  = 5;
    ThreadStackSize = 1024;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;


  PROCEDURE writeReadError(res: INTEGER);
  BEGIN
    IF res = In.NoError THEN
      Out.String("OK")
    ELSIF res = In.BufferOverflow THEN
      Out.String("buffer overflow")
    ELSIF res = In.SyntaxError THEN
      Out.String("number syntax error")
    ELSIF res = In.OutOfLimits THEN
      Out.String("number out of 32 bit 2-complement limits")
    ELSIF res = In.NoInput THEN
      Out.String("no input")
    END
  END writeReadError;


  PROCEDURE t0c;
  BEGIN
    GPIO.Set({LED.Green});
    REPEAT
      GPIO.Toggle({LED.Green});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR str: ARRAY 16 OF CHAR; res, int: INTEGER; (* small buffer to test string overflows *)
  BEGIN
    REPEAT
      REPEAT
        Out.String("enter string: ");
        In.String(str, res);
        IF res = In.BufferOverflow THEN
          writeReadError(res); Out.String(", string truncated (the buffer provided to 'In.String')"); Out.Ln;
          Out.String("truncated string: ")
        END;
        Out.Char("'"); Out.String(str); Out.Char("'");
        Out.Ln
      UNTIL res = In.NoInput;
      Kernel.Next;
      REPEAT
        Out.String("enter number: ");
        In.Int(int, res);
        IF res = In.NoError THEN
          Out.Int(int, 0)
        ELSE
          writeReadError(res); Out.String(", number not valid");
          IF res = In.BufferOverflow THEN
            Out.String(" (the buffer in 'Texts.ReadInt')")
          END
        END;
        Out.Ln;
      UNTIL res = In.NoInput;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t0, 500, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t1, 50, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END ReadTerminal.
