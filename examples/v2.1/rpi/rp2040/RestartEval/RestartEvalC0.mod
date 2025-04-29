MODULE RestartEvalC0;
(**
  Oberon RTK Framework v2.x
  --
  Example program, multi-threaded, multi-core
  Evaluate different restart options and conditions.
  Description: https://oberon-rtk.org/examples/v2.1/restarteval/
  --
  Core 1 program: RestartEvalC1
  --
  MCU: RP2040
  Board: Pico
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

    SysReset1 = MCU.PSM_ALL - {MCU.PSM_ROSC, MCU.PSM_XOSC};
    SysReset2 = MCU.PSM_ALL - {MCU.PSM_ROSC, MCU.PSM_XOSC};


  VAR
    hb, t1: Kernel.Thread;
    hbid, tid1: INTEGER;


  PROCEDURE hbc;
  BEGIN
    GPIO.Set({LED.Pico});
    Kernel.SetPeriod(HeartbeatPeriod, 0);
    REPEAT
      GPIO.Toggle({LED.Pico});
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
    SYSTEM.PUT(MCU.WATCHDOG_SCRATCH1, resetsResetsDone);
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
      watchdogReason, chipReset, scratch, gpioOut, sramProcAddr, handlerStackAddr: INTEGER;
      resetsResetsDone: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    Kernel.SetPeriod(ThreadOnePeriod, 0);
    SYSTEM.GET(CHIP_RESET, chipReset);
    Out.String("CHIP_RESET       "); Out.Hex(chipReset, 12); Out.Ln;
    SYSTEM.GET(MCU.WATCHDOG_REASON, watchdogReason);
    Out.String("WATCHDOG_REASON  "); Out.Hex(watchdogReason, 12); Out.Ln;
    SYSTEM.GET(MCU.SIO_GPIO_OUT, gpioOut);
    Out.String("SIO_GPIO_OUT     "); Out.Hex(gpioOut, 12); Out.Ln;
    SYSTEM.GET(MCU.WATCHDOG_SCRATCH1, resetsResetsDone);
    Out.String("RESETS_DONE      "); Out.Hex(resetsResetsDone, 12); Out.Ln;
    i := 2;
    WHILE i < 8 DO
      SYSTEM.GET(MCU.WATCHDOG_SCRATCH0 + (i * MCU.WATCHDOG_SCRATCH_Offset), scratch);
      Out.String("WATCHDOG_SCRATCH"); Out.Int(i, 0); Out.Hex(scratch, 12); Out.Ln;
      INC(i)
    END;
    i := 1;
    WHILE i < 8 DO
      SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0 + (i * MCU.WATCHDOG_SCRATCH_Offset), 0ABABABABH);
      INC(i)
    END;
    SYSTEM.GET(MCU.WATCHDOG_SCRATCH0, scratch);
    cnt := 0; x := 0;
    REPEAT
      Kernel.Next;
      IF scratch = 1 THEN (* watchdog timer *)
        IF cnt = 0 THEN
          GPIO.Set({LEDext.LED0});
          Out.Ln; Out.String("watchdog timer: system reset"); Out.Ln
        END;
        IF cnt = Cnt THEN
          StartUp.SetPowerOnWatchdogResets(SysReset1);
          SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 2);
          REPEAT UNTIL FALSE
        END
      ELSIF scratch = 2 THEN (* watchdog force, with watchdog boot handler *)
        IF cnt = 0 THEN
          GPIO.Set({LEDext.LED1});
          Out.Ln; Out.String("watchdog force: system reset, then run watchdog boot handler"); Out.Ln
        END;
        IF cnt = Cnt THEN
          StartUp.SetPowerOnWatchdogResets(SysReset2);
          MemoryExt.CopyProc(SYSTEM.ADR(bootHandler), sramProcAddr);
          MemoryExt.Allocate(handlerStackAddr, HandlerStackSize);
          StartUp.SetWatchdogBootVector(handlerStackAddr + HandlerStackSize, sramProcAddr);
          SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 3);
          Watchdog.Trigger;
          REPEAT UNTIL FALSE
        END
      ELSIF scratch = 3 THEN (* run-time error *)
        IF cnt = 0 THEN
          GPIO.Set({LEDext.LED2});
          Out.Ln; Out.String("runtime error: PPB_AIRCR reset"); Out.Ln
        END;
        IF cnt = Cnt THEN
          SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 1);
          x := x DIV x
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
    SYSTEM.GET(MCU.WATCHDOG_SCRATCH0, scratch0);
    IF scratch0 = 0 THEN (* scratch regs are zeroed by chip reset, incl. flash programming *)
      Out.String("*** start-up reset ***"); Out.Ln;
      SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 1);
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
    Watchdog.SetLoadTime(800); (* heartbeat does reload *)
    Watchdog.Enable;

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END RestartEvalC0.
