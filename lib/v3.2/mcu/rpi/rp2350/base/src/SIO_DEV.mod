MODULE SIO_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  SIO
  datasheet 3.1.11, p54
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE;

  CONST
    SIO_BASE*     = BASE.SIO_BASE;
    SIO_NS_BASE*  = BASE.SIO_NS_BASE;

    GPIOA* = SIO_BASE + 004H; (* low bank *)
    GPIOB* = SIO_BASE + 008H; (* high bank *)
    PORTA* = GPIOA;
    PORTB* = GPIOB;

    SIO_CPUID*              = SIO_BASE;
    SIO_GPIO_IN*            = SIO_BASE + 00004H;
    SIO_GPIO_HI_IN*         = SIO_BASE + 00008H;

    SIO_GPIO_OUT*           = SIO_BASE + 00010H;
    SIO_GPIO_HI_OUT*        = SIO_BASE + 00014H;
    SIO_GPIO_OUT_SET*       = SIO_BASE + 00018H;
    SIO_GPIO_HI_OUT_SET*    = SIO_BASE + 0001CH;
    SIO_GPIO_OUT_CLR*       = SIO_BASE + 00020H;
    SIO_GPIO_HI_OUT_CLR*    = SIO_BASE + 00024H;
    SIO_GPIO_OUT_XOR*       = SIO_BASE + 00028H;
    SIO_GPIO_HI_OUT_XOR*    = SIO_BASE + 0002CH;

    SIO_GPIO_OE*            = SIO_BASE + 00030H;
    SIO_GPIO_HI_OE*         = SIO_BASE + 00034H;
    SIO_GPIO_OE_SET*        = SIO_BASE + 00038H;
    SIO_GPIO_HI_OE_SET*     = SIO_BASE + 0003CH;
    SIO_GPIO_OE_CLR*        = SIO_BASE + 00040H;
    SIO_GPIO_HI_OE_CLR*     = SIO_BASE + 00044H;
    SIO_GPIO_OE_XOR*        = SIO_BASE + 00048H;
    SIO_GPIO_HI_OE_XOR*     = SIO_BASE + 0004CH;

    SIO_FIFO_ST*            = SIO_BASE + 00050H;
    SIO_FIFO_WR*            = SIO_BASE + 00054H;
    SIO_FIFO_RD*            = SIO_BASE + 00058H;
    SIO_SPINLOCK_ST*        = SIO_BASE + 0005CH;


    (* offsets from GPIOA and GPIOB *)

    SIO_GPIO_IN_Offset*       = 0000H;  (*  0 + 4 =  4 004H *) (*  0 + 8 =  8 008H *)
    SIO_GPIO_OUT_Offset*      = 000CH;  (* 12 + 4 = 16 010H *) (* 12 + 8 = 20 014H *)
    SIO_GPIO_OUT_SET_Offset*  = 0014H;  (* 20 + 4 = 24 018H *) (* 20 + 8 = 28 01CH *)
    SIO_GPIO_OUT_CLR_Offset*  = 001CH;  (* 28 + 4 = 32 020H *) (* 28 + 8 = 36 024H *)
    SIO_GPIO_OUT_XOR_Offset*  = 0024H;  (* 36 + 4 = 40 028H *) (* 36 + 8 = 44 02CH *)
    SIO_GPIO_OE_Offset*       = 002CH;  (* 44 + 4 = 48 030H *) (* 44 + 8 = 52 034H *)
    SIO_GPIO_OE_SET_Offset*   = 0034H;  (* 52 + 4 = 56 038H *) (* 52 + 8 = 60 03CH *)
    SIO_GPIO_OE_CLR_Offset*   = 003CH;  (* 60 + 4 = 64 040H *) (* 60 + 8 = 68 044H *)
    SIO_GPIO_OE_XOR_Offset*   = 0044H;  (* 68 + 4 = 72 048H *) (* 68 + 8 = 76 04CH *)

    SIO_INTERP0_ACCUM0*     = SIO_BASE + 00080H;
    SIO_INTERP0_ACCUM1*     = SIO_BASE + 00084H;
    SIO_INTERP0_BASE0*      = SIO_BASE + 00088H;
    SIO_INTERP0_BASE1*      = SIO_BASE + 0008CH;
    SIO_INTERP0_BASE2*      = SIO_BASE + 00090H;
    SIO_INTERP0_POP_LANE0*  = SIO_BASE + 00094H;
    SIO_INTERP0_POP_LANE1*  = SIO_BASE + 00098H;
    SIO_INTERP0_POP_FULL*   = SIO_BASE + 0009CH;
    SIO_INTERP0_PEEK_LANE0* = SIO_BASE + 000A0H;
    SIO_INTERP0_PEEK_LANE1* = SIO_BASE + 000A4H;
    SIO_INTERP0_PEEK_FULL*  = SIO_BASE + 000A8H;
    SIO_INTERP0_CTRL_LANE0* = SIO_BASE + 000ACH;
    SIO_INTERP0_CTRL_LANE1* = SIO_BASE + 000B0H;
    SIO_INTERP0_ACCUM0_ADD* = SIO_BASE + 000B4H;
    SIO_INTERP0_ACCUM1_ADD* = SIO_BASE + 000B8H;
    SIO_INTERP0_BASE_1AND0* = SIO_BASE + 000BCH;
      (* INTERP0 .. INTERP1 *)
      (* block offset *)
      SIO_INTERP_Offset* = 040H;
      (* block register offsets *)
      SIO_INTERP_ACCUM0_Offset*     = 000H;
      SIO_INTERP_ACCUM1_Offset*     = 004H;
      SIO_INTERP_BASE0_Offset*      = 008H;
      SIO_INTERP_BASE1_Offset*      = 00CH;
      SIO_INTERP_BASE2_Offset*      = 010H;
      SIO_INTERP_POP_LANE0_Offset*  = 014H;
      SIO_INTERP_POP_LANE1_Offset*  = 018H;
      SIO_INTERP_POP_FULL_Offset*   = 01CH;
      SIO_INTERP_PEEK_LANE0_Offset* = 020H;
      SIO_INTERP_PEEK_LANE1_Offset* = 024H;
      SIO_INTERP_PEEK_FULL_Offset*  = 028H;
      SIO_INTERP_CTRL_LANE0_Offset* = 02CH;
      SIO_INTERP_CTRL_LANE1_Offset* = 030H;
      SIO_INTERP_ACCUM0_ADD_Offset* = 034H;
      SIO_INTERP_ACCUM1_ADD_Offset* = 038H;
      SIO_INTERP_BASE_1AND0_Offset* = 03CH;

    SIO_SPINLOCK0*  = SIO_BASE + 00100H;
      (* SPINLOCK0 to SPINLOCK 31 *)
      (* block offset *)
      SIO_SPINLOCK_Offset* = 4;

    SIO_DOORBELL_OUT_SET*     = SIO_BASE + 00180H;
    SIO_DOORBELL_OUT_CLR*     = SIO_BASE + 00184H;
    SIO_DOORBELL_IN_SET*      = SIO_BASE + 00188H;
    SIO_DOORBELL_IN_CLR*      = SIO_BASE + 0018CH;
    SIO_PERI_NONSEC*          = SIO_BASE + 00190H;
    SIO_RISCV_SOFTIRQ*        = SIO_BASE + 001A0H;
    SIO_MTIME_CTRL*           = SIO_BASE + 001A4H;
    SIO_MTIME*                = SIO_BASE + 001B0H;
    SIO_MTIMEH*               = SIO_BASE + 001B4H;
    SIO_MTIMECMP*             = SIO_BASE + 001B8H;
    SIO_MTIMECMPH*            = SIO_BASE + 001BCH;
    SIO_TMDS_CTRL*            = SIO_BASE + 001C0H;
    SIO_TMDS_WDATA*           = SIO_BASE + 001C4H;
    SIO_TMDS_PEEK_SINGLE*     = SIO_BASE + 001C8H;
    SIO_TMDS_POP_SINGLE*      = SIO_BASE + 001CCH;
    SIO_TMDS_PEEK_DOUBLE_L0*  = SIO_BASE + 001D0H;
    SIO_TMDS_POP_DOUBLE_L0*   = SIO_BASE + 001D4H;
    SIO_TMDS_PEEK_DOUBLE_L1*  = SIO_BASE + 001D8H;
    SIO_TMDS_POP_DOUBLE_L1*   = SIO_BASE + 001DCH;
    SIO_TMDS_PEEK_DOUBLE_L2*  = SIO_BASE + 001E0H;
    SIO_TMDS_POP_DOUBLE_L2*   = SIO_BASE + 001E4H;

END SIO_DEV.
