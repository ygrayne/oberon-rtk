MODULE ActuateSystem;
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
    SystemName = "Actuate";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;


  PROCEDURE runLed(lb: CL.LedBinding; sp: CS.LedSetpoint; lm: CS.LedMeasured);
  BEGIN
    IF lm.value # sp.value THEN
      LEDbinding.Put(lb.ledPin, sp.value)
    END
  END runLed;


  PROCEDURE runSystemLeader(setp: ARRAY OF CS.LedSetpoint; meas: ARRAY OF CS.LedMeasured);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < LEN(setp) DO
      runLed(CL.ledBindingLeader[i], setp[i], meas[i]);
      INC(i)
    END
  END runSystemLeader;


  PROCEDURE runSystemFollower(setp: ARRAY OF CS.LedSetpoint; meas: ARRAY OF CS.LedMeasured);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < LEN(setp) DO
      runLed(CL.ledBindingFollower[i], setp[i], meas[i]);
      INC(i)
    END
  END runSystemFollower;


  PROCEDURE Run*;
    VAR S: CS.Store;
  BEGIN
    S := CS.S;
    runSystemLeader(S.ledSetpointLeader, S.ledMeasuredLeader);
    runSystemFollower(S.ledSetpointFollower, S.ledMeasuredFollower)
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {CS.LedSetpointLeaderId, CS.LedSetpointFollowerId, CS.LedMeasuredId};
  Manifest.O := {};
  Manifest.P := {};
  Manifest.Cx := {};
  Manifest.Px := {}
END ActuateSystem.
