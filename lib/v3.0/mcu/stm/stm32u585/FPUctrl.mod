MODULE FPUctrl;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  FPU control/mgmt
  --
  Type: Cortex-M33
  --
  IMPORTANT:
    * 'Init' needs to called from the core whose FPU shall be initialised/enabled.
    * See modules InitCoreOne and Cores.
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2024-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    (* PPB_CPACR bits & values *)
    CPACR_FPU_1 = 23;
    CPACR_FPU_0 = 20;
      (*
      FPU_NoAccess   = 00H; (* 0000, disabled *)
      FPU_PrivAccess = 05H; (* 0101, priviledged code access *)
      *)
      FPU_AllAccess  = 0FH; (* 1111, all code access *)

  PROCEDURE* Init*;
     VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.PPB_CPACR, val);
    BFI(val, CPACR_FPU_1, CPACR_FPU_0, FPU_AllAccess);
    SYSTEM.PUT(MCU.PPB_CPACR, val);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
  END Init;

END FPUctrl.
