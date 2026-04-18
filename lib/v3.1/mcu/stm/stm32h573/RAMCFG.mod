MODULE RAMCFG;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Embedded SRAM configuration controller driver
  --
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYS := RAMCFG_SYS, RST;


  PROCEDURE* GetDevSec*(VAR reg, pos: INTEGER);
  BEGIN
    reg := SYS.RAMCFG_SEC_reg;
    pos := SYS.RAMCFG_SEC_pos
  END GetDevSec;


  PROCEDURE enable;
  (* enable bus clock *)
  BEGIN
    RST.EnableBusClock(SYS.RAMCFG_BC_reg, SYS.RAMCFG_BC_pos)
  END enable;

BEGIN
  enable
END RAMCFG.
