MODULE S;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure6
  Secure program
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, S0, Secure;

  CONST NSimageAddr = 010080000H;


BEGIN
  Secure.StartNonSecProg(NSimageAddr, 0)
END S.
