MODULE Kernel;
(**
  Oberon RTK Framework
  Version v4.0
  --
  The kernel for ECS-for-control architecture.
  * system registration
  * world-creation consistency checks
  * system scheduling order derivation
  * cooperative system scheduler
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SysTick, ASM, EXC, Errors;

  CONST
    MaxSystems* = 16;
    MaxTokens* = 32;

    (* check ids *)
    (* not relaxable *)
    ChkWriter* = 0;    (* rule: no P or O token in two Systems *)
    ChkClass* = 1;     (* rule: a token is a dataflow (-> P & C) or a deposit/collect (-> Px Cx), not mixed *)
    ChkOwnedRead* = 2; (* rule: no O token in C *)
    ChkSelfLoop* = 3;  (* rule: no system consumes a token it produces *)
    ChkCycle* = 4;     (* rule: no cycles in P -> C dependencies *)

    (* relaxable *)
    ChkUnproduced* = 5;  (* rule: every C has a P, every Cx has a Px *)
    ChkUnconsumed* = 6;  (* rule: every P has at least one C *)
    ChkNoCollector* = 7; (* rule: every Px has at least one collector Cx *)

    NumChecks* = 8;

    Relaxable = {ChkUnproduced, ChkUnconsumed, ChkNoCollector};

  TYPE
    SystemProc* = PROCEDURE;
    SystemName* = ARRAY 32 OF CHAR;

    Manifest* = RECORD
      C*: SET; (* R *)
      O*, P*: SET;  (* RW *)
      Cx*: SET; (* R, collected Px, after all depositors have run *)
      Px*: SET; (* RW, deposit: multi-producer by design, at least one collector *)
    END;

    System* = RECORD
      run: SystemProc;
      manifest*: Manifest; (* -> for PlanView *)
      period: INTEGER;
      ticker: INTEGER;
      name*: SystemName (* -> for PlanView *)
    END;

  VAR
    TickPeriod*: INTEGER;
    TickCount*: INTEGER;    (* running counter, written by sysTickHandler *)
    MissedTicks*: INTEGER;  (* cumulative missed ticks, written by Run *)
    ElapsedTicks*: INTEGER; (* ticks of the current pass, written by Run *)

    Systems*: ARRAY MaxSystems OF System;
    NumSystems*: INTEGER;
    Deps*: ARRAY MaxSystems OF SET;      (* dependencies of system i *)
    Order*: ARRAY MaxSystems OF INTEGER; (* scheduling order, valid entries: Order[0 .. NumPlaced-1] *)
    NumPlaced*: INTEGER;
    Failed*, Relaxed*: SET;              (* check ids *)
    Offend*: ARRAY NumChecks OF SET;     (* offending tokens; system ids for ChkCycle *)
    planned: BOOLEAN;


  PROCEDURE* AddSystem*(run: SystemProc; manifest: Manifest; period: INTEGER; name: ARRAY OF CHAR);
  BEGIN
    ASSERT(NumSystems < MaxSystems, Errors.ProgError);
    Systems[NumSystems].run := run;
    Systems[NumSystems].period := period;
    Systems[NumSystems].ticker := period;
    Systems[NumSystems].manifest := manifest;
    Systems[NumSystems].name := name;
    INC(NumSystems);
    planned := FALSE
  END AddSystem;


  PROCEDURE Relax*(checks: SET);
  (* dev builds only; non-relaxable checks are masked out structurally *)
  BEGIN
    Relaxed := checks * Relaxable
  END Relax;


  PROCEDURE Plan*;
    VAR
      allWritten, allP, allPx, allC, allCx, allO, written, self, placed: SET;
      i, j, count: INTEGER; found: BOOLEAN;
  BEGIN
    Failed := {};
    CLEAR(Offend);

    allWritten := {}; allP := {}; allPx := {}; allC := {}; allCx := {}; allO := {};
    i := 0;
    WHILE i < NumSystems DO
      written := Systems[i].manifest.O + Systems[i].manifest.P;
      IF written * allWritten # {} THEN
        (* rule: one writer of O and P *)
        INCL(Failed, ChkWriter);
        Offend[ChkWriter] := Offend[ChkWriter] + (written * allWritten)
      END;
      self := (Systems[i].manifest.C + Systems[i].manifest.Cx) * (written + Systems[i].manifest.Px);
      IF self # {} THEN
        (* rule: system does not consume own products *)
        INCL(Failed, ChkSelfLoop);
        Offend[ChkSelfLoop] := Offend[ChkSelfLoop] + self
      END;
      allWritten := allWritten + written;
      allP := allP + Systems[i].manifest.P;
      allPx := allPx + Systems[i].manifest.Px;
      allC := allC + Systems[i].manifest.C;
      allCx := allCx + Systems[i].manifest.Cx;
      allO := allO + Systems[i].manifest.O;
      INC(i)
    END;

    IF (allPx * (allP + allO)) + (allC * allPx) + (allCx * (allP + allO)) # {} THEN
      (* rule: a token is a dataflow (-> P & C) or a deposit/collect (-> Px Cx), not mixed *)
      INCL(Failed, ChkClass);
      Offend[ChkClass] :=  (allPx * (allP + allO)) + (allC * allPx) + (allCx * (allP + allO))
    END;
    IF allO * allC # {} THEN
      (* rule: no O token in C *)
      INCL(Failed, ChkOwnedRead);
      Offend[ChkOwnedRead] := allO * allC
    END;
    IF (allC - allP) + (allCx - allPx) # {} THEN
      (* rule: every C has a P, every Cx has at least one Px *)
      INCL(Failed, ChkUnproduced);
      Offend[ChkUnproduced] := (allC - allP) + (allCx - allPx)
    END;
    IF allP - allC # {} THEN
      (* rule: every P has at least one C *)
      INCL(Failed, ChkUnconsumed);
      Offend[ChkUnconsumed] := allP - allC
    END;
    IF allPx - allCx # {} THEN
      (* rule: every Px has at least one collector Cx *)
      INCL(Failed, ChkNoCollector);
      Offend[ChkNoCollector] := allPx - allCx
    END;

    (* dependencies: i depends on every j whose P meets i's C, or whose Px meets i's Cx *)
    i := 0;
    WHILE i < NumSystems DO
      Deps[i] := {};
      j := 0;
      WHILE j < NumSystems DO
        IF j # i THEN
          IF ((Systems[i].manifest.C * Systems[j].manifest.P)
               + (Systems[i].manifest.Cx * Systems[j].manifest.Px)) # {} THEN
            INCL(Deps[i], j)
          END
        END;
        INC(j)
      END;
      INC(i)
    END;

    (* Kahn's topological sort -> Order[]; a stall is a cycle, recorded not trapped *)
    placed := {}; count := 0; found := TRUE;
    WHILE (count < NumSystems) & found DO
      found := FALSE; i := 0;
      WHILE (i < NumSystems) & ~found DO
        IF ~(i IN placed) & (Deps[i] - placed = {}) THEN
          Order[count] := i; INCL(placed, i); INC(count); found := TRUE
        END;
        INC(i)
      END
    END;
    NumPlaced := count;
    IF count < NumSystems THEN
      INCL(Failed, ChkCycle);
      i := 0;
      WHILE i < NumSystems DO
        IF ~(i IN placed) THEN INCL(Offend[ChkCycle], i) END;
        INC(i)
      END
    END;

    planned := TRUE
  END Plan;


  PROCEDURE* Commit*;
  BEGIN
    ASSERT(planned, Errors.ProgError);
    ASSERT(Failed - Relaxed = {}, Errors.PlanCheck)
  END Commit;


  PROCEDURE runSystem(VAR s: System; elapsedTicks: INTEGER);
  BEGIN
    IF s.period = 0 THEN
      s.run
    ELSE
      DEC(s.ticker, elapsedTicks);
      IF s.ticker <= 0 THEN
        s.run;
        INC(s.ticker, s.period)
      END
    END
  END runSystem;


  PROCEDURE Run*;
    VAR sid, now, delta, ticksSeen: INTEGER;
  BEGIN
    TickCount := 0; MissedTicks := 0; ticksSeen := 0;
    SysTick.Enable;
    REPEAT
      SYSTEM.EMIT(ASM.WFI);
      now := TickCount;
      delta := now - ticksSeen;
      IF delta > 0 THEN
        IF delta > 1 THEN
          INC(MissedTicks, delta - 1)
        END;
        ticksSeen := now;
        ElapsedTicks := delta;
        sid := 0;
        WHILE sid < NumSystems DO
          runSystem(Systems[Order[sid]], delta);
          INC(sid)
        END
      END
    UNTIL FALSE
  END Run;


  PROCEDURE* sysTickHandler[0];
  BEGIN
    INC(TickCount)
  END sysTickHandler;


  PROCEDURE Install*(msPerTick: INTEGER);
  BEGIN
    NumSystems := 0;
    Relaxed := {};
    planned := FALSE;
    TickPeriod := msPerTick;
    SysTick.Config(msPerTick, sysTickHandler, EXC.ExcPrioLow)
  END Install;

END Kernel.
