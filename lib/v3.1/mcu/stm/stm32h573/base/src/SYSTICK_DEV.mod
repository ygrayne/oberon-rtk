MODULE SYSTICK_DEV;
(**
  MCU: STM32H573II
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT RCC_SYS;

  CONST
    (* RCC: functional clock FC *)
    SYSTICK_FC_reg* = RCC_SYS.RCC_CCIPR4;
    SYSTICK_FC_pos* = 2;
    SYSTICK_FC_width* = 2;

END SYSTICK_DEV.
