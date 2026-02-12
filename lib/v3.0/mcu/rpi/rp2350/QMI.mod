MODULE QMI;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  QSPI Memory Interface QMI
  --
  Type: Cortex-M33
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;

  CONST
    SectorSize* = 01000H; (* 4k *)
    PaneSize* = 0400000H; (* 4M *)
    XIP_BASE = MCU.FLASH_BASE;


  PROCEDURE SetAtran*(pane, size, base: INTEGER);
    VAR addr, val: INTEGER;
  BEGIN
    addr := MCU.QMI_ATRANS0 + (pane * MCU.QMI_ATRANS_Offset);
    val := 0;
    BFI(val, 23, 16, size);
    BFI(val, 11, 0, base);
    SYSTEM.PUT(addr, val)
  END SetAtran;


  PROCEDURE SetAddrTranslation*(codeBaseAddr, physAddr, size: INTEGER);
  (*
    codeBaseAddr: linker base address
    physAddr: physical address in flash, as per partition table, or zero without partitions
    size: code window size, as per partition table, or full flash size without
    note: this should probably work on sectors to begin with
  *)
    VAR base, pane: INTEGER;
  BEGIN
    ASSERT(codeBaseAddr MOD SectorSize = 0, Errors.AlignmentError);
    ASSERT(physAddr MOD SectorSize = 0, Errors.AlignmentError);
    ASSERT(size MOD SectorSize = 0, Errors.AlignmentError);

    pane := (codeBaseAddr - XIP_BASE) DIV PaneSize;
    (*Out.String("pane"); Out.Hex(pane, 12); Out.Ln;*)

    (*Out.String("code"); Out.Hex(codeBaseAddr, 12);*)
    codeBaseAddr := codeBaseAddr - XIP_BASE;
    (*Out.Hex(codeBaseAddr, 12);*)

    codeBaseAddr := ORD(BITS(codeBaseAddr) - {22, 23});
    (*Out.Hex(codeBaseAddr, 12); Out.Ln;*)

    base := physAddr - codeBaseAddr;
    (*Out.String("base"); Out.Hex(base, 12);*)
    base := base DIV SectorSize;;
    (*Out.Hex(base, 12); Out.Ln;*)

    (*Out.String("size"); Out.Hex(size, 12);*)
    size := size DIV SectorSize;
    (*Out.Hex(size, 12); Out.Ln;*)

    SetAtran(pane, size, base)
  END SetAddrTranslation;


END QMI.

(*
  No partitions, ie. physical address = XIP_BASE => virtual addr = 0

  ATRANS0.SIZE = 400H
  ATRANS0.BASE = 000H

  ATRANS1.SIZE = 400H
  ATRANS1.BASE = 400H

  ATRANS2.SIZE = 400H
  ATRANS2.BASE = 800H

  ATRANS3.SIZE = 400H
  ATRANS3.BASE = C00H

*)
