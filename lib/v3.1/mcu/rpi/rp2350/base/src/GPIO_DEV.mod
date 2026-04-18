MODULE GPIO_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  GPIO: IO_BANK0, PADS_BANK0
  datasheet 12.1.8, p958
  --
  MCU: RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS, ACCESSCTRL_SYS, SIO_DEV;

  CONST
    (* IO functions *)
    IO_BANK0_Fhstx*   = 0;
    IO_BANK0_Fspi*    = 1;
    IO_BANK0_Fuart*   = 2;
    IO_BANK0_Fi2c*    = 3;
    IO_BANK0_Fpwm*    = 4;
    IO_BANK0_Fsio*    = 5;
    IO_BANK0_Fpio0*   = 6;
    IO_BANK0_Fpio1*   = 7;
    IO_BANK0_Fpio2*   = 8;
    IO_BANK0_Fqmi*    = 9;
    IO_BANK0_Ftrc*    = 9;
    IO_BANK0_Fclk*    = 9;
    IO_BANK0_Fusb*    = 10;
    IO_BANK0_FuartAlt* = 11;
    IO_BANK0_Fnull*   = 31;   (* sets GPIO output driver to hi-z *)

    IO_BANK0_Functions* = {IO_BANK0_Fhstx .. IO_BANK0_FuartAlt, IO_BANK0_Fnull};


    (* -- PADS_BANK0 -- *)
    PADS_BANK0_BASE* = BASE.PADS_BANK0_BASE;

    PADS_BANK0_VOLTAGE_SELECT*  = PADS_BANK0_BASE;

    (* bank base & offset *)
    PADS_BANK0_GPIO0*           = PADS_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO47 *)
      PADS_BANK0_GPIO_Offset* = 4;

    PADS_BANK0_SWCLK*           = PADS_BANK0_BASE + 0C4H;
    PADS_BANK0_SWD*             = PADS_BANK0_BASE + 0C8H;

    (* reset *)
    PADS_BANK0_RST_reg* = RESETS_SYS.RESETS_RESET;
    PADS_BANK0_RST_pos* = RESETS_SYS.RESETS_PADS_BANK0;

    (* secure *)
    PADS_BANK0_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_PADS_BANK0;


    (* -- IO_BANK0 -- *)
    IO_BANK0_BASE* = BASE.IO_BANK0_BASE;

    IO_BANK0_GPIO0_STATUS*  = IO_BANK0_BASE;
    IO_BANK0_GPIO0_CTRL*    = IO_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO47 *)
      (* block offset *)
      IO_BANK0_GPIO_Offset* = 8;
      (* block register offsets *)
      IO_BANK0_GPIO_STATUS_Offset*  = 0;
      IO_BANK0_GPIO_CTRL_Offset*    = 4;

    (* note: identifiers abbreviated due to compiler name length restrictions *)
    IO_BANK0_IRQSUM_PROC0_SEC0*       = IO_BANK0_BASE + 0200H;
    IO_BANK0_IRQSUM_PROC0_SEC1*       = IO_BANK0_BASE + 0204H;
    IO_BANK0_IRQSUM_PROC0_NONSEC0*    = IO_BANK0_BASE + 0208H;
    IO_BANK0_IRQSUM_PROC0_NONSEC1*    = IO_BANK0_BASE + 020CH;
    IO_BANK0_IRQSUM_PROC1_SEC0*       = IO_BANK0_BASE + 0210H;
    IO_BANK0_IRQSUM_PROC1_SEC1*       = IO_BANK0_BASE + 0214H;
    IO_BANK0_IRQSUM_PROC1_NONSEC0*    = IO_BANK0_BASE + 0218H;
    IO_BANK0_IRQSUM_PROC1_NONSEC1*    = IO_BANK0_BASE + 021CH;
    IO_BANK0_IRQSUM_COMA_WK_SEC0*     = IO_BANK0_BASE + 0220H;
    IO_BANK0_IRQSUM_COMA_WK_SEC1*     = IO_BANK0_BASE + 0224H;
    IO_BANK0_IRQSUM_COMA_WK_NONSEC0*  = IO_BANK0_BASE + 0228H;
    IO_BANK0_IRQSUM_COMA_WK_NONSEC1*  = IO_BANK0_BASE + 022CH;

    (* raw interrupts *)
    IO_BANK0_INTR0*                   = IO_BANK0_BASE + 0230H;
      IO_BANK0_INTR_Offset* = 4;

    (* core 0 interrupt enable *)
    IO_BANK0_PROC0_INTE0*             = IO_BANK0_BASE + 0248H;
      IO_BANK0_PROC0_INTE_Offset* = 4;

    (* core 0 interrupt force *)
    IO_BANK0_PROC0_INTF0*             = IO_BANK0_BASE + 0260H;
      IO_BANK0_PROC0_INTF_Offset* = 4;

    (* core 0 interrupt status *)
    IO_BANK0_PROC0_INTS0*             = IO_BANK0_BASE + 0278H;
      IO_BANK0_PROC0_INTS_Offset* = 4;

    (* core 1 interrupt enable *)
    IO_BANK0_PROC1_INTE0*             = IO_BANK0_BASE + 0290H;
      IO_BANK0_PROC1_INTE_Offset* = 4;

    (* core 1 interrupt force *)
    IO_BANK0_PROC1_INTF0*             = IO_BANK0_BASE + 02A8H;

      IO_BANK0_PROC1_INTF_Offset* = 4;

    (* core 1 interrupt status *)
    IO_BANK0_PROC1_INTS0*             = IO_BANK0_BASE + 02C0H;
      IO_BANK0_PROC1_INTS_Offset* = 4;

    (* dormant_wake interrupt enable *)
    IO_BANK0_DORMANT_WAKE_INTE0*      = IO_BANK0_BASE + 02D8H;
      IO_BANK0_DOR_WAKE_INTE_Offset* = 4;

    (* dormant_wake interrupt force *)
    IO_BANK0_DORMANT_WAKE_INTF0*      = IO_BANK0_BASE + 02F0H;
      IO_BANK0_DOR_WAKE_INTF_Offset* = 4;

    (* dormant_wake interrupt status *)
    IO_BANK0_DORMANT_WAKE_INTS0*      = IO_BANK0_BASE + 0308H;
      IO_BANK0_DOR_WAKE_INTS_Offset* = 4;


    (* reset *)
    IO_BANK0_RST_reg* = RESETS_SYS.RESETS_RESET;
    IO_BANK0_RST_pos* = RESETS_SYS.RESETS_IO_BANK0;

    (* secure *)
    IO_BANK0_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_IO_BANK0;

    (* -- pin secure -- *)
    GPIO0_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_GPIO_NSMASK0;
    GPIO1_SEC_reg* = ACCESSCTRL_SYS.ACCESSCTRL_GPIO_NSMASK1;

    (* cross *)
    GPIO_SIO_CPUID* = SIO_DEV.SIO_CPUID;


END GPIO_DEV.
