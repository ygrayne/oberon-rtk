(*! SEC *)
MODULE S0;
(**
  Oberon RTK Framework v3.0
  --
  Exploration program Secure2
  https://oberon-rtk.org/docs/examples/v3/secure2/
  Secure module, used from Secure and Non-secure program
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  (* "real" procedure *)
  (*
  PROCEDURE* ToggleLED*(led: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, {led})
  END ToggleLED
  *)

  (*
  (* as required by the dispatch handler *)
  PROCEDURE* ToggleLED*(led, x, y, z: INTEGER): INTEGER;
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, {led});
    RETURN led
  END ToggleLED;
  *)

  PROCEDURE ToggleLED*(led: INTEGER);
    (*VAR r0, r1, r2, r3: INTEGER;*)
  BEGIN
    (*
    r0 := SYSTEM.REG(0);
    r1 := SYSTEM.REG(1);
    r2 := SYSTEM.REG(2);
    r3 := SYSTEM.REG(3);
    Out.Int(r0, 4);
    Out.Int(r1, 4);
    Out.Int(r2, 4);
    Out.Int(r3, 4);
    Out.Ln;
    *)
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, {led})
  END ToggleLED;

END S0.
