MODULE HeartbeatSystem;
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

  IMPORT CS, CL, I, Texts, PrintBuffers, TIMER, Kernel;

  CONST
    SystemName = "Heartbeat";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;


  PROCEDURE runSystem(VAR hbs: CS.HeartbeatStatus; VAR pbs: ARRAY OF CS.PrintBuf);
    VAR
      now, delta, writerHandle: INTEGER;
  BEGIN
    writerHandle := CL.printWriter[I.Printer_Heartbeat].writerHandle;
    PrintBuffers.Reset(CL.printBuf[I.Printer_Heartbeat].devHandle);
    TIMER.GetTimeL(CL.timerBinding.devHandle, now);
    delta := now - hbs.last;
    hbs.last := now;
    INC(hbs.count);
    Texts.WriteString(writerHandle, SystemName);
    Texts.WriteInt(writerHandle, hbs.count, 12);
    Texts.WriteInt(writerHandle, now, 12);
    Texts.WriteInt(writerHandle, delta, 10);
    Texts.WriteLn(writerHandle);
    INC(pbs[I.Printer_Heartbeat].seq)
  END runSystem;


  PROCEDURE Run*;
    VAR S: CS.Store;
  BEGIN
    S := CS.S;
    runSystem(S.heartbeatStatus, S.printBuf)
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {};
  Manifest.O := {CS.HeartbeatStatusId};
  Manifest.P := {};
  Manifest.Cx := {};
  Manifest.Px := {CS.PrintBufId}
END HeartbeatSystem.
