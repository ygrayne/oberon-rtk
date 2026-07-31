MODULE BlinkSystem;
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

  IMPORT CS, Kernel;

  CONST
    SystemName = "Blink";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;


  PROCEDURE runLed(VAR bc: CS.BlinkConfig; VAR sp: CS.LedSetpoint);
  BEGIN
    DEC(bc.ticker, Kernel.ElapsedTicks);
    IF bc.ticker <= 0 THEN
      sp.value := ORD((BITS(sp.value) / {0}) * {0}); (* XOR toggle 1 bit *)
      INC(bc.ticker, bc.period)
    END
  END runLed;


  PROCEDURE runSystem(VAR cfg: ARRAY OF CS.BlinkConfig; VAR setp: ARRAY OF CS.LedSetpoint);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < LEN(setp) DO
      runLed(cfg[i], setp[i]);
      INC(i)
    END
  END runSystem;


  PROCEDURE Run*;
    VAR S: CS.Store;
  BEGIN
    S := CS.S;
    runSystem(S.blinkConfig, S.ledSetpointLeader)
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {};
  Manifest.O := {CS.BlinkConfigId};
  Manifest.P := {CS.LedSetpointLeaderId};
  Manifest.Cx := {};
  Manifest.Px := {}
END BlinkSystem.
