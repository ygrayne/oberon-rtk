MODULE K4perf0;
(**
  Oberon RTK Framework v3.0
  --
  Performance test program for kernel-v4.
  https://oberon-rtk.org/docs/examples/v2/k4perf/
  --
  Commented-out code: see description
  --
  MCU: RP2350
  Board: Pico2
  --
  Kernel-v4
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, Main, MCU := MCU2, Kernel, GPIO, Exceptions, Out, Errors;

  CONST
    HighPrio = MCU.ExcPrioTop;
    MedPrio = MCU.ExcPrioMedium;
    LowPrio = MCU.ExcPrioLow;
    SysTickPrio = MCU.ExcPrioHigh;

    HighRunIntNo = MCU.IRQ_SW_0;
    MedRunIntNo = MCU.IRQ_SW_1;
    LowRunIntNo = MCU.IRQ_SW_2;

    NumIntMsg = 2;

    Pin1 = 16;
    Pin2 = 17;
    Pin3 = 18;
    Pin4 = 19;
    Pin5 = 3;

  VAR
    ah, am, al: Kernel.Actor;
    rdyQh, rdyQm, rdyQl: Kernel.ReadyQ;
    pinEvQ: Kernel.EventQ;
    pinMsgPool: Kernel.MessagePool;


  PROCEDURE rdyHigh[0];
  BEGIN
    Kernel.RunQueue(rdyQh)
  END rdyHigh;

  PROCEDURE rdyMed[0];
  BEGIN
    Kernel.RunQueue(rdyQm)
  END rdyMed;

  PROCEDURE rdyLow[0];
  BEGIN
    Kernel.RunQueue(rdyQl)
  END rdyLow;


  PROCEDURE pinHandler[0];
    VAR msg: Kernel.Message; (*ev, intL, intH: SET; cnt: INTEGER;*)
  BEGIN
    (*SYSTEM.GET(MCU.PPB_DWT_CYCCNT, cnt); (* 26 cycles = 208 ns*)*)
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin2});
    (*SYSTEM.GET(MCU.PPB_DWT_CYCCNT, cnt); (* 29 cycles = 232 ns*)*)
    (*Out.Int(cnt, 0); Out.Ln;*)
    GPIO.ClearAllIntEvents(Pin5);
    Kernel.GetFromMsgPool(pinMsgPool, msg);
    IF msg # NIL THEN
      Kernel.PutMsg(pinEvQ, msg)
    END;
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin2})
  END pinHandler;

(*
  PROCEDURE pinHandler2[0];
    VAR msg: Kernel.Message; ev, intL, intH: SET;
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin2});
    GPIO.GetIntSummary(intL, intH);
    IF Pin5 IN intL THEN
      GPIO.GetIntEvents(Pin5, ev);
      GPIO.ClearAllIntEvents(Pin5);
      Kernel.GetFromMsgPool(pinMsgPool, msg);
      IF GPIO.IRQ_EDGE_RISE IN ev THEN
        IF msg # NIL THEN
          Kernel.PutMsg(pinEvQ, msg)
        END
      ELSIF GPIO.IRQ_EDGE_FALL IN ev THEN
        IF msg # NIL THEN
          Kernel.PutMsg(pinEvQ, msg)
        END
      END
    END;
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin2})
  END pinHandler2;
