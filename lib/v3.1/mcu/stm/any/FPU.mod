MODULE FPU;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  FPU control/mgmt
  --
  - Single-image Main: FPU.Enable
  - S-image Main: FPU.Enable; FPU.EnableNSaccess; FPU.SetSecure
  - NS-image Main: FPU.Enable (NSACR already set by S)
  --
  MCU: STM32U585AI, STM32H573II
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB;

  PROCEDURE* Enable*;
  (* Enable FPU: full access. Called from every image (S, NS, single). Per-core. *)
    CONST CP10 = {20, 21}; CP11 = {22, 23};
    VAR val: SET;
  BEGIN
    SYSTEM.GET(PPB.CPACR, val);
    SYSTEM.PUT(PPB.CPACR, val + CP10 + CP11);
    (* asm
      dsb
      isb
    end asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3BF8F4FH);  (* dsb *)
    SYSTEM.EMIT(0F3BF8F6FH);  (* isb *)
    (* -asm *)
  END Enable;


  PROCEDURE* EnableNSaccess*;
  (* Allow Non-secure FPU access. Called from S only, before starting NS. Per-core. *)
    CONST CP10 = 10; CP11 = 11;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(PPB.NSACR, val);
    SYSTEM.PUT(PPB.NSACR, val + {CP10, CP11})
  END EnableNSaccess;


  PROCEDURE* SetSecure*;
  (* Full FP security hardening. Called from S only. Per-core. *)
    CONST TS = 26; CLRONRETS = 27; CLRONRET = 28; LSPENS = 29;
    VAR val: SET;
  BEGIN
    SYSTEM.GET(PPB.FPCCR, val);
    SYSTEM.PUT(PPB.FPCCR, val + {TS, CLRONRETS, CLRONRET, LSPENS})
  END SetSecure;

END FPU.
