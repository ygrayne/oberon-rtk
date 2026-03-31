MODULE Cores;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Core handling
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB;


  PROCEDURE* GetCoreId*(VAR cid: INTEGER);
  (* set in StartupCfg *)
  BEGIN
    SYSTEM.GET(PPB.VTOR, cid);
    SYSTEM.GET(cid, cid)
  END GetCoreId;


  PROCEDURE* CoreId*(): INTEGER;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(PPB.VTOR, cid);
    SYSTEM.GET(cid, cid)
    RETURN cid
  END CoreId;

END Cores.
