MODULE TrapHandlers;
(**
  Oberon RTK Framework
  Example program, single-threaded, one core
  Description & instructions: https://oberon-rtk.org/examples/traphandlers/
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Alarms, Out, MemoryExt, Exceptions;

  CONST
    NumRecords = 6;
    NumHandlers = 4;
    Rv0 = 3; Rv1 = 12;
    Rv0ur = 4; Rv1ur = 8;
    V00 = 13; V01 = -13;
    V10 = 42; V11 = -42;
    Vx0 = -99; Vx1 = -88;

    Ah0 = 0; Ah1 = 1; Ah2 = 2;
    Th = 3; Th0 = Th; Th1 = Th + 1; Th2 = Th + 2; Th3 = Th + 3;
    Tt = 7; Tt0 = Tt; Tt1 = Tt + 1;
    NumH = 9;


  TYPE
    Rec = POINTER TO RecDesc;
    RecDesc = RECORD
      id: INTEGER;
      intNo, intPrio: INTEGER;
      alarmTime: INTEGER;
      runBegin, runEnd: INTEGER;
      runMid0, runMid1: INTEGER;
      v0, v1: INTEGER
    END;

  VAR
    dev0, dev1, dev2: Alarms.Device;
    devR: Alarms.Device;
    recs: ARRAY NumRecords OF Rec;
    recNo: INTEGER;
    intPrio: ARRAY NumHandlers OF INTEGER;
    intNo : ARRAY NumHandlers OF INTEGER;
    testCase: INTEGER;
    thTests0, thTests1: SET;


  PROCEDURE ah0[0];
    CONST Limit0 = 995;
    VAR now, i, v0, v1: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, {intNo[Ah0]});
    INC(recNo);
    r := recs[recNo];
    r.alarmTime := dev0.time;
    r.runBegin := now;
    r.id := Ah0;
    r.intNo := intNo[Ah0];
    r.intPrio := intPrio[Ah0];
    IF testCase IN thTests0 THEN
      v0 := V00; v1 := V01;
      r.v0 := v0; r.v1 := v1;
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid0);
      SYSTEM.LDREG(Rv1, v1)
    ELSIF testCase IN thTests1 THEN
      v0 := V00; v1 := V01;
      r.v0 := v0; r.v1 := v1;
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid0);
      SYSTEM.LDREG(Rv1ur, v1)
    END;
    i := 0;
    WHILE i < Limit0 DO
      INC(i)
    END;
    IF testCase IN thTests0 THEN
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid1);
      SYSTEM.LDREG(Rv0, v0);
      SYSTEM.PUT(MCU.NVIC_ISPR, {intNo[Th]})
    ELSIF testCase IN thTests1 THEN
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid1);
      SYSTEM.LDREG(Rv0ur, v0);
      SYSTEM.PUT(MCU.NVIC_ISPR, {intNo[Th]})
    END;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END ah0;


  PROCEDURE ah1[0];
    CONST Limit = 1000;
    VAR v0, v1, now, i: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, {intNo[Ah1]});
    INC(recNo); (* possible race condition *)
    r := recs[recNo];
    r.alarmTime := dev1.time;
    r.runBegin := now;
    r.id := Ah1;
    r.intNo := intNo[Ah1];
    r.intPrio := intPrio[Ah1];
    IF testCase IN thTests0 THEN
      v0 := V10; v1 := V11;
      r.v0 := v0; r.v1 := v1;
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid0);
      SYSTEM.LDREG(Rv1, v1)
    END;
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    IF testCase IN thTests0 THEN
      SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid1);
      SYSTEM.LDREG(Rv0, v0);
      SYSTEM.PUT(MCU.NVIC_ISPR, {intNo[Th]})
    END;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END ah1;


  PROCEDURE ah2[0];
    CONST Limit = 250;
    VAR now, i, rv0ur, rv1ur: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    SYSTEM.PUT(MCU.TIMER_INTR + MCU.ACLR, {intNo[Ah2]});
    rv0ur := SYSTEM.REG(Rv0ur); (* "push Rv0ur" *)
    rv1ur := SYSTEM.REG(Rv1ur); (* "push Rv1ur" *)
    INC(recNo); (* possible race condition *)
    r := recs[recNo];
    r.runBegin := now;
    r.alarmTime := dev2.time;
    r.id := Ah2;
    r.intNo := intNo[Ah2];
    r.intPrio := intPrio[Ah2];
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    SYSTEM.LDREG(Rv0, Vx0);
    SYSTEM.LDREG(Rv0ur, Vx0);
    SYSTEM.LDREG(Rv1ur, Vx1);
    SYSTEM.LDREG(Rv0ur, rv0ur); (* "pop Rv0ur" *)
    SYSTEM.LDREG(Rv1ur, rv1ur); (* "pop Rv1ur" *)
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END ah2;


  PROCEDURE th0[0];
  (* parameters passed via lower registers, read directly from registers *)
    CONST Limit = 1000;
    VAR now, i, v0, v1: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    INC(recNo);
    r := recs[recNo];
    v0 := SYSTEM.REG(Rv0);
    r.v0 := v0;
    r.runBegin := now;
    r.id := Th0;
    r.alarmTime := -1;
    r.intNo := intNo[Th];
    r.intPrio := intPrio[Th];
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    v1 := SYSTEM.REG(Rv1);
    r.v1 := v1;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END th0;


  PROCEDURE th1[0];
  (* parameters passed via lower registers, read from stack *)
    CONST Limit = 1000; Rv0offset = 12; Rv1offset = 16; LR = 14; SP = 13;
    VAR now, i, v0, v1, regAddr: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    INC(recNo);
    r := recs[recNo];
    IF 2 IN BITS(SYSTEM.REG(LR)) THEN
      SYSTEM.EMIT(MCU.MRS_R11_PSP); (* r11: save/restore on M3 and up *)
      regAddr := SYSTEM.REG(11)
    ELSE
      regAddr := SYSTEM.REG(SP) + 28;
    END;
    SYSTEM.GET(regAddr + Rv0offset, v0);
    r.v0 := v0;
    r.runBegin := now;
    r.id := Th1;
    r.alarmTime := -1;
    r.intNo := intNo[Th];
    r.intPrio := intPrio[Th];
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    SYSTEM.GET(regAddr + Rv1offset, v1);
    r.v1 := v1;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END th1;


  PROCEDURE th2[0];
  (* parameters passed via upper registers, read directly from upper register *)
    CONST Limit = 1000;
    VAR now, i, v0, v1: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    INC(recNo);
    r := recs[recNo];
    v0 := SYSTEM.REG(Rv0ur);
    r.v0 := v0;
    r.runBegin := now;
    r.id := Th2;
    r.alarmTime := -1;
    r.intNo := intNo[Th];
    r.intPrio := intPrio[Th];
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    v1 := SYSTEM.REG(Rv1ur);
    r.v1 := v1;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END th2;


  PROCEDURE th3[0];
  (* parameters passed via stack, read from stack *)
    CONST
      LR = 14; SP = 13; PSPflag = 2; AlignFlag = 9; Limit = 1000;
      StackFrameSize = 32; PSRoffset = 28;
    VAR now, i, v0, v1, regAddr, parAddr: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    INC(recNo);
    r := recs[recNo];
    IF PSPflag IN BITS(SYSTEM.REG(LR)) THEN
      SYSTEM.EMIT(MCU.MRS_R11_PSP);
      regAddr := SYSTEM.REG(11)
    ELSE
      regAddr := SYSTEM.REG(SP) + 32
    END;
    parAddr := regAddr + StackFrameSize;
    IF SYSTEM.BIT(regAddr + PSRoffset, AlignFlag) THEN
      INC(parAddr, 4)
    END;
    SYSTEM.GET(parAddr, v0);
    r.v0 := v0;
    r.runBegin := now;
    r.id := Th3;
    r.alarmTime := -1;
    r.intNo := intNo[Th];
    r.intPrio := intPrio[Th];
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    SYSTEM.GET(parAddr + 4, v1);
    r.v1 := v1;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END th3;


  PROCEDURE tt0;
    CONST Limit = 988;
    VAR now, i, v0, v1: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    INC(recNo);
    r := recs[recNo];
    r.runBegin := now;
    r.alarmTime := -1;
    r.id := Tt0;
    r.intNo := -1;
    r.intPrio := -1;
    v0 := V00; v1 := V01;
    r.v0 := v0; r.v1 := v1;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid0);
    SYSTEM.LDREG(Rv1, v1);
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid1);
    SYSTEM.LDREG(Rv0, v0);
    SYSTEM.PUT(MCU.NVIC_ISPR, {intNo[Th]});
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END tt0;


  PROCEDURE tt1;
    CONST Limit = 988;
    VAR v0, v1, now, i: INTEGER; r: Rec;
  BEGIN
    SYSTEM.GET(MCU.TIMER_TIMERAWL, now);
    INC(recNo);
    r := recs[recNo];
    r.runBegin := now;
    r.alarmTime := -1;
    r.id := Tt1;
    r.intNo := -1;
    r.intPrio := -1;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid0);
    v0 := V00;
    r.v0 := v0;
    i := 0;
    WHILE i < Limit DO
      INC(i)
    END;
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runMid1);
    v1 := V01;
    r.v1 := v1;
    SYSTEM.PUT(MCU.NVIC_ISPR, {intNo[Th]});
    SYSTEM.GET(MCU.TIMER_TIMERAWL, r.runEnd)
  END tt1;


  PROCEDURE pR[0];
    VAR i: INTEGER; r: Rec;
  BEGIN
    Alarms.DeassertInt(devR);
    Out.String("test case: "); Out.Int(testCase, 0); Out.Ln;
    Out.String(" rec");
    Out.String("   id");
    Out.String(" int");
    Out.String(" prio");
    Out.String("   alarm");
    Out.String("   begin");
    Out.String("    p-th");
    Out.String("    t-th");
    Out.String("     end");
    Out.String("   rtm");
    Out.String("   p0");
    Out.String("   p1");
    Out.Ln;
    i := 0;
    WHILE i <= recNo DO
      r := recs[i];
      Out.Int(i, 4);
      IF r.id < NumH THEN
        CASE r.id OF
          0: Out.String("  ah0")
        | 1: Out.String("  ah1")
        | 2: Out.String("  ah2")
        | 3: Out.String("  th0")
        | 4: Out.String("  th1")
        | 5: Out.String("  th2")
        | 6: Out.String("  th3")
        | 7: Out.String("  tt0")
        | 8: Out.String("  tt1")
        END;
      ELSE
        Out.String("  err")
      END;
      IF r.intNo >= 0 THEN Out.Int(r.intNo, 4) ELSE Out.String("   -") END;
      IF r.intPrio >= 0 THEN Out.Int(r.intPrio, 5) ELSE Out.String("    -") END;
      IF r.alarmTime >= 0 THEN Out.Int(r.alarmTime, 8) ELSE Out.String("      --") END;
      Out.Int(r.runBegin, 8);
      IF r.runMid0 > 0 THEN Out.Int(r.runMid0, 8) ELSE Out.String("      --") END;
      IF r.runMid1 > 0 THEN Out.Int(r.runMid1, 8) ELSE Out.String("      --") END;
      Out.Int(r.runEnd, 8);
      Out.Int(r.runEnd - r.runBegin, 6);
      IF r.v0 # 0 THEN Out.Int(r.v0, 5) ELSE Out.String("    -") END;
      IF r.v1 # 0 THEN Out.Int(r.v1, 5) ELSE Out.String("    -") END;
      Out.Ln;
      INC(i)
    END;
    Out.Ln
  END pR;


  PROCEDURE initRecs;
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < NumRecords DO
      NEW(recs[i]);
      CLEAR(recs[i]^);
      INC(i)
    END
  END initRecs;


  PROCEDURE preCache;
  BEGIN
    MemoryExt.CacheProc(SYSTEM.ADR(ah0));
    MemoryExt.CacheProc(SYSTEM.ADR(ah1));
    MemoryExt.CacheProc(SYSTEM.ADR(ah2));
    MemoryExt.CacheProc(SYSTEM.ADR(th0));
    MemoryExt.CacheProc(SYSTEM.ADR(th1));
    MemoryExt.CacheProc(SYSTEM.ADR(th2));
    MemoryExt.CacheProc(SYSTEM.ADR(th3));
    MemoryExt.CacheProc(SYSTEM.ADR(tt0));
    MemoryExt.CacheProc(SYSTEM.ADR(tt1))
  END preCache;


  PROCEDURE run;
    CONST Start = 10000;
    VAR time: INTEGER; en: SET;
  BEGIN
    initRecs;
    preCache;
    thTests0 := {}; thTests1 := {};
    recNo := -1;

    NEW(dev0); NEW(dev1); NEW(dev2); NEW(devR);
    Alarms.Init(devR, 3, FALSE);
    Alarms.Enable(devR, 3);
    Alarms.Arm(devR, pR, Start + 500000);

    testCase := 0;

    (* basic tests *)
    IF testCase = 0 THEN
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intPrio[Ah0] := 2;
      intPrio[Ah1] := 2;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start + 250)

    ELSIF testCase = 1 THEN
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intPrio[Ah0] := 2;
      intPrio[Ah1] := 2;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start + 50)

    ELSIF testCase = 2 THEN
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intPrio[Ah0] := 2;
      intPrio[Ah1] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start + 50)

    ELSIF testCase = 3 THEN
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intPrio[Ah0] := 2;
      intPrio[Ah1] := 2;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start)

    (* trap handler triggered by two alarm handlers *)
    ELSIF testCase = 4 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start + 50)

    ELSIF testCase = 5 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start + 150)

    ELSIF testCase = 6 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start)

    ELSIF testCase = 7 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah0] := 3;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start + 50)

    ELSIF testCase = 8 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah0] := 3;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev1, ah1, Start + 150)

    (* trap handler triggered by thread code and alarm handler *)
    ELSIF testCase = 9 THEN
      INCL(thTests0, testCase);
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev1, ah1, Start + 50);
      REPEAT
        SYSTEM.GET(MCU.TIMER_TIMERAWL, time)
      UNTIL time >= Start;
      tt0

    ELSIF testCase = 10 THEN
      INCL(thTests0, testCase);
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev1, ah1, Start + 150);
      REPEAT
        SYSTEM.GET(MCU.TIMER_TIMERAWL, time)
      UNTIL time >= Start;
      tt0

     ELSIF testCase = 11 THEN
      INCL(thTests0, testCase);
      intNo[Ah1] := 0;
      intNo[Th] := 26;
      intPrio[Ah1] := 2;
      intPrio[Th] := 1;
      Alarms.Init(dev1, intNo[Ah1], TRUE);
      Alarms.Enable(dev1, intPrio[Ah1]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev1, ah1, Start);
      REPEAT
        SYSTEM.GET(MCU.TIMER_TIMERAWL, time)
      UNTIL time >= Start;
      tt0

    (* reading parameter tests *)
    ELSIF testCase = 12 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah2] := 2;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah2] := 0;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev2, intNo[Ah2], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev2, intPrio[Ah2]);
      Exceptions.InstallIntHandler(intNo[Th], th0);
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev2, ah2, Start + 113)

    ELSIF testCase = 13 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah2] := 2;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah2] := 0;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev2, intNo[Ah2], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev2, intPrio[Ah2]);
      Exceptions.InstallIntHandler(intNo[Th], th1); (* th1 *)
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev2, ah2, Start + 113)

    ELSIF testCase = 14 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah2] := 2;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah2] := 0;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev2, intNo[Ah2], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev2, intPrio[Ah2]);
      Exceptions.InstallIntHandler(intNo[Th], th1); (* th1 *)
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev2, ah2, Start + 50)

    ELSIF testCase = 15 THEN
      INCL(thTests0, testCase);
      intNo[Ah0] := 1;
      intNo[Ah2] := 2;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah2] := 0;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev2, intNo[Ah2], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev2, intPrio[Ah2]);
      Exceptions.InstallIntHandler(intNo[Th], th1); (* th1 *)
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev2, ah2, Start + 150)

    ELSIF testCase = 16 THEN
      INCL(thTests1, testCase); (* thTests1: use upper registers, see ah0 *)
      intNo[Ah0] := 1;
      intNo[Ah2] := 2;
      intNo[Th] := 26;
      intPrio[Ah0] := 2;
      intPrio[Ah2] := 0;
      intPrio[Th] := 1;
      Alarms.Init(dev0, intNo[Ah0], TRUE);
      Alarms.Init(dev2, intNo[Ah2], TRUE);
      Alarms.Enable(dev0, intPrio[Ah0]);
      Alarms.Enable(dev2, intPrio[Ah2]);
      Exceptions.InstallIntHandler(intNo[Th], th2); (* th2 *)
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev0, ah0, Start);
      Alarms.Arm(dev2, ah2, Start + 150)

    ELSIF testCase = 17 THEN
      intNo[Th] := 26;
      intNo[Ah2] := 2;
      intPrio[Ah2] := 0;
      intPrio[Th] := 1;
      Alarms.Init(dev2, intNo[Ah2], TRUE);
      Alarms.Enable(dev2, intPrio[Ah2]);
      Exceptions.InstallIntHandler(intNo[Th], th3); (* th2 *)
      Exceptions.SetIntPrio(intNo[Th], intPrio[Th]);
      en := {intNo[Th]}; (* workaround v9.1 *)
      Exceptions.EnableInt(en);
      Alarms.Arm(dev2, ah2, Start + 150);
      REPEAT
        SYSTEM.GET(MCU.TIMER_TIMERAWL, time)
      UNTIL time >= Start;
      tt1 (* tt1 *)

    ELSE
      ASSERT(FALSE)
    END;
  END run;

BEGIN
  run
END TrapHandlers.
