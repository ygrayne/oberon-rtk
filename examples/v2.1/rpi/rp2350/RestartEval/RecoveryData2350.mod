MODULE RecoveryData;
(**
  Oberon RTK Framework v2
  --
  Example program, multi-threaded, multi-core

  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Kernel, Recovery, Watchdog, StartUp, MultiCore, GPIO, LED, Out, LEDext;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;
    HeartbeatPeriod = 50; (* ticks *)
    ThreadOnePeriod = 100;

    CHIP_RESET = MCU.CHIP_RESET;

    RP2350 = FALSE;

  VAR
    hb, t1: Kernel.Thread;
    hbid, tid1: INTEGER;
    helloStack: ARRAY 1024 OF BYTE;


  PROCEDURE hbc;
  BEGIN
    GPIO.Set({LED.Pico});
    Kernel.ChangePeriod(HeartbeatPeriod, 0);
    REPEAT
      GPIO.Toggle({LED.Pico});
      Watchdog.Reload;
      Kernel.Next
    UNTIL FALSE
  END hbc;


  PROCEDURE hello;
  BEGIN
    SYSTEM.PUT(LEDext.LSET, {LEDext.LED7})
  END hello;


  PROCEDURE t1c;
    CONST Cnt = 3;
    VAR i, tid, cid, cnt, x, watchdogReason, chipReset, scratch: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    Kernel.ChangePeriod(ThreadOnePeriod, 0);
    SYSTEM.GET(CHIP_RESET, chipReset);
    Out.String("CHIP_RESET       "); Out.Hex(chipReset, 12); Out.Ln;
    SYSTEM.GET(MCU.WATCHDOG_REASON, watchdogReason);
    Out.String("WATCHDOG_REASON  "); Out.Hex(watchdogReason, 12); Out.Ln;
    i := 1;
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
      IF scratch = 1 THEN
        SYSTEM.PUT(LEDext.LSET, {LEDext.LED0});
        IF cnt = 0 THEN
          Out.Ln; Out.String("watchdog timer: system reset"); Out.Ln
        END;
        StartUp.SetPowerOnWatchdogResets(MCU.PSM_RESET);
        IF cnt = Cnt THEN
          StartUp.SetWatchdogBootVector(SYSTEM.ADR(helloStack), hello);
          SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 2);
          REPEAT UNTIL FALSE
        END
      ELSIF scratch = 2 THEN
        SYSTEM.PUT(LEDext.LSET, {LEDext.LED1});
        IF cnt = 0 THEN
          Out.Ln; Out.String("watchdog force: system reset"); Out.Ln
        END;
        StartUp.SetPowerOnWatchdogResets(MCU.PSM_RESET);
        IF cnt = Cnt THEN
          SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 3);
          Watchdog.Trigger
        END
      ELSIF scratch = 3 THEN
        SYSTEM.PUT(LEDext.LSET, {LEDext.LED2});
        IF cnt = 0 THEN
          Out.Ln; Out.String("runtime error: PPB_AIRCR reset"); Out.Ln
        END;
        IF cnt = Cnt THEN
          IF RP2350 THEN
            SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 4)
          ELSE
            SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 1)
          END;
          x := x DIV x
        END
      ELSIF scratch = 4 THEN
        IF RP2350 THEN
          SYSTEM.PUT(LEDext.LSET, {LEDext.LED3});
          IF cnt = 0 THEN
            Out.Ln; Out.String("watchdog timer: chip reset"); Out.Ln
          END;
          (*
          StartUp.SetPowerOnWatchdogResets(MCU.PSM_ALL);
          StartUp.SetPowmanWatchdogReset(LSL(1, 12));
          *)
          IF cnt = Cnt THEN
            SYSTEM.PUT(MCU.WATCHDOG_SCRATCH0, 2);
            REPEAT UNTIL FALSE
          END
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
    SYSTEM.GET(MCU.WATCHDOG_SCRATCH0, scratch0);
    IF scratch0 = 0 THEN
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

    Watchdog.SetLoadTime(800);
    (*StartUp.SetWatchdogPowerOnResets(MCU.PSM_RESET);*)
    (*StartUp.SetPowerOnWatchdogResets(MCU.PSM_ALL);*)
    (*StartUp.SetPowmanWatchdogReset(LSL(1, 12));*)
    Watchdog.Enable;

    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END RecoveryData.
