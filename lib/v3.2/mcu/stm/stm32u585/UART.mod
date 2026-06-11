MODULE UART;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  UART device driver
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, DEV := UART_DEV, RST, TextIO, Errors;

  CONST
    (* handles *)
    (* do  not assume any specific value for these handles *)
    (* full functionality as per ref manual *)
    USART1* = DEV.USART1;
    USART2* = DEV.USART2;
    USART3* = DEV.USART3;
    (* basic functionality *)
    UART4*  = DEV.UART4;
    UART5*  = DEV.UART5;

    (* functional clock sources/value *)
    CLK_PCLK*   = 0; (* reset *)
    CLK_SYSCLK* = 1;
    CLK_HSI16*  = 2;
    CLK_LSE*    = 3;

    (* prescaler for functional/kernel clock *)
    Presc_1*   = 0; (* reset *)
    Presc_2*   = 1;
    Presc_4*   = 2;
    Presc_6*   = 3;
    Presc_8*   = 4;
    Presc_10*  = 5;
    Presc_12*  = 6;
    Presc_16*  = 7;
    Presc_32*  = 8;
    Presc_64*  = 9;
    Presc_128* = 10;
    Presc_256* = 11;

    FifoSize* = 8;

    Disabled* = 0;
    Enabled* = 1;

    (* ISR bits and values *)
    ISR_TXFNF*  = 7; (* corresponds to TXE without FIFO *)
    ISR_RXFNE*  = 5; (* corresponds to RXNE without FIFO *)


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartId*: INTEGER;
      bcEnReg, bcEnPos: INTEGER; (* bus clock enable *)
      fcSelReg, fcSelPos, fcSelWidth: INTEGER; (* func clock selection *)
      rstReg, rstPos: INTEGER; (* reset *)
      smReg, smPos: INTEGER; (* clock sleep mode *)
      CR1, CR2, CR3: INTEGER;
      BRR, PRESC: INTEGER;
      RDR*, TDR*, ISR*: INTEGER; (* exported for client modules *)
    END;

    (* 8 bits, 1 stop but, no parity *)
    DeviceCfg* = RECORD
      fifoEn*: INTEGER;   (* reset: off *)
      over8En*: INTEGER;  (* reset: off, ie. 16x oversampling *)
      clkSel*: INTEGER;   (* CLK_* above, reset: CLK_PCLK *)
      presc*: INTEGER;    (* Presc_* above, reset: Presc_1 *)
      clkFreq*: INTEGER;  (* look up in clock configure module *)
    END;

  VAR
    presc: ARRAY 12 OF INTEGER;


  PROCEDURE* Init*(dev: Device; uartId: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(uartId IN DEV.UART_all);
    dev.uartId := uartId;
    dev.fcSelReg := DEV.UART_FC_reg;
    dev.fcSelWidth := DEV.UART_FC_width;
    IF uartId IN DEV.UART_full THEN
      CASE uartId OF
        DEV.USART1:
          base := DEV.USART1_BASE;
          dev.bcEnReg := DEV.USART1_BC_reg; dev.bcEnPos := DEV.USART1_BC_pos;
          dev.fcSelPos := DEV.USART1_FC_pos;
          dev.rstReg := DEV.USART1_RST_reg; dev.rstPos := DEV.USART1_RST_pos;
          dev.smReg := DEV.USART1_SM_reg; dev.smPos := DEV.USART1_SM_pos
      | DEV.USART2:
          base := DEV.USART2_BASE;
          dev.bcEnReg := DEV.USART2_BC_reg; dev.bcEnPos := DEV.USART2_BC_pos;
          dev.fcSelPos := DEV.USART2_FC_pos;
          dev.rstReg := DEV.USART2_RST_reg; dev.rstPos := DEV.USART2_RST_pos;
          dev.smReg := DEV.USART2_SM_reg; dev.smPos := DEV.USART2_SM_pos
      | DEV.USART3:
          base := DEV.USART3_BASE;
          dev.bcEnReg := DEV.USART3_BC_reg ; dev.bcEnPos := DEV.USART3_BC_pos;
          dev.fcSelPos := DEV.USART3_FC_pos;
          dev.rstReg := DEV.USART3_RST_reg; dev.rstPos := DEV.USART3_RST_pos;
          dev.smReg := DEV.USART3_SM_reg; dev.smPos := DEV.USART3_SM_pos
      END
    ELSE (* DEV.UART_basic *)
      CASE uartId OF
        DEV.UART4:
          base := DEV.UART4_BASE;
          dev.bcEnReg := DEV.UART4_BC_reg; dev.bcEnPos := DEV.UART4_BC_pos;
          dev.fcSelPos := DEV.UART4_FC_pos;
          dev.rstReg := DEV.UART4_RST_reg; dev.rstPos := DEV.UART4_RST_pos;
          dev.smReg := DEV.UART4_SM_reg; dev.smPos := DEV.UART4_SM_pos
      | DEV.UART5:
          base := DEV.UART5_BASE;
          dev.bcEnReg := DEV.UART5_BC_reg; dev.bcEnPos := DEV.UART5_BC_pos;
          dev.fcSelPos := DEV.UART5_FC_pos;
          dev.rstReg := DEV.UART5_RST_reg; dev.rstPos := DEV.UART5_RST_pos;
          dev.smReg := DEV.UART5_SM_reg; dev.smPos := DEV.UART5_SM_pos
      END
    END;
    dev.CR1 := base + DEV.UART_CR1_Offset;
    dev.CR2 := base + DEV.UART_CR2_Offset;
    dev.CR3 := base + DEV.UART_CR3_Offset;
    dev.BRR := base + DEV.UART_BRR_Offset;
    dev.PRESC := base + DEV.UART_PRESC_Offset;
    dev.RDR := base + DEV.UART_RDR_Offset;
    dev.TDR := base + DEV.UART_TDR_Offset;
    dev.ISR := base + DEV.UART_ISR_Offset
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
    ASSERT(uartId IN DEV.UART_all, Errors.PreCond);
    IF uartId IN DEV.UART_full THEN
      CASE uartId OF
        DEV.USART1: reg := DEV.USART1_SEC_reg; pos := DEV.USART1_SEC_pos
      | DEV.USART2: reg := DEV.USART2_SEC_reg; pos := DEV.USART2_SEC_pos
      | DEV.USART3: reg := DEV.USART3_SEC_reg; pos := DEV.USART3_SEC_pos
      END
    ELSE
      CASE uartId OF
        DEV.UART4: reg := DEV.UART4_SEC_reg; pos := DEV.UART4_SEC_pos
      | DEV.UART5: reg := DEV.UART5_SEC_reg; pos := DEV.UART5_SEC_pos
      END
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