*)

  PROCEDURE aRunHigh(act: Kernel.Actor);
    (*VAR cnt: INTEGER;*)
  BEGIN
    (*SYSTEM.GET(MCU.PPB_DWT_CYCCNT, cnt);*)
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin3});
    (*Out.Int(cnt, 0); Out.Ln;*)
    Kernel.GetMsg(pinEvQ, act);
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin3})
  END aRunHigh;

  PROCEDURE aInitHigh(act: Kernel.Actor);
  BEGIN
    act.run := aRunHigh;
    Kernel.GetMsg(pinEvQ, act);
  END aInitHigh;


  PROCEDURE aRunMed(act: Kernel.Actor);
  BEGIN
    IF act.state = 0 THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin1});
      (*SYSTEM.PUT(MCU.PPB_DWT_CYCCNT, 0);*)
      act.state := 1
    ELSIF act.state = 1 THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin1});
      (*SYSTEM.PUT(MCU.PPB_DWT_CYCCNT, 0);*)
      act.state := 0
    ELSE
      ASSERT(FALSE, Errors.ProgError)
    END;
    Kernel.GetTick(act)
  END aRunMed;

  PROCEDURE aInitMed(act: Kernel.Actor);
  BEGIN
    act.run := aRunMed;
    act.state := 1;
    Kernel.GetTick(act)
  END aInitMed;


  PROCEDURE aRunLow(act: Kernel.Actor);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin4});
    REPEAT UNTIL FALSE
  END aRunLow;

  PROCEDURE aInitLow(act: Kernel.Actor);
  BEGIN
    act.run := aRunLow;
    Kernel.GetTick(act)
  END aInitLow;


  PROCEDURE run;
    CONST GPIOintNo = MCU.IRQ_IO_BANK0; (*TRCENA = 24; CYCCNTENA = 0;*)
    (*VAR s: SET;*)
  BEGIN
    Out.String("begin K4perf0"); Out.Ln;

    (* set up GPIO *)
    (* Pin5: interrrupt trigger input *)
    (* others: for measurements *)
    GPIO.SetFunction(Pin1, MCU.IO_BANK0_Fsio);
    GPIO.SetFunction(Pin2, MCU.IO_BANK0_Fsio);
    GPIO.SetFunction(Pin3, MCU.IO_BANK0_Fsio);
    GPIO.SetFunction(Pin4, MCU.IO_BANK0_Fsio);
    GPIO.ConnectInput(Pin5);
    GPIO.ClearPadIso(Pin5);
    GPIO.EnableOutputL({Pin1, Pin2, Pin3, Pin4});
    GPIO.ClearL({Pin1, Pin2, Pin3, Pin4});

    (* set up GPIO interrupt in NVIC *)
    Exceptions.InstallIntHandler(GPIOintNo, pinHandler);
    Exceptions.SetIntPrio(GPIOintNo, HighPrio);
    Exceptions.ClearPendingInt(GPIOintNo);
    Exceptions.EnableInt(GPIOintNo);

    (* enable GPIO int on Pin 5 *)
    GPIO.SetIntEvents(Pin5, {GPIO.IRQ_EDGE_FALL, GPIO.IRQ_EDGE_RISE});
    GPIO.ClearAllIntEvents(Pin5);

    (* compose the kernel *)
    Kernel.Install(1, SysTickPrio);
    Kernel.NewRdyQ(rdyQh, 0, 0);
    Kernel.InstallRdyQ(rdyQh, rdyHigh, HighRunIntNo, HighPrio);
    Kernel.NewRdyQ(rdyQm, 0, 0);
    Kernel.InstallRdyQ(rdyQm, rdyMed, MedRunIntNo, MedPrio);
    Kernel.NewRdyQ(rdyQl, 0, 0);
    Kernel.InstallRdyQ(rdyQl, rdyLow, LowRunIntNo, LowPrio);

    Kernel.NewEvQ(pinEvQ);
    Kernel.NewMsgPool(pinMsgPool, NIL, NumIntMsg);

    (* create actors *)
    NEW(ah); ASSERT(ah # NIL, Errors.HeapOverflow);
    Kernel.InitAct(ah, aInitHigh, 0);
    NEW(am); ASSERT(am # NIL, Errors.HeapOverflow);
    Kernel.InitAct(am, aInitMed, 1);
    NEW(al); ASSERT(al # NIL, Errors.HeapOverflow);
    Kernel.InitAct(al, aInitLow, 2);

    (* start actors *)
    Kernel.RunAct(ah, rdyQh);
    Kernel.RunAct(am, rdyQm);
    Kernel.RunAct(al, rdyQl);

    (* clock cycle counter *)
    (*
    SYSTEM.GET(MCU.PPB_DEMCR, s);
    INCL(s, TRCENA);
    SYSTEM.PUT(MCU.PPB_DEMCR, s);
    SYSTEM.GET(MCU.PPB_DWT_CTRL, s);
    INCL(s, CYCCNTENA);
    SYSTEM.PUT(MCU.PPB_DWT_CTRL, s);
    *)

    Out.String("end init K4perf0"); Out.Ln;
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END K4perf0.
