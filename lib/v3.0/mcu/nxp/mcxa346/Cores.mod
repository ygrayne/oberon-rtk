MODULE Cores;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Core handling
  --
  MCU: MCX-A346
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  (*
  VAR
    runInit, runStart: PROCEDURE;
  *)

  PROCEDURE SetCoreId*(id: INTEGER);
    VAR vtor: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.PPB_VTOR, vtor);
    SYSTEM.PUT(vtor, id)
  END SetCoreId;


  PROCEDURE GetCoreId*(VAR cid: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.PPB_VTOR, cid);
    SYSTEM.GET(cid, cid)
  END GetCoreId;


  PROCEDURE* CoreId*(): INTEGER;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.PPB_VTOR, cid);
    SYSTEM.GET(cid, cid)
    RETURN cid
  END CoreId;

(*
  PROCEDURE init;
  BEGIN
    IF runInit # NIL THEN
      runInit
    END;
    runStart
  END init;


  PROCEDURE StartCoreOne*(startProc, initProc: PROCEDURE);
    CONST Core1 = 1;
  BEGIN
    runInit := initProc;
    runStart := startProc;

  END StartCoreOne;
*)
END Cores.
