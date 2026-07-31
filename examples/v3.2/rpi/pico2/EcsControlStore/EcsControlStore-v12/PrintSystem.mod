MODULE PrintSystem;
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

  IMPORT CS, CL, PrintBuffers, DrainBuffers, Kernel;

  CONST
    SystemName = "Print";

  VAR
    Manifest*: Kernel.Manifest;
    Name*: Kernel.SystemName;

    (* uncomment for TickMonitor trigger *)
    (*
    debug_NoRuns: INTEGER;
    *)

  PROCEDURE runSystem(printb: ARRAY OF CS.PrintBuf; VAR printc: ARRAY OF CS.PrintCursor);
    VAR
      drainHandle: INTEGER;
      buf: ARRAY PrintBuffers.BufSize OF CHAR; numChar, i, id: INTEGER;
  BEGIN
    drainHandle := CL.drainBuf.devHandle;
    id := 0;
    WHILE id < LEN(printb) DO
      IF printb[id].seq # printc[id].seqDone THEN
        PrintBuffers.GetString(CL.printBuf[id].devHandle, buf, numChar);
        i := 0;
        WHILE ~DrainBuffers.Full(drainHandle) & (i < numChar) DO
          DrainBuffers.Put(drainHandle, buf[i]); INC(i)
        END;
        printc[id].seqDone := printb[id].seq
      END;
      INC(id)
    END
  END runSystem;


  PROCEDURE Run*;
    VAR
      S: CS.Store;
      (* uncomment for TickMonitor trigger *)
      (*
      i: INTEGER;
      *)

  BEGIN
    S := CS.S;
    runSystem(S.printBuf, S.printCursor);

    (* debug/test: create sys tick overrun *)
    (* uncomment to trigger TickMonitor *)
    (*
    INC(debug_NoRuns);
    IF debug_NoRuns MOD 17 = 0 THEN
      i := 0;
      WHILE i < 1000000 DO INC(i) END;
    END;
    *)
    (* debug/test *)
  END Run;

BEGIN
  Name := SystemName;
  Manifest.C := {};
  Manifest.O := {CS.PrintCursorId};
  Manifest.P := {CS.DrainBufId};
  Manifest.Cx := {CS.PrintBufId};
  Manifest.Px := {};
  (* debug/test *)
  (* uncomment for TickMonitor trigger *)
  (*
  debug_NoRuns := 0
  *)
END PrintSystem.
