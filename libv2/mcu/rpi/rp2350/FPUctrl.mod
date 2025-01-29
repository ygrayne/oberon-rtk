MODULE FPUctrl;
(**
  Oberon RTK Framework v2
  --
  FPU control/mgmt
  --
  MCU: RP2350
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

    (* PPB_NSACR bits and values *)
    (* unused
    NSACR_FPU_1 = 23;
    NSACR_FPU_0 = 20;
      (* values as for PPB_CPACR *)
    *)

    (* PPB_FPCCR bits *)
    FPCCR_TS = 26;

  PROCEDURE Init*(nonSecAccess, treatAsSec: BOOLEAN);
     VAR x: INTEGER;
  BEGIN
    x := 0;
    BFI(x, CPACR_FPU_1, CPACR_FPU_0, FPU_AllAccess);
    SYSTEM.PUT(MCU.PPB_CPACR, x);
    IF nonSecAccess THEN
      SYSTEM.PUT(MCU.PPB_NSACR, x)
      (* not sure if NS alias of CPACR needs to be set too *)
    END;
    IF treatAsSec THEN
      SYSTEM.GET(MCU.PPB_FPCCR, x);
      BFI(x, FPCCR_TS, 1);
      SYSTEM.PUT(MCU.PPB_FPCCR, x)
    END
  END Init;

END FPUctrl.
