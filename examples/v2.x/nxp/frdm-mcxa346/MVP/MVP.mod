MODULE MVP;
(**
  Oberon RTK Framework v2.x
  --
  Minimal Viable Program
  --
  MCU: MCX-A346
  Board: FRDM-MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main;

  CONST
    MRCC_BASE = 040091000H;
    MRCC_GLB_RST1_SET = MRCC_BASE + 024H; (* reset release for PORT, bit 15 *)
    MRCC_GLB_RST2_SET = MRCC_BASE + 020H; (* reset release for GPIO3, bit 7 *)
    MRCC_GLB_CC1_SET  = MRCC_BASE + 054H; (* clock enable for PORT3, bit 15 *)
    MRCC_GLB_CC2_SET  = MRCC_BASE + 064H; (* clock enable for GPIO3, bit 7 *)

    RGPIO3_BASE = 40105000H;
    RGPIO3_PTOR = RGPIO3_BASE + 04CH;     (* toggle *)
    RGPIO3_PDDR = RGPIO3_BASE + 054H;     (* data direction, output = 1 *)


  PROCEDURE init;
  BEGIN
    SYSTEM.PUT(MRCC_GLB_RST1_SET, {15});
    SYSTEM.PUT(MRCC_GLB_RST2_SET, {7});
    SYSTEM.PUT(MRCC_GLB_CC1_SET, {15});
    SYSTEM.PUT(MRCC_GLB_CC2_SET, {7});
    SYSTEM.PUT(RGPIO3_PDDR, {19})
  END init;


  PROCEDURE run;
    VAR i: INTEGER;
  BEGIN
    REPEAT
      SYSTEM.PUT(RGPIO3_PTOR, {19});
      i := 0;
      WHILE i < 1000000 DO INC(i) END
    UNTIL FALSE
  END run;

BEGIN
  init;
  run
END MVP.
