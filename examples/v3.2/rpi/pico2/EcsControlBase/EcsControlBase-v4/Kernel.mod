MODULE Kernel;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v4
  --
  A minimal cooperative scheduler for the ECS variants. Systems are
  registered with 'AddSystem' (period 0 runs every tick, otherwise
  every 'period' ms) and each runs once per tick, to completion, in
  registration order -- the hand-ordered schedule a derived toposort
  will eventually replace. 'Run' waits for the tick ('WFI') and
  dispatches; nothing pre-empts a System. The roster is fixed once
  registered ('MaxSystems' slots).
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SysTick, ASM, EXC, Errors;

  CONST
    MaxSystems* = 8;

  TYPE
    SystemProc* = PROCEDURE;

    System* = POINTER TO SystemDesc;
    SystemDesc* = RECORD
      run: SystemProc;
      period: INTEGER;
      ticker: INTEGER
    END;

  VAR
    systems: ARRAY MaxSystems OF System;
    numSystems: INTEGER;
    TickPeriod*: INTEGER;


  PROCEDURE AddSystem*(run: SystemProc; period: INTEGER);
  BEGIN
    ASSERT(numSystems < MaxSystems, Errors.ProgError);
    NEW(systems[numSystems]); ASSERT(systems[numSystems] # NIL, Errors.HeapOverflow);
    systems[numSystems].run := run;
    systems[numSystems].period := period;
    systems[numSystems].ticker := period;
    INC(numSystems)
  END AddSystem;


  PROCEDURE Run*;
    VAR system: System; sid: INTEGER;
  BEGIN
    SysTick.Enable;
    REPEAT
      SYSTEM.EMIT(ASM.WFI);
      IF SysTick.Tick() THEN
        sid := 0;
        WHILE sid < numSystems DO
          system := systems[sid];
          IF system.period = 0 THEN
            system.run
          ELSE
            DEC(system.ticker, TickPeriod);
            IF system.ticker < 0 THEN
              system.run;
              INC(system.ticker, system.period)
            END
          END;
          INC(sid)
        END
      END
    UNTIL FALSE
  END Run;


  PROCEDURE sysTickHandler[0];
  END sysTickHandler;


  PROCEDURE Install*(msPerTick: INTEGER);
  BEGIN
    numSystems := 0;
    TickPeriod := msPerTick;
    SysTick.Config(msPerTick, sysTickHandler, EXC.ExcPrioLow)
  END Install;

END Kernel.
