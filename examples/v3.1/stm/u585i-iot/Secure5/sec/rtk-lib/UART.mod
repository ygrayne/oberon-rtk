MODULE UART;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  UART device driver
  --
  Definition module: UARTdef.mod
  --
  Type: MCU
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV2, DEF := UARTdef, RST, TextIO, Errors;

  CONST
    (* API definitions *)
    (* prescaler for functional/kernel clock *)
    Presc_1* = 0; (* reset *)
    Presc_2* = 1;
    Presc_4* = 2;
    Presc_6* = 3;
    Presc_8* = 4;
    Presc_10* = 5;
    Presc_12* = 6;
    Presc_16* = 7;
    Presc_32* = 8;
    Presc_64* = 9;
    Presc_128* = 10;
    Presc_256* = 11;

    Disabled* = 0;
    Enabled* = 1;

    FifoSize* = 8;

    (* ISR bits and values *)
    ISR_TXFNF*  = 7; (* corresponds to TXE without FIFO *)
    ISR_RXFNE*  = 5; (* corresponds to RXNE without FIFO *)

    (* internal definitions *)
    UART = {DEF.USART1 .. DEF.UART5};


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartId*: INTEGER;
      bcEnReg, bcEnPos: INTEGER; (* bus clock enable *)
      fcSelReg, fcSelPos, fcSelWidth: INTEGER; (* func clock selection *)
      CR1, CR2, CR3: INTEGER;
      BRR, PRESC: INTEGER;
      RDR*, TDR*, ISR*: INTEGER;
    END;

    (* 8 bits, 1 stop but, no parity *)
    DeviceCfg* = RECORD
      fifoEn*: INTEGER;   (* reset: off *)
      over8En*: INTEGER;  (* reset: off, ie. 16x oversampling *)
      clkSel*: INTEGER;   (* CLK_* above, reset: CLK_PCLK *)
      presc*: INTEGER;    (* Presc_* above, reset: Presc_1 *)
      clkFreq*: INTEGER;  (* usually look up in module ClockCfg *)
    END;

  VAR
    presc: ARRAY 12 OF INTEGER;


  PROCEDURE* Init*(dev: Device; uartId: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(uartId IN UART, Errors.PreCond);
    dev.uartId := uartId;
    dev.fcSelReg := CFG.USART_FC_reg;
    CASE uartId OF
      DEF.USART1:
        base := CFG.USART1_BASE;
        dev.bcEnReg := CFG.USART1_BC_reg; dev.bcEnPos := CFG.USART1_BC_pos;
        dev.fcSelPos := CFG.USART1_FC_pos; dev.fcSelWidth := CFG.USART_FC_width;
    | DEF.USART2:
        base := CFG.USART2_BASE;
        dev.bcEnReg := CFG.USART2_BC_reg; dev.bcEnPos := CFG.USART2_BC_pos;
        dev.fcSelPos := CFG.USART2_FC_pos; dev.fcSelWidth := CFG.USART_FC_width;
    | DEF.USART3:
        base := CFG.USART3_BASE;
        dev.bcEnReg := CFG.USART3_BC_reg ; dev.bcEnPos := CFG.USART3_BC_pos;
        dev.fcSelPos := CFG.USART3_FC_pos; dev.fcSelWidth := CFG.USART_FC_width;
    | DEF.UART4:
        base := CFG.UART4_BASE;
        dev.bcEnReg := CFG.UART4_BC_reg; dev.bcEnPos := CFG.UART4_BC_pos;
        dev.fcSelPos := CFG.UART4_FC_pos; dev.fcSelWidth := CFG.USART_FC_width;
    | DEF.UART5:
        base := CFG.UART5_BASE;
        dev.bcEnReg := CFG.UART5_BC_reg; dev.bcEnPos := CFG.UART5_BC_pos;
        dev.fcSelPos := CFG.UART5_FC_pos; dev.fcSelWidth := CFG.USART_FC_width;
    END;
    dev.CR1 := base + CFG.UART_CR1_Offset;
    dev.CR2 := base + CFG.UART_CR2_Offset;
    dev.CR3 := base + CFG.UART_CR3_Offset;
    dev.BRR := base + CFG.UART_BRR_Offset;
    dev.PRESC := base + CFG.UART_PRESC_Offset;
    dev.RDR := base + CFG.UART_RDR_Offset;
    dev.TDR := base + CFG.UART_TDR_Offset;
    dev.ISR := base + CFG.UART_ISR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg; baudrate: INTEGER);
    VAR div, brr: INTEGER; cr1: SET;
  BEGIN
    (* set functional/kernel clock, start bus clock *)
    RST.ConfigDevClock(cfg.clkSel, dev.fcSelReg, dev.fcSelPos, dev.fcSelWidth);
    RST.EnableBusClock(dev.bcEnReg, dev.bcEnPos);

    (* stop/reset *)
    SYSTEM.PUT(dev.CR1, 0);
    cr1 := {};

    (* baudrate *)
    div := (cfg.clkFreq DIV presc[cfg.presc]) DIV baudrate;
    ASSERT(div >= 16, Errors.ProgError);
    IF cfg.over8En = Disabled THEN
      SYSTEM.PUT(dev.BRR, div)
    ELSE
      div := div * 2;
      brr := 0;
      BFI(brr, 2, 0, BFX(div, 3, 0) DIV 2);
      BFI(brr, 15, 4, BFX(div, 15, 4));
      SYSTEM.PUT(dev.BRR, brr);
      cr1 := cr1 + {15}
    END;
    SYSTEM.PUT(dev.PRESC, cfg.presc);

    (* enable fifos *)
    IF cfg.fifoEn = Enabled THEN
      cr1 := cr1 + {29}
    END;

    SYSTEM.PUT(dev.CR1, cr1)
  END Configure;


  PROCEDURE* GetBaseCfg*(VAR cfg: DeviceCfg);
  BEGIN
    CLEAR(cfg);
  END GetBaseCfg;


  PROCEDURE* Enable*(dev: Device);
    VAR val: SET;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.GET(dev.CR1, val);
    SYSTEM.PUT(dev.CR1, val + {0, 2, 3})
  END Enable;


  PROCEDURE GetDevSec*(uartId: INTEGER; VAR reg, pos: INTEGER);
  BEGIN
    ASSERT(uartId IN UART, Errors.PreCond);
    CASE uartId OF
      DEF.USART1: reg := CFG.USART1_SEC_reg; pos := CFG.USART1_SEC_pos
    | DEF.USART2: reg := CFG.USART2_SEC_reg; pos := CFG.USART2_SEC_pos
    | DEF.USART3: reg := CFG.USART3_SEC_reg; pos := CFG.USART3_SEC_pos
    | DEF.UART4: reg := CFG.UART4_SEC_reg; pos := CFG.UART4_SEC_pos
    | DEF.UART5: reg := CFG.UART5_SEC_reg; pos := CFG.UART5_SEC_pos
    END
  END GetDevSec;


  PROCEDURE* initPresc;
  BEGIN
    presc[Presc_1] := 1;
    presc[Presc_2] := 2;
    presc[Presc_4] := 4;
    presc[Presc_6] := 6;
    presc[Presc_8] := 8;
    presc[Presc_10] := 10;
    presc[Presc_12] := 12;
    presc[Presc_16] := 16;
    presc[Presc_32] := 32;
    presc[Presc_64] := 64;
    presc[Presc_128] := 128;
    presc[Presc_256] := 256
  END initPresc;

BEGIN
  initPresc
END UART.
