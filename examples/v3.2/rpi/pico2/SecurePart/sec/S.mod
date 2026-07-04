MODULE S;
(**
  Oberon RTK Framework v3.2
  --
  Test program SecurePart
  Secure program
  Using flash partitions
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, S0, Secure;

  CONST
    NScodeBaseAddr = 010400000H; (* linker base address *)
    VTORoffset = 0000H;


BEGIN
  Secure.InstallNonSecImage(NScodeBaseAddr);
  Secure.StartNonSecProg(NScodeBaseAddr, VTORoffset)
END S.
