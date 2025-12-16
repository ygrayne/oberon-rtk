MODULE MPU;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Memory protection unit
  --
  Type: Cortex-M33
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* MAIR0, MAIR1 *)
    (* normal memory not cacheable *)
    NotCacheable* = {2};

    (* normal memory cacheable: OR write policy, transient mode, allocation * *)
    (* write policy *)
    WriteThrough*   = {};
    WriteBack*      = {2};
    (* transient mode *)
    Transient*      = {};
    NonTransient*   = {3};
    (* cache allocation *)
    NoAlloc*        = {};
    WriteAlloc*     = {0};
    ReadAlloc*      = {1};
    ReadWriteAlloc* = {0, 1};

    (* device memory *)
    DeviceNGNRNE* = {};   (* non-Gathering, non-Reordering, no Early write acknowledgement *)
    DeviceNGNRE* = {2};   (* non-Gathering, non-Reordering, Early write acknowledgement *)
    DeviceNGRE* = {3};    (* non-Gathering, Reordering, Early write acknowledgement *)
    DeviceGRE* = {2, 3};  (* Gathering, Reordering, Early write acknowledgement *)

    (* basic regions *)
    AttrFlash* = WriteThrough + NonTransient + ReadAlloc;
    AttrSRAM* = NotCacheable;
    AttrDevices* = DeviceNGNRE;

    (* ap *)
    AccessRWpriv* = 0;
    AccessRWall* = 1;
    AccessROpriv* = 2;
    AccessROall* = 3;

    (* sh *)
    ShareNone*  = 0;
    ShareOuter* = 2;
    ShareInner* = 3;

    (* xn *)
    ExecEnabled*  = 0;
    ExecDisabled* = 1;


  TYPE
    Region* = RECORD
      rbar*, rlar*: INTEGER;
      base*, sh*, ap*, xn*: INTEGER;
      limit*, ai*, en*: INTEGER
    END;

    RegionCfg* = RECORD
      base*, sh*, ap*, xn*: INTEGER;
      limit*, ai*: INTEGER
    END;


  PROCEDURE* GetNumRegions*(VAR num: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.PPB_MPU_TYPE, num);
    num := BFX(num, 15, 8)
  END GetNumRegions;


  PROCEDURE* GetRegion*(ri: INTEGER; VAR region: Region);
  BEGIN
    SYSTEM.PUT(MCU.PPB_MPU_RNR, ri);
    SYSTEM.GET(MCU.PPB_MPU_RBAR, region.rbar);
    region.base := BFX(region.rbar, 31, 5) * 32;
    region.sh := BFX(region.rbar, 4, 3);
    region.ap := BFX(region.rbar, 2, 1);
    region.xn := BFX(region.rbar, 0);
    SYSTEM.GET(MCU.PPB_MPU_RLAR, region.rlar);
    region.limit := (BFX(region.rlar, 31, 5) * 32) + 01FH;
    region.ai := BFX(region.rlar, 3, 1);
    region.en := BFX(region.rlar, 0);
  END GetRegion;


  PROCEDURE* SetRegion*(rnr: INTEGER; cfg: RegionCfg);
    VAR rbar, rlar: INTEGER;
  BEGIN
    rbar := LSL(cfg.base DIV 32, 5);
    rbar := rbar + LSL(cfg.sh, 3);
    rbar := rbar + LSL(cfg.ap, 1);
    rbar := rbar + cfg.xn;

    rlar := LSL((cfg.limit) DIV 32, 5);
    rlar := rlar + LSL(cfg.ai, 1);
    rlar := rlar + 1;

    SYSTEM.PUT(MCU.PPB_MPU_RNR, rnr);
    SYSTEM.PUT(MCU.PPB_MPU_RBAR, rbar);
    SYSTEM.PUT(MCU.PPB_MPU_RLAR, rlar)

  END SetRegion;


  PROCEDURE* SetAttribute*(ai: INTEGER; outer, inner: SET);
    VAR addr: INTEGER; val, attr: INTEGER;
  BEGIN
    addr := MCU.PPB_MPU_MAIR0 + (ai DIV 4) * 4;
    attr := LSL(ORD(outer), 4) + ORD(inner);
    SYSTEM.GET(addr, val);
    SYSTEM.PUT(addr, val + LSL(attr, (ai MOD 4) * 8))
  END SetAttribute;


  PROCEDURE* Enable*;
  BEGIN
    SYSTEM.PUT(MCU.PPB_MPU_CTRL, {0})
  END Enable;

END MPU.
