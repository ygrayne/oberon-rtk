MODULE GPIO_DEV;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  GPIO: PADS_BANK0, IO_BANK0
  datasheet 2.19.6.3, p298 PADS_BANK0
  datasheet 2.19.6.1, p243 IO_BANK0
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT BASE, RESETS_SYS;

  CONST
    (* IO functions *)
    IO_BANK0_Fspi*    = 1;
    IO_BANK0_Fuart*   = 2;
    IO_BANK0_Fi2c*    = 3;
    IO_BANK0_Fpwm*    = 4;
    IO_BANK0_Fsio*    = 5;
    IO_BANK0_Fpio0*   = 6;
    IO_BANK0_Fpio1*   = 7;
    IO_BANK0_Fclk*    = 8;
    IO_BANK0_Fusb*    = 9;
    IO_BANK0_Fnull*   = 31;

    IO_BANK0_Functions* = {IO_BANK0_Fspi .. IO_BANK0_Fusb, IO_BANK0_Fnull};

    (* -- PADS_BANK0 -- *)
    PADS_BANK0_BASE* = BASE.PADS_BANK0_BASE;

    PADS_BANK0_VOLTAGE_SELECT*  = PADS_BANK0_BASE;

    (* bank base & offset *)
    PADS_BANK0_GPIO0*           = PADS_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO29 *)
      PADS_BANK0_GPIO_Offset* = 4;

    PADS_BANK0_SWCLK*           = PADS_BANK0_BASE + 07CH;
    PADS_BANK0_SWD*             = PADS_BANK0_BASE + 080H;


    (* reset *)
    PADS_BANK0_RST_reg* = RESETS_SYS.RESETS_RESET;
    PADS_BANK0_RST_pos* = RESETS_SYS.RESETS_PADS_BANK0;

    (* -- IO_BANK0 -- *)
    IO_BANK0_BASE* = BASE.IO_BANK0_BASE;

    IO_BANK0_GPIO0_STATUS*   = IO_BANK0_BASE;
    IO_BANK0_GPIO0_CTRL*     = IO_BANK0_BASE + 004H;
      (* GPIO0 .. GPIO29 *)
      (* block offset *)
      IO_BANK0_GPIO_Offset* = 8;
      (* block register offsets *)
      IO_BANK0_GPIO_STATUS_Offset*  = 0;
      IO_BANK0_GPIO_CTRL_Offset*    = 4;


    (* raw interrupts *)
    IO_BANK0_INTR0*       = IO_BANK0_BASE + 00F0H;
      IO_BANK0_INTR_Offset* = 4;

    (* core 0 interrupt enable *)
    IO_BANK0_PROC0_INTE0* = IO_BANK0_BASE + 0100H;
      IO_BANK0_PROC0_INTE_Offset* = 4;

    (* core 0 interrupt force *)
    IO_BANK0_PROC0_INTF0* = IO_BANK0_BASE + 0110H;
      IO_BANK0_PROC0_INTF_Offset* = 4;

    (* core 0 interrupt status *)
    IO_BANK0_PROC0_INTS0* = IO_BANK0_BASE + 0120H;
      IO_BANK0_PROC0_INTS_Offset* = 4;

    (* core 1 interrupt enable *)
    IO_BANK0_PROC1_INTE0* = IO_BANK0_BASE + 0130H;
      IO_BANK0_PROC1_INTE_Offset* = 4;

    (* core 1 interrupt force *)
    IO_BANK0_PROC1_INTF0* = IO_BANK0_BASE + 0140H;
      IO_BANK0_PROC1_INTF_Offset* = 4;

    (* core 1 interrupt status *)
    IO_BANK0_PROC1_INTS0* = IO_BANK0_BASE + 0150H;
      IO_BANK0_PROC1_INTS_Offset* = 4;

    (* dormant_wake interrupt enable *)
    IO_BANK0_DORMANT_WAKE_INTE0*  = IO_BANK0_BASE + 0160H;
      IO_BANK0_DOR_WAKE_INTE_Offset* = 4;

    (* dormant_wake interrupt force *)
    IO_BANK0_DORMANT_WAKE_INTF0*  = IO_BANK0_BASE + 0170H;
      IO_BANK0_DOR_WAKE_INTF_Offset* = 4;

    (* dormant_wake interrupt status *)
    IO_BANK0_DORMANT_WAKE_INTS0*  = IO_BANK0_BASE + 0180H;
      IO_BANK0_DOR_WAKE_INTS_Offset* = 4;

    (* reset *)
    IO_BANK0_RST_reg* = RESETS_SYS.RESETS_RESET;
    IO_BANK0_RST_pos* = RESETS_SYS.RESETS_IO_BANK0;


END GPIO_DEV.
