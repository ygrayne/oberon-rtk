MODULE S;
(**
  Oberon RTK Framework v3.2
  --
  Test program Secure
  Secure program
  No flash partitions
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, S0, Secure;

  CONST
    NSimageAddr = 010080000H; (* linker base address *)
    VTORoffset = 0000H;


  PROCEDURE fail;
  BEGIN
    ASSERT(FALSE)
  END fail;

  PROCEDURE fail0;
  BEGIN
    fail
  END fail0;

BEGIN
  (*fail0;*)
  Secure.StartNonSecProg(NSimageAddr, VTORoffset)
END S.
