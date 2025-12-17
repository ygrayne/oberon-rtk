MODULE K4print;
(**
  Oberon RTK Framework v3.0
  --
  Base test program for kernel-v4 prototype.
  https://oberon-rtk.org/docs/examples/v2/k4print/
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Kernel-v4
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, Main, MCU := MCU2, Kernel, KernelAlarms, Alarms, Errors, TextIO, Texts, Terminals, GPIO;

  CONST
    RunIntLowNo = MCU.IRQ_SW_2;
    RunIntHighNo = MCU.IRQ_SW_3;
    RunPrioLow = MCU.ExcPrioLow;
    RunPrioHigh = MCU.ExcPrioHigh;
    SysTickPrio = MCU.ExcPrioMedium;

    TimerNo = Alarms.T0;
    AlarmNo = Alarms.A0;
    HighPeriod = 10;

    TIMER_RAWL = MCU.TIMER0_BASE + MCU.TIMER_TIMERAWL_Offset;

    (* test pins *)
    Pin1* = 16;
    Pin2* = 17;
    Pin3* = 18;
    Pin4* = 19;

    TrigPin = 20; (* oscilloscope external trigger *)

  TYPE
    A0 = POINTER TO A0desc;
    A0desc = RECORD (Kernel.ActorDesc)
      cnt: INTEGER;
      startAt: INTEGER
    END;

  VAR
    a0, a1: A0;
    ahp: Kernel.Actor;
    rdyQlow, rdyQhigh: Kernel.ReadyQ;
    ka: KernelAlarms.Alarm;
    W: ARRAY 2 OF TextIO.Writer;
    pins: ARRAY 2 OF INTEGER;


  PROCEDURE rdyRunLow[0];
  (* ready queue run int handler *)
  BEGIN
    Kernel.RunQueue(rdyQlow)
  END rdyRunLow;


  PROCEDURE rdyRunHigh[0];
  (* ready queue run int handler *)
  BEGIN
    Kernel.RunQueue(rdyQhigh)
  END rdyRunHigh;


  PROCEDURE aWrite(act: Kernel.Actor);
  (* systick-interrupt-driven actor run procedure *)
    CONST TestString0 = "   123456789012345678901234567890"; TestString1 = " 12345"; TestString2 = " 123456";
    VAR a: A0; timeL, id, pin: INTEGER; W0: TextIO.Writer;
  BEGIN
    SYSTEM.GET(TIMER_RAWL, timeL);
    a := act(A0);
    id := a.id;
    W0 := W[0];
    pin := pins[id];
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {pin});
    Texts.WriteString(W0, "=> int");    (* 6 chars *)
    Texts.WriteString(W0, " test ");    (* 6 chars *)
    Texts.WriteInt(W0, id, 1);          (* 1 char *)
    Texts.WriteInt(W0, a.cnt, 12);      (* 12 chars, two PrintString calls *)
    Texts.WriteString(W0, TestString1);
    Texts.WriteLn(W0);                  (* 2 chars *)
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {pin});
    INC(a.cnt);
    a.startAt := timeL;
    Kernel.GetTick(a)
  END aWrite;


  PROCEDURE aHigh(act: Kernel.Actor);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, {Pin1});
    KernelAlarms.Rearm(ka, act, HighPeriod)
  END aHigh;


  PROCEDURE aInit(act: Kernel.Actor);
    VAR a: A0;
  BEGIN
    a := act(A0);
    a.cnt := 0;
    a.startAt := 0;
    a.run := aWrite;
    Kernel.GetTick(a)
  END aInit;


  PROCEDURE ahpInit(act: Kernel.Actor);
    VAR time: INTEGER;
  BEGIN
    act.run := aHigh;
    KernelAlarms.GetTime(ka, time);
    KernelAlarms.Arm(ka, act, time + HighPeriod)
  END ahpInit;


  PROCEDURE run;
  BEGIN
    W[0] := Terminals.W[0];
    W[1] := Terminals.W[1];
    pins[0] := Pin3;
    pins[1] := Pin4;

    Kernel.Install(1000, SysTickPrio);
    Kernel.NewRdyQ(rdyQlow, 0, 0);
    Kernel.InstallRdyQ(rdyQlow, rdyRunLow, RunIntLowNo, RunPrioLow);
    Kernel.NewRdyQ(rdyQhigh, 0, 0);
    Kernel.InstallRdyQ(rdyQhigh, rdyRunHigh, RunIntHighNo, RunPrioHigh);

    NEW(ka); ASSERT(ka # NIL, Errors.HeapOverflow);
    KernelAlarms.Init(ka, TimerNo, AlarmNo, RunPrioHigh);

    NEW(a0); ASSERT(a0 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(a0, aInit, 0);
    NEW(a1); ASSERT(a1 # NIL, Errors.HeapOverflow);
    Kernel.InitAct(a1, aInit, 1);
    NEW(ahp); ASSERT(ahp # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ahp, ahpInit, 2);

    Kernel.RunAct(a0, rdyQlow);
    Kernel.RunAct(a1, rdyQlow);
    Kernel.RunAct(ahp, rdyQhigh);

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  GPIO.SetFunction(Pin1, MCU.IO_BANK0_Fsio);
  GPIO.SetFunction(Pin2, MCU.IO_BANK0_Fsio);
  GPIO.SetFunction(Pin3, MCU.IO_BANK0_Fsio);
  GPIO.SetFunction(Pin4, MCU.IO_BANK0_Fsio);
  GPIO.SetFunction(TrigPin, MCU.IO_BANK0_Fsio);
  GPIO.EnableOutputL({Pin1, Pin2, Pin3, Pin4, TrigPin});
  GPIO.ClearL({Pin1, Pin2, Pin3, Pin4, TrigPin});
  run
END K4print.
