MODULE TickMonitorSystem;
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

  IMPORT CS, CL, I, Texts, PrintBuffers, Kernel;

  CONST
    SystemName = "TickMonitor";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;


  PROCEDURE runSystem(VAR pbs: ARRAY OF CS.PrintBuf);
    VAR
      writerHandle: INTEGER;
  BEGIN
    IF Kernel.ElapsedTicks > 1 THEN
      writerHandle := CL.printWriter[I.Printer_TickMonitor].writerHandle;
      PrintBuffers.Reset(CL.printBuf[I.Printer_TickMonitor].devHandle);
      Texts.WriteString(writerHandle, SystemName);
      Texts.WriteInt(writerHandle, Kernel.ElapsedTicks, 12);
      Texts.WriteInt(writerHandle, Kernel.MissedTicks, 12);
      Texts.WriteInt(writerHandle, Kernel.TickCount, 12);
      Texts.WriteLn(writerHandle);
      INC(pbs[I.Printer_TickMonitor].seq)
    END
  END runSystem;


  PROCEDURE Run*;
    VAR S: CS.Store;
  BEGIN
    S := CS.S;
    runSystem(S.printBuf)
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {};
  Manifest.O := {};
  Manifest.P := {};
  Manifest.Cx := {};
  Manifest.Px := {CS.PrintBufId}
END TickMonitorSystem.
