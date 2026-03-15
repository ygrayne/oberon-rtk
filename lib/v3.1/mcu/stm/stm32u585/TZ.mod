MODULE TZ;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  TrustZone Support
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    TT* = 0;
    TTT* = 1;
    TTA* = 2;
    TTAT* = 3;
    Ts = {0 .. 3};


  PROCEDURE TestTarget*(addr: INTEGER; tt: INTEGER; VAR result: INTEGER);
  (*
    E84 Rn F Rd A T 00 0
  *)
  BEGIN
    IF tt IN Ts THEN
      SYSTEM.LDREG(6, addr);
      CASE tt OF
        TT: SYSTEM.EMIT(0E846F700H)
      | TTT: SYSTEM.EMIT(0)
      | TTA: SYSTEM.EMIT(0)
      | TTAT: SYSTEM.EMIT(0)
      END;
      result := SYSTEM.REG(7)
    END
  END TestTarget;

END TZ.
