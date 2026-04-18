MODULE PIO_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  PIO Programmable I/O
  PIO0, PIO1, PIO2
  datasheet 11.7, p925
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, ACCESSCTRL_SYS;

  CONST
    PIO0* = 0;
    PIO1* = 1;
    PIO2* = 2;
    SM0* = 0;
    SM1* = 1;
    SM2* = 2;
    SM3* = 3;

    PIO_all* = {0 .. 3};
    PIO_NumStateMachines* = 4;
    PIO_MaxNumInstr* = 32;

    PIO0_BASE* = BASE.PIO0_BASE;
    PIO1_BASE* = BASE.PIO1_BASE;
    PIO2_BASE* = BASE.PIO2_BASE;

    (* offsets from PIO0_BASE, PIO1_BASE, PIO2_BASE *)
    PIO_Offset*                   = PIO1_BASE - PIO0_BASE;
    PIO_CTRL_Offset*              = 0000H;
    PIO_FSTAT_Offset*             = 0004H;
    PIO_FDEBUG_Offset*            = 0008H;
    PIO_FLEVEL_Offset*            = 000CH;
    PIO_TXF0_Offset*              = 0010H;
    PIO_TXF1_Offset*              = 0014H;
    PIO_TXF2_Offset*              = 0018H;
    PIO_TXF3_Offset*              = 001CH;
    PIO_RXF0_Offset*              = 0020H;
    PIO_RXF1_Offset*              = 0024H;
    PIO_RXF2_Offset*              = 0028H;
    PIO_RXF3_Offset*              = 002CH;
    PIO_IRQ_Offset*               = 0030H;
    PIO_IRQ_FORCE_Offset*         = 0034H;
    PIO_INPUT_SYNC_BYPASS_Offset* = 0038H;
    PIO_DBG_PADOUT_Offset*        = 003CH;
    PIO_DBG_PADOE_Offset*         = 0040H;
    PIO_DBG_CFGINFO_Offset*       = 0044H;

    PIO_INSTR_MEM0_Offset*        = 0048H;
      (* MEM0 .. MEM31 *)
      (* block offset *)
      PIO_INSTR_MEM_Offset* = 4;

    PIO_SM0_Offset*               = 00C8H;
    PIO_SM0_CLKDIV_Offset*        = PIO_SM0_Offset;
    PIO_SM0_EXECCTRL_Offset*      = 00CCH;
    PIO_SM0_SHIFTCTRL_Offset*     = 00D0H;
    PIO_SM0_ADDR_Offset*          = 00D4H;
    PIO_SM0_INSTR_Offset*         = 00D8H;
    PIO_SM0_PINCTRL_Offset*       = 00DCH;
      (* SM0 .. SM3 *)
      (* block offset *)
      PIO_SM_Offset* = 018H;
      (* block register offsets *)
      PIO_SM_CLKDIV_Offset*    = 000H;
      PIO_SM_EXECCTRL_Offset*  = 004H;
      PIO_SM_SHIFTCTRL_Offset* = 008H;
      PIO_SM_ADDR_Offset*      = 00CH;
      PIO_SM_INSTR_Offset*     = 010H;
      PIO_SM_PINCTRL_Offset*   = 014H;

    PIO_RXF0_PUTGET0_Offset*      = 0128H;
    PIO_RXF0_PUTGET1_Offset*      = 012CH;
    PIO_RXF0_PUTGET2_Offset*      = 0130H;
    PIO_RXF0_PUTGET3_Offset*      = 0134H;
      (* RXF0 .. RXF3 *)
      (* block offset *)
      PIO_RXF_Offset* = 010H;
      (* block register offsets *)
      PIO_RXF_PUTGET0_Offset* = 000H;
      PIO_RXF_PUTGET1_Offset* = 004H;
      PIO_RXF_PUTGET2_Offset* = 008H;
      PIO_RXF_PUTGET3_Offset* = 00CH;

    PIO_GPIOBASE_Offset*        = 0168H;
    PIO_INTR_Offset*            = 016CH;
    PIO_IRQ0_INTE_Offset*       = 0170H;
    PIO_IRQ0_INTF_Offset*       = 0174H;
    PIO_IRQ0_INTS_Offset*       = 0178H;
    PIO_IRQ1_INTE_Offset*       = 017CH;
    PIO_IRQ1_INTF_Offset*       = 0180H;
    PIO_IRQ1_INTS_Offset*       = 0184H;

    (* reset *)
    PIO_RST_reg* = RESETS_SYS.RESETS_RESET;
    PIO0_RST_pos* = RESETS_SYS.RESETS_PIO0;
    PIO1_RST_pos* = RESETS_SYS.RESETS_PIO1;
    PIO2_RST_pos* = RESETS_SYS.RESETS_PIO2;

    (* secure *)
    PIO0_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_PIO0;
    PIO1_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_PIO1;
    PIO2_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_PIO2;


END PIO_DEV.
