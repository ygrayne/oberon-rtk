(*! SEC *)
MODULE S0;
(**
  Oberon RTK Framework v3.0
  --
  Exploration program Secure3
  https://oberon-rtk.org/docs/examples/v3/secure3/
  Secure module, used from Secure and Non-secure program
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  PROCEDURE* ToggleLED*(led: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, {led});

    (* manually inserted Secure epilogue *)
    (* no add sp,#n as leaf procedure *)
    SYSTEM.EMIT(MCU.POP_LR);
    SYSTEM.EMITH(MCU.BXNS_LR) (* ok within Secure code *)
  END ToggleLED;

END S0.
