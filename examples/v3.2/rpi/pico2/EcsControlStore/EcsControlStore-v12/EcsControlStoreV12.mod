MODULE EcsControlStoreV12;
(**
  Oberon RTK Framework v3.2
  --
  Evaluation program for ECS architecture

  v12 -- declared, derived, checked

  * Closed-loop LED control: two leader LEDs blink, two followers
    track them crosswise via measured state.
  * Each System declares its store access in a manifest.
  * The kernel derives the schedule from the manifests, checks the
    construction before the first tick, and detects missed ticks.
  * Reporting runs as a shared facility: two depositors, one collector,
    drained to a UART.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, CS, CL, W, V, Kernel, PlanView, Console, Texts, Errors,
    BlinkSystem, ActuateSystem, SenseSystem, CoupleSystem, HeartbeatSystem,
    PrintSystem, DrainSystem, TickMonitorSystem,
    UARTbinding, LEDbinding, UART, TIMER, PrintBuffers, DrainBuffers;


  PROCEDURE build;
    VAR
      S: CS.Store;
      uartDev: UART.Device; printDev: PrintBuffers.Device;
      timerDev: TIMER.Device; writer: Texts.Writer;
      drainDev: DrainBuffers.Device;
      printBufHandle, writerHandle: INTEGER;
  BEGIN
    CS.Build;
    S := CS.S;

    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    UART.Init(uartDev, W.UartHandle_Drain, W.UartUnit_Drain);

    NEW(drainDev); ASSERT(drainDev # NIL, Errors.HeapOverflow);
    DrainBuffers.Init(drainDev, W.DrainBufHandle_Tx);

    printBufHandle := 0; writerHandle := 0;
    WHILE printBufHandle < LEN(CL.printWriter) DO
      NEW(printDev); ASSERT(printDev # NIL, Errors.HeapOverflow);
      PrintBuffers.Init(printDev, printBufHandle);
      NEW(writer); ASSERT(writer # NIL, Errors.HeapOverflow);
      Texts.OpenWriter(writer, writerHandle, printBufHandle, PrintBuffers.PutString, NIL);
      INC(printBufHandle); INC(writerHandle);
    END;

    NEW(timerDev); ASSERT(timerDev # NIL, Errors.HeapOverflow);
    TIMER.Init(timerDev, W.TimerHandle_Heartbeat, W.TimerUnit_Heartbeat);

    LEDbinding.Config;
    UARTbinding.Config(CL.uartBinding.devHandle, W.Pin_DrainUartTx, W.Pin_DrainUartRx, V.DrainBaudrate);
    TIMER.Configure(CL.timerBinding.devHandle)
  END build;


  PROCEDURE attest;
  (* verify that every device reference wired in CL resolves to a bound device *)
    VAR i: INTEGER;
  BEGIN
    ASSERT(UART.Bound(CL.uartBinding.devHandle), Errors.ConsCheck);
    ASSERT(TIMER.Bound(CL.timerBinding.devHandle), Errors.ConsCheck);
    ASSERT(DrainBuffers.Bound(CL.drainBuf.devHandle), Errors.ConsCheck);
    i := 0;
    WHILE i < LEN(CL.printBuf) DO
      ASSERT(PrintBuffers.Bound(CL.printBuf[i].devHandle), Errors.ConsCheck);
      ASSERT(Texts.Bound(CL.printWriter[i].writerHandle), Errors.ConsCheck);
      INC(i)
    END
  END attest;


  PROCEDURE acquire;
    VAR S: CS.Store; i: INTEGER;
  BEGIN
    S := CS.S;
    i := 0;
    WHILE i < LEN(CL.ledBindingLeader) DO
      LEDbinding.Get(CL.ledBindingLeader[i].ledPin, S.ledMeasuredLeader[i].value);
      INC(i)
    END;
    i := 0;
    WHILE i < LEN(CL.ledBindingFollower) DO
      LEDbinding.Get(CL.ledBindingFollower[i].ledPin, S.ledMeasuredFollower[i].value);
      INC(i)
    END;
    TIMER.GetTimeL(CL.timerBinding.devHandle, S.heartbeatStatus.last)
  END acquire;


  PROCEDURE value;
    VAR
      S: CS.Store;
      i: INTEGER; periods: ARRAY LEN(S.ledSetpointLeader) OF INTEGER;
  BEGIN
    S := CS.S;
    periods[0] := V.BlinkPeriod_0;
    periods[1] := V.BlinkPeriod_1;
    i := 0;
    WHILE i < LEN(S.ledSetpointLeader) DO
      S.ledSetpointLeader[i].value := 0;
      S.blinkConfig[i].period := periods[i];
      S.blinkConfig[i].ticker := periods[i];
      INC(i)
    END;
    i := 0;
    WHILE i < LEN(S.ledSetpointFollower) DO
      S.ledSetpointFollower[i].value := 0;
      INC(i)
    END;
    i := 0;
    WHILE i < LEN(S.printBuf) DO
      S.printBuf[i].seq := 0;
      S.printCursor[i].seqDone := 0;
      INC(i)
    END;
    S.heartbeatStatus.count := 0
  END value;


  PROCEDURE propagate;
    VAR S: CS.Store; i: INTEGER;
  BEGIN
    S := CS.S;
    i := 0;
    WHILE i < LEN(CL.ledBindingLeader) DO
      LEDbinding.Put(CL.ledBindingLeader[i].ledPin, S.ledSetpointLeader[i].value);
      INC(i)
    END;
    i := 0;
    WHILE i < LEN(CL.ledBindingFollower) DO
      LEDbinding.Put(CL.ledBindingFollower[i].ledPin, S.ledSetpointFollower[i].value);
      INC(i)
    END
  END propagate;


  PROCEDURE addSystems;
  (* add in any order: the scheduling order is determined algorithmically *)
  BEGIN
    Kernel.AddSystem(BlinkSystem.Run, BlinkSystem.Manifest, 0, BlinkSystem.Name);
    Kernel.AddSystem(CoupleSystem.Run, CoupleSystem.Manifest, 0, CoupleSystem.Name);
    Kernel.AddSystem(ActuateSystem.Run, ActuateSystem.Manifest, 0, ActuateSystem.Name);
    Kernel.AddSystem(DrainSystem.Run, DrainSystem.Manifest, 0, DrainSystem.Name);
    Kernel.AddSystem(TickMonitorSystem.Run, TickMonitorSystem.Manifest, 0, TickMonitorSystem.Name);
    Kernel.AddSystem(PrintSystem.Run, PrintSystem.Manifest, 0, PrintSystem.Name);
    Kernel.AddSystem(SenseSystem.Run, SenseSystem.Manifest, 0, SenseSystem.Name);
    Kernel.AddSystem(HeartbeatSystem.Run, HeartbeatSystem.Manifest, V.HeartbeatPeriod, HeartbeatSystem.Name);
  END addSystems;

BEGIN
  build;
  attest;
  acquire;
  value;
  propagate;
  Kernel.Install(V.TickPeriod);
  addSystems;
  (*Kernel.Relax({Kernel.ChkUnconsumed});*)
  Kernel.Plan;
  PlanView.Report(Console.Werr[Console.SYSTERM0]);
  Kernel.Commit;
  Kernel.Run
END EcsControlStoreV12.
