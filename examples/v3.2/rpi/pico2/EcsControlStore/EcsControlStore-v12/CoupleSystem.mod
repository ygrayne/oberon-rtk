MODULE CoupleSystem;
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

  IMPORT CS, CL, Kernel;

  CONST
    SystemName = "Couple";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;


  PROCEDURE runSystem(lma: ARRAY OF CS.LedMeasured; VAR lsa: ARRAY OF CS.LedSetpoint);
    VAR i, follows: INTEGER;
  BEGIN
    i := 0;
    WHILE i < LEN(lsa) DO
      follows := CL.ledFollower[i].follows;
      lsa[i].value := lma[follows].value;
      INC(i)
    END
  END runSystem;


  PROCEDURE Run*;
    VAR S: CS.Store;
  BEGIN
    S := CS.S;
    runSystem(S.ledMeasuredLeader, S.ledSetpointFollower)
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {CS.LedMeasuredId};
  Manifest.O := {};
  Manifest.P := {CS.LedSetpointFollowerId};
  Manifest.Cx := {};
  Manifest.Px := {}
END CoupleSystem.
