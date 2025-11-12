MODULE RestartEvalC0;
(**
  Oberon RTK Framework v2.1
  --
  Example program, multi-threaded, multi-core
  Evaluate different restart options and conditions.
  Description: https://oberon-rtk.org/docs/examples/v2.1/restarteval/
  --
  Core 1 program: RestartEvalC1
  --
  MCU: RP2350
  Board: Pico 2
  --
  Copyright (c) 2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Main, Kernel, Recovery, Watchdog, StartUp, MultiCore,
    GPIO, LED, Out, LEDext, MemoryExt, InitCoreOne, Core1 := RestartEvalC1;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;
    HeartbeatPeriod = 50; (* ticks *)
    ThreadOnePeriod = 100;

    CHIP_RESET = MCU.CHIP_RESET;

  VAR
    hb, t1: Kernel.Thread;
    hbid, tid1: INTEGER;


  PROCEDURE hbc;
    VAR wdTime: INTEGER;
  BEGIN
    GPIO.Set({LED.Pico});
    Kernel.SetPeriod(HeartbeatPeriod, 0);
    REPEAT
      GPIO.Toggle({LED.Pico});
      (*
      Watchdog.GetTime(wdTime);
      Out.Int(wdTime, 0); Out.Ln;
      *)
      Watchdog.Reload;
      Kernel.Next
    UNTIL FALSE
  END hbc;


  PROCEDURE bootHandler;
    CONST Resets = {MCU.RESETS_IO_BANK0, MCU.RESETS_PADS_BANK0}; LEDpinNo7 = 15;
    VAR done: SET; addr, x, resetsResetsDone: INTEGER;
  BEGIN
    (* get RESETS_DONE state, store into SCRATCH1 to print by thread *)
    SYSTEM.GET(MCU.RESETS_DONE, resetsResetsDone);
    SYSTEM.PUT(MCU.POWMAN_SCRATCH1, resetsResetsDone);
    (* release resets *)
    SYSTEM.PUT(MCU.RESETS_RESET + MCU.ACLR, Resets);
    SYSTEM.GET(MCU.RESETS_DONE, done);
    WHILE done * Resets # Resets DO
      SYSTEM.GET(MCU.RESETS_DONE, done)
    END;
    (* set SIO function *)
    addr := MCU.IO_BANK0_GPIO0_CTRL + (LEDpinNo7 * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, MCU.IO_BANK0_Fsio);
    SYSTEM.PUT(addr, x);
    (* enable output *)
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, {LEDpinNo7});
    (* LED on *)
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {LEDpinNo7})
  END bootHandler;


  PROCEDURE t1c;
    CONST Cnt = 3; HandlerStackSize = 128;
    VAR
      i, tid, cid, cnt, x: INTEGER;
      watchdogReason, watchdogCtrl, chipReset, scratch, gpioOut, sramProcAddr, handlerStackAddr: INTEGER;
      resetsResetsDone: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    Kernel.SetPeriod(ThreadOnePeriod, 0);
    SYSTEM.GET(CHIP_RESET, chipReset);
    Out.String("CHIP_RESET       "); Out.Hex(chipReset, 12); Out.Ln;
    SYSTEM.GET(MCU.WATCHDOG_CTRL, watchdogCtrl);
    Out.String("WATCHDOG_CTRL    "); Out.Hex(watchdogCtrl, 12); Out.Ln;
    SYSTEM.GET(MCU.WATCHDOG_REASON, watchdogReason);
    Out.String("WATCHDOG_REASON  "); Out.Hex(watchdogReason, 12); Out.Ln;
    SYSTEM.GET(MCU.SIO_GPIO_OUT, gpioOut);
    Out.String("SIO_GPIO_OUT     "); Out.Hex(gpioOut, 12); Out.Ln;
    SYSTEM.GET(MCU.POWMAN_SCRATCH1, resetsResetsDone);
    Out.String("RESETS_DONE      "); Out.Hex(resetsResetsDone, 12); Out.Ln;

    i := 2;
    WHILE i < 8 DO
      SYSTEM.GET(MCU.POWMAN_SCRATCH0 + (i * MCU.POWMAN_SCRATCH_Offset), scratch);
      Out.String("POWMAN_SCRATCH"); Out.Int(i, 0); Out.Hex(scratch, 14); Out.Ln;
      INC(i)
    END;
    i := 0;
    WHILE i < 8 DO
      SYSTEM.GET(MCU.WATCHDOG_SCRATCH0 + (i * MCU.WATCHDOG_SCRATCH_Offset), scratch);
      Out.String("WATCHDOG_SCRATCH"); Out.Int(i, 0); Out.Hex(scratch, 12); Out.Ln;
      INC(i)
    END;
    i := 0;
    WHILE i < 4 DO
      SYSTEM.GET(MCU.POWMAN_BOOT0 + (i * MCU.POWMAN_BOOT_Offset), scratch);
      Out.String("POWMAN_BOOT"); Out.Int(i, 0); Out.Hex(scratch, 17); Out.Ln;
      INC(i)
    END;

    i := 1;
    WHILE i < 8 DO
      SYSTEM.PUT(MCU.POWMAN_SCRATCH0 + (i * MCU.POWMAN_SCRATCH_Offset), 0ABABABABH);
      INC(i)
    END;
    i := 0;
    WHILE i < 8 DO
      SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0 + (i * MCU.WATCHDOG_SCRATCH_Offset), 0CDCDCDCDH);
      INC(i)
    END;
    i := 0;
    WHILE i < 4 DO
      SYSTEM.PUT(MCU.POWMAN_BOOT0 + (i * MCU.POWMAN_BOOT_Offset), 0EFEFEFEFH);
      INC(i)
    END;

    SYSTEM.GET(MCU.POWMAN_SCRATCH0, scratch);
    cnt := 0; x := 0;
    REPEAT
      Kernel.Next;
      IF scratch = 1 THEN
        IF cnt = 0 THEN
          GPIO.Set({LEDext.LED0});
          Out.Ln; Out.String("watchdog timer: system reset"); Out.Ln
        END;
        IF cnt = Cnt THEN
          StartUp.SetResetWatchdogResets(MCU.RESETS_ALL);
          StartUp.SetPowerOnWatchdogResets(MCU.PSM_ALL);
          SYSTEM.PUT(MCU.POWMAN_SCRATCH0, 2);
          REPEAT UNTIL FALSE
        END
      ELSIF scratch = 2 THEN
        IF cnt = 0 THEN
          GPIO.Set({LEDext.LED1});
          Out.Ln; Out.String("watchdog force: system reset, then run watchdog boot handler"); Out.Ln
        END;
        IF cnt = Cnt THEN
          StartUp.SetResetWatchdogResets(MCU.RESETS_ALL);
          StartUp.SetPowerOnWatchdogResets(MCU.PSM_ALL);
          MemoryExt.CopyProc(SYSTEM.ADR(bootHandler), sramProcAddr);
          MemoryExt.Allocate(handlerStackAddr, HandlerStackSize);
          StartUp.SetWatchdogBootVector(handlerStackAddr + HandlerStackSize, sramProcAddr);
          SYSTEM.PUT(MCU.POWMAN_SCRATCH0, 3);
          Watchdog.Trigger;
          REPEAT UNTIL FALSE
        END
      ELSIF scratch = 3 THEN
        IF cnt = 0 THEN
          GPIO.Set({LEDext.LED2});
          Out.Ln; Out.String("watchdog force: system reset, then run powman boot handler"); Out.Ln
        END;
        IF cnt = Cnt THEN
          StartUp.SetResetWatchdogResets(MCU.RESETS_ALL);
          StartUp.SetPowerOnWatchdogResets(MCU.PSM_ALL);
          MemoryExt.CopyProc(SYSTEM.ADR(bootHandler), sramProcAddr);
          MemoryExt.Allocate(handlerStackAddr, HandlerStackSize);
          StartUp.SetPowmanBootVector(handlerStackAddr + HandlerStackSize, sramProcAddr);
          SYSTEM.PUT(MCU.POWMAN_SCRATCH0, 4);
          Watchdog.Trigger;
          REPEAT UNTIL FALSE
        END
      ELSIF scratch = 4 THEN
        IF cnt = 0 THEN
          GPIO.Set({LEDext.LED3});
          Out.Ln; Out.String("runtime error: error handler reset "); Out.Ln
        END;
        IF cnt = Cnt THEN
          SYSTEM.PUT(MCU.POWMAN_SCRATCH0, 1);
          GPIO.Set({LEDext.LED5});
          x := x DIV x
        END
      ELSIF scratch = 5 THEN (* watchdog timer, chip reset *)
        IF cnt = 0 THEN
          SYSTEM.PUT(LEDext.LSET, {LEDext.LED4});
          Out.Ln; Out.String("watchdog timer: chip reset"); Out.Ln
        END;
        IF cnt = Cnt THEN
          StartUp.SetResetWatchdogResets(MCU.RESETS_ALL);
          StartUp.SetPowerOnWatchdogResets(MCU.PSM_ALL);
          StartUp.SetPowmanWatchdogReset(LSL(1, 8));
          SYSTEM.PUT(MCU.POWMAN_SCRATCH0, 1);
          REPEAT UNTIL FALSE
        END
      ELSE
        Out.Ln; Out.String("wrong test case"); Out.Ln;
        REPEAT UNTIL FALSE
      END;
      INC(cnt)
    UNTIL FALSE
  END t1c;


  PROCEDURE run;
    VAR scratch0, res: INTEGER;
  BEGIN
    MultiCore.StartCoreOne(Core1.Run, InitCoreOne.Init);
    SYSTEM.GET(MCU.POWMAN_SCRATCH0, scratch0);
    IF scratch0 = 0 THEN (* scratch regs are zeroed by chip reset, incl. flash programming *)
      Out.String("*** start-up reset ***"); Out.Ln;
      SYSTEM.PUT(MCU.POWMAN_SCRATCH0, 1);
    ELSE
      Out.String("*** reset ***"); Out.Ln;
    END;
    Recovery.Init;
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(hbc, ThreadStackSize, hb, hbid, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(hb);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK);
    Kernel.Enable(t1);

    StartUp.SetPowerOnWatchdogResets(MCU.PSM_RESET);
    Watchdog.SetLoadTime(700); (* heartbeat does reload *)
    Watchdog.Enable;

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END RestartEvalC0.
