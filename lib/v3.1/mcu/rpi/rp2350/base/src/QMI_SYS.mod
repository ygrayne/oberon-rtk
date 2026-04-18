MODULE QMI_SYS;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  QMI
  datasheet 12.14.6, p1221
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, ACCESSCTRL_SYS;

  CONST
    QMI_ATRAN_PANESIZE* = 0400000H; (* 4 M *)

    XIP_QMI_BASE* = BASE.XIP_QMI_BASE;

    QMI_DIRECT_CSR*   = XIP_QMI_BASE;
    QMI_DIRECT_TX*    = XIP_QMI_BASE + 004H;
    QMI_DIRECT_RX*    = XIP_QMI_BASE + 008H;
    QMI_M0_TIMING*    = XIP_QMI_BASE + 00CH;
    QMI_M0_RFMT*      = XIP_QMI_BASE + 010H;
    QMI_M0_RCMD*      = XIP_QMI_BASE + 014H;
    QMI_M0_WFMT*      = XIP_QMI_BASE + 018H;
    QMI_M0_WCMD*      = XIP_QMI_BASE + 01CH;
    QMI_M1_TIMING*    = XIP_QMI_BASE + 020H;
    QMI_M1_RFMT*      = XIP_QMI_BASE + 024H;
    QMI_M1_RCMD*      = XIP_QMI_BASE + 028H;
    QMI_M1_WFMT*      = XIP_QMI_BASE + 02CH;
    QMI_M1_WCMD*      = XIP_QMI_BASE + 030H;
    QMI_ATRANS0*      = XIP_QMI_BASE + 034H;
    QMI_ATRANS1*      = XIP_QMI_BASE + 038H;
    QMI_ATRANS2*      = XIP_QMI_BASE + 03CH;
    QMI_ATRANS3*      = XIP_QMI_BASE + 040H;
    QMI_ATRANS4*      = XIP_QMI_BASE + 044H;
    QMI_ATRANS5*      = XIP_QMI_BASE + 048H;
    QMI_ATRANS6*      = XIP_QMI_BASE + 04CH;
    QMI_ATRANS7*      = XIP_QMI_BASE + 050H;
      QMI_ATRANS_Offset* = 4;

  (* reset PSM *)
  QMI_PSM_reg* = RESETS_SYS.PSM_DONE;
  QMI_PSM_pos* = RESETS_SYS.PSM_XIP;

  (* secure *)
  QMI_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_XIP_QMI;

END QMI_SYS.

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
