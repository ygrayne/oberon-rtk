MODULE NoBusyWaitingC0;
(**
  Oberon RTK Framework v2
  --
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/nobusywating/
  --
  Program for core 1: 'NoBusyWaitingC1'
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
**)

  IMPORT Main, Kernel, MultiCore, Memory, GPIO, LED, CoreOne := NoBusyWaitingC1;

  CONST
    Core1 = 1;
    MillisecsPerTick  = 100; (* no need for speed for the blinker *)
    ThreadStackSize = 1024;

  VAR
    t0: Kernel.Thread;
    tid0: INTEGER;


  PROCEDURE t0c;
  BEGIN
    GPIO.Set({LED.Green});
    REPEAT
      GPIO.Toggle({LED.Green});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE run;
    VAR res: INTEGER;
  BEGIN
    MultiCore.InitCoreOne(CoreOne.Run, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK);
    Kernel.SetPeriod(t0, 500, 0); Kernel.Enable(t0);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END NoBusyWaitingC0.

