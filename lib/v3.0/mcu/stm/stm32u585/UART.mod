MODULE UART;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  UART device driver
  --
  Type: MCU
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, CLK, TextIO;

  CONST
    USART1* = 0;
    USART2* = 1;
    USART3* = 2;
    UART4* = 3;
    UART5* = 4;
    UART = {USART1 .. UART5};
    NumUART* = MCU.NumUART;

    (* functionsl/kernel clock values *)
    CLK_PCLK* = 0; (* reset *)
    CLK_SYSCLK* = 1;
    CLK_HSI16* = 2;
    CLK_LSE* = 3;

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


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD(TextIO.DeviceDesc)
      uartId*: INTEGER;
      devNo: INTEGER;    (* MCU.DEV_* *)
      clkSelReg: INTEGER; (* functional/kernel clock: MCU.RCC_CCIPR1 *)
      clkSelPos: INTEGER; (* bit position in RCC_CCIPR1 *)
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
      clkFreq*: INTEGER;  (* usually look up in module Clocks *)
    END;

    VAR
      presc: ARRAY 12 OF INTEGER;


    PROCEDURE* Init*(dev: Device; uartId: INTEGER);
      VAR base: INTEGER;
    BEGIN
      ASSERT(dev # NIL, Errors.ProgError);
      ASSERT(uartId IN UART, Errors.ProgError);
      dev.uartId := uartId;
      IF uartId = USART1 THEN
        base := MCU.USART1_BASE;
        dev.devNo := MCU.DEV_USART1
      ELSE
        base := MCU.USART2_BASE + (uartId * MCU.UART_Offset);
        dev.devNo := MCU.DEV_USART2 + uartId
      END;
      dev.clkSelReg := MCU.RCC_CCIPR1;
      dev.clkSelPos := uartId * 2;
      dev.CR1 := base + MCU.UART_CR1_Offset;
      dev.CR2 := base + MCU.UART_CR2_Offset;
      dev.CR3 := base + MCU.UART_CR3_Offset;
      dev.BRR := base + MCU.UART_BRR_Offset;
      dev.PRESC := base + MCU.UART_PRESC_Offset;
      dev.RDR := base + MCU.UART_RDR_Offset;
      dev.TDR := base + MCU.UART_TDR_Offset;
      dev.ISR := base + MCU.UART_ISR_Offset
    END Init;


    PROCEDURE Configure*(dev: Device; cfg: DeviceCfg; baudrate: INTEGER);
      CONST TwoBits = 2;
      VAR div, brr: INTEGER; cr1: SET;
    BEGIN
      ASSERT(dev # NIL, Errors.PreCond);

      (* set functional/kernel clock, start bus clock *)
      CLK.ConfigDevClock(dev.clkSelReg, cfg.clkSel, dev.clkSelPos, TwoBits);
      CLK.EnableBusClock(dev.devNo);

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
      ASSERT(dev # NIL, Errors.ProgError);
      SYSTEM.GET(dev.CR1, val);
      SYSTEM.PUT(dev.CR1, val + {0, 2, 3})
    END Enable;


    PROCEDURE* init;
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
    END init;

BEGIN
  init
END UART.
