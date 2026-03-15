MODULE SAU;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Security Attribution Unit
  --
  Type: Cortex-M33
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    NumRegions* = 8;

  TYPE
    RegionCfg* = RECORD
      baseAddr*: INTEGER;
      limitAddr*: INTEGER;
      nsc*: INTEGER
    END;


  PROCEDURE* Enable*;
  (* enable SAU, set ALLNS = 0 *)
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_SAU_CTRL, val);
    SYSTEM.PUT(MCU.PPB_SAU_CTRL, val + {0} - {1});
    SYSTEM.EMIT(MCU.DSB);
    SYSTEM.EMIT(MCU.ISB)
  END Enable;


  PROCEDURE* Disable*;
  (* disable SAU, set ALLNS = 0 *)
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_SAU_CTRL, val);
    SYSTEM.PUT(MCU.PPB_SAU_CTRL, val - {0} - {1});
    SYSTEM.EMIT(MCU.DSB);
    SYSTEM.EMIT(MCU.ISB)
  END Disable;


  PROCEDURE* DisableAllNonSecure*;
  (* disable SAU, set ALLNS = 1 *)
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_SAU_CTRL, val);
    SYSTEM.PUT(MCU.PPB_SAU_CTRL, val - {0} + {1});
    SYSTEM.EMIT(MCU.DSB);
    SYSTEM.EMIT(MCU.ISB)
  END DisableAllNonSecure;


  PROCEDURE* ConfigRegion*(rnr: INTEGER; cfg: RegionCfg);
  (* config and enable *)
    VAR rbar, rlar: INTEGER;
  BEGIN
    rbar := LSL(LSR(cfg.baseAddr, 5), 5);
    rlar := LSL(LSR(cfg.limitAddr, 5), 5);
    BFI(rlar, 1, cfg.nsc);
    BFI(rlar, 0, 1);
    SYSTEM.PUT(MCU.PPB_SAU_RNR, rnr);
    SYSTEM.PUT(MCU.PPB_SAU_RBAR, rbar);
    SYSTEM.PUT(MCU.PPB_SAU_RLAR, rlar)
  END ConfigRegion;


  PROCEDURE* DisableRegion*(rnr: INTEGER);
  (* but leave config intact *)
    VAR rlar: SET;
  BEGIN
    SYSTEM.PUT(MCU.PPB_SAU_RNR, rnr);
    SYSTEM.GET(MCU.PPB_SAU_RLAR, rlar);
    SYSTEM.PUT(MCU.PPB_SAU_RLAR, rlar - {0})
  END DisableRegion;

END SAU.
