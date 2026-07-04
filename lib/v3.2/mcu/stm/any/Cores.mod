MODULE Cores;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Core handling
  --
  STM32 MCUs don't have dedicated register to determine the current core.
  For code compatibility, module Startup writes zero at address 0 of the
  vector table => core ID = 0 can be read from there.
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB;


  PROCEDURE* GetCoreId*(VAR cid: INTEGER);
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
