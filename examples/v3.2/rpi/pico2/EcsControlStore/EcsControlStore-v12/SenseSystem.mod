MODULE SenseSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT CS, CL, LEDbinding, Kernel;

  CONST
    SystemName = "Sense";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;


  PROCEDURE runLed(lb: CL.LedBinding; VAR lm: CS.LedMeasured);
  BEGIN
    LEDbinding.Get(lb.ledPin, lm.value);
  END runLed;


  PROCEDURE runSystemLeader(VAR meas: ARRAY OF CS.LedMeasured);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < LEN(meas) DO
      runLed(CL.ledBindingLeader[i], meas[i]);
      INC(i)
    END
  END runSystemLeader;


  PROCEDURE runSystemFollower(VAR meas: ARRAY OF CS.LedMeasured);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < LEN(meas) DO
      runLed(CL.ledBindingFollower[i], meas[i]);
      INC(i)
    END
  END runSystemFollower;


  PROCEDURE Run*;
    VAR S: CS.Store;
  BEGIN
    S := CS.S;
    runSystemLeader(S.ledMeasuredLeader);
    runSystemFollower(S.ledMeasuredFollower)
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {};
  Manifest.O := {};
  Manifest.P := {CS.LedMeasuredId};
  Manifest.Cx := {};
  Manifest.Px := {}
END SenseSystem.
