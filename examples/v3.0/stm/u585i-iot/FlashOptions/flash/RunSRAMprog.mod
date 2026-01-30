MODULE RunSRAMprog;
(**
  Oberon RTK Framework v3.0
  --
  Run a program in SRAM1, image at 0E000000H, ie. entry address at 0E000004H
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main;

  CONST
    PCaddr = 0E000004H; (* in SRAM1, secure *)

  PROCEDURE run;
    VAR pc: INTEGER;
  BEGIN
    SYSTEM.GET(PCaddr, pc);
    SYSTEM.LDREG(11, pc);
    SYSTEM.EMITH(04758H) (* bx r11 *)
  END run;

BEGIN
  run
END RunSRAMprog.
