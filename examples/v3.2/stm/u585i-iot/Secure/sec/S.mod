MODULE S;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure
  Secure program
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, S0, Secure; (* unsed S0, needs to be includeded in the program *)

  CONST
    (* Non-secure program flash address *)
    NSimageAddr = 08100000H;
    VTORoffset  = 0000H;

BEGIN
  Secure.StartNonSecProg(NSimageAddr, VTORoffset)
END S.
