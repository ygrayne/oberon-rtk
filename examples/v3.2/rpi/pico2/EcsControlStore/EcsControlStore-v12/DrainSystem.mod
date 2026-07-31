MODULE DrainSystem;
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

  IMPORT CS, CL, UARTdrain, DrainBuffers, Kernel;

  CONST
    SystemName = "Drain";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;


  PROCEDURE runSystem;
    VAR drainHandle, uartHandle: INTEGER; ch: CHAR;
  BEGIN
    drainHandle := CL.drainBuf.devHandle;
    uartHandle := CL.uartBinding.devHandle;
    WHILE ~(DrainBuffers.Empty(drainHandle) OR UARTdrain.Full(uartHandle)) DO
      DrainBuffers.Get(drainHandle, ch);
      UARTdrain.Put(uartHandle, ch)
    END
  END runSystem;


  PROCEDURE Run*;
  BEGIN
    runSystem
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {CS.DrainBufId};
  Manifest.O := {};
  Manifest.P := {};
  Manifest.Cx := {};
  Manifest.Px := {}
END DrainSystem.

