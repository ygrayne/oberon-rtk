MODULE QMI;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  QSPI Memory Interface QMI
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, SYS := QMI_SYS, Errors, Bootrom;

  CONST
    SectorSize* = Bootrom.FlashSectorSize;
    AtranPaneSize* = SYS.QMI_ATRAN_PANESIZE;
    XIP_BASE = BASE.FLASH_BASE;


  PROCEDURE SetAtran*(pane, size, base: INTEGER);
    VAR addr, val: INTEGER;
  BEGIN
    addr := SYS.QMI_ATRANS0 + (pane * SYS.QMI_ATRANS_Offset);
    val := 0;
    BFI(val, 23, 16, size);
    BFI(val, 11, 0, base);
    SYSTEM.PUT(addr, val)
  END SetAtran;


  PROCEDURE SetAddrTranslation*(codeBaseAddr, flashAddr, size: INTEGER);
  (*
    codeBaseAddr: linker base address
    flashAddr: physical address in flash, as per partition table, or zero without partitions
    size: code window size, as per partition table, or full flash size without
  *)
    VAR base, pane: INTEGER;
  BEGIN
    (* all must align with flash sector size boundaries *)
    ASSERT(codeBaseAddr MOD SectorSize = 0, Errors.AlignmentError);
    ASSERT(flashAddr MOD SectorSize = 0, Errors.AlignmentError);
    ASSERT(size MOD SectorSize = 0, Errors.AlignmentError);

    codeBaseAddr := codeBaseAddr - XIP_BASE;
    pane := codeBaseAddr DIV AtranPaneSize;
    codeBaseAddr := ORD(BITS(codeBaseAddr) - {22, 23});
    base := flashAddr - codeBaseAddr;
    base := base DIV SectorSize;;
    size := size DIV SectorSize;
    SetAtran(pane, size, base)
  END SetAddrTranslation;


  (* Secure/Non-secure, RP2350 only *)

  PROCEDURE GetDevSec*(VAR reg: INTEGER);
  BEGIN
    reg := SYS.QMI_SEC_reg
  END GetDevSec;

END QMI.


