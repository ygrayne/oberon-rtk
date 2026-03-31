MODULE FPU;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  FPU control/mgmt
  --
  Type: Cortex-M33
  --
  - Single-image Main: FPU.Init
  - S-image Main: FPU.Init; FPU.EnableNSaccess; FPU.SetSecure
  - NS-image Main: FPU.Init (NSACR already set by S)
  --
  MCU: RP2350A
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  PROCEDURE* Init*;
  (* Enable FPU: full access. Called from every image (S, NS, single). Per-core. *)
    CONST CP10 = {20, 21}; CP11 = {22, 23};
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_CPACR, val);
    SYSTEM.PUT(MCU.PPB_CPACR, val + CP10 + CP11);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
  END Init;


  PROCEDURE* EnableNSaccess*;
  (* Allow Non-secure FPU access. Called from S only, before starting NS. Per-core. *)
    CONST CP10 = 10; CP11 = 11;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_NSACR, val);
    SYSTEM.PUT(MCU.PPB_NSACR, val + {CP10, CP11})
  END EnableNSaccess;


  PROCEDURE* SetSecure*;
  (* Full FP security hardening. Called from S only. Per-core. *)
    CONST TS = 26; CLRONRETS = 27; CLRONRET = 28; LSPENS = 29;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_FPCCR, val);
    SYSTEM.PUT(MCU.PPB_FPCCR, val + {TS, CLRONRETS, CLRONRET, LSPENS})
  END SetSecure;

END FPU.
