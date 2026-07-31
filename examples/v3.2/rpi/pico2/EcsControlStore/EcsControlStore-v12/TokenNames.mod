MODULE TokenNames;
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

  IMPORT CS;

  CONST
    TokenNameSize = 32;
    NumTokenNames = 32;

  TYPE
    TokenName = ARRAY TokenNameSize OF CHAR;

  VAR
    Names*: ARRAY NumTokenNames OF TokenName;

BEGIN
  CLEAR(Names);
  Names[CS.LedMeasuredId] := "LedMeasured";
  Names[CS.LedSetpointLeaderId] := "LedSetpoint Leader";
  Names[CS.LedSetpointFollowerId] := "LedSetpoint Follower";
  Names[CS.BlinkConfigId] := "BlinkConfig";
  Names[CS.PrintCursorId] := "PrintCursor";
  Names[CS.PrintBufId] := "PrintBuf";
  Names[CS.HeartbeatStatusId] := "HeartbeatStatus";
  Names[CS.DrainBufId] := "DrainBuf"
END TokenNames.
