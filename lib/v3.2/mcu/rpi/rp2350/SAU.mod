MODULE SAU;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Security Attribution Unit
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, ASM;

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
    SYSTEM.GET(PPB.SAU_CTRL, val);
    SYSTEM.PUT(PPB.SAU_CTRL, val + {0} - {1});
    SYSTEM.EMIT(ASM.DSB);
    SYSTEM.EMIT(ASM.ISB)
  END Enable;


  PROCEDURE* Disable*;
  (* disable SAU, set ALLNS = 0 *)
    VAR val: SET;
  BEGIN
    SYSTEM.GET(PPB.SAU_CTRL, val);
    SYSTEM.PUT(PPB.SAU_CTRL, val - {0} - {1});
    SYSTEM.EMIT(ASM.DSB);
    SYSTEM.EMIT(ASM.ISB)
  END Disable;


  PROCEDURE* DisableAllNonSecure*;
  (* disable SAU, set ALLNS = 1 *)
    VAR val: SET;
  BEGIN
    SYSTEM.GET(PPB.SAU_CTRL, val);
    SYSTEM.PUT(PPB.SAU_CTRL, val - {0} + {1});
    SYSTEM.EMIT(ASM.DSB);
    SYSTEM.EMIT(ASM.ISB)
  END DisableAllNonSecure;


  PROCEDURE* ConfigRegion*(rnr: INTEGER; cfg: RegionCfg);
  (* config and enable *)
    VAR rbar, rlar: INTEGER;
  BEGIN
    rbar := LSL(LSR(cfg.baseAddr, 5), 5);
    rlar := LSL(LSR(cfg.limitAddr, 5), 5);
    BFI(rlar, 1, cfg.nsc);
    BFI(rlar, 0, 1);
    SYSTEM.PUT(PPB.SAU_RNR, rnr);
    SYSTEM.PUT(PPB.SAU_RBAR, rbar);
    SYSTEM.PUT(PPB.SAU_RLAR, rlar)
  END ConfigRegion;


  PROCEDURE* DisableRegion*(rnr: INTEGER);
  (* but leave config intact *)
    VAR rlar: SET;
  BEGIN
    SYSTEM.PUT(PPB.SAU_RNR, rnr);
    SYSTEM.GET(PPB.SAU_RLAR, rlar);
    SYSTEM.PUT(PPB.SAU_RLAR, rlar - {0})
  END DisableRegion;

END SAU.
