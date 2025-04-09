MODULE StringBufOut;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, one core
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, Terminals, StringDev, StringBuffers, MultiCore, Out, Errors, GPIO, LEDext;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    TestString = "0123456789";

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;


  PROCEDURE t0c;
    VAR ledNo: INTEGER;
  BEGIN
    GPIO.Set({LEDext.LEDpico});
    ledNo := 0;
    REPEAT
      LEDext.SetLedBits(ledNo, 7, 4);
      LEDext.SetLedBits(ledNo, 3, 0);
      INC(ledNo);
      GPIO.Toggle({LEDext.LEDpico});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    CONST NumStr = 3; (* 4 will overflow the output buffer *)
    VAR tid, cid, cnt, i: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    REPEAT
      writeThreadInfo(tid, cid);
      Out.Int(cnt, 8); INC(cnt);
      Out.String(" ");
      Out.String(TestString);
      Out.String(" ");
      Out.Flush;
      i := 0;
      WHILE i < NumStr DO
        Out.String(TestString); INC(i)
      END;
      Out.Ln;
      Out.Flush;
      IF NumStr > 3 THEN (* buffer overflow: previous Out.Ln gets lost *)
        Out.Ln; Out.Flush
      END;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE run;
    VAR res: INTEGER; strDev0, strDev1: StringDev.Device;
  BEGIN
    (**
      Re-wire the text output pipeline, as set up my Main, to use the string buffers
      between Out and the terminals.
      This block can be commented out, and the program will work unchanged, but
      writing directly to the UART.
    **)
    StringBuffers.InitStrDev(strDev0, Terminals.W[Terminals.TERM0]);
    StringBuffers.Open(StringBuffers.BUF0, strDev0, StringDev.PutString, StringDev.FlushOut);
    StringBuffers.InitStrDev(strDev1, Terminals.W[Terminals.TERM1]);
    StringBuffers.Open(StringBuffers.BUF1, strDev1, StringDev.PutString, StringDev.FlushOut);
    Out.Open(StringBuffers.W[0], StringBuffers.W[1]);
    (* end potential comment-out *)

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
END StringBufOut.
