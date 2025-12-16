MODULE UART;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  UART device
  * initialisation of device data structure
  * configure UART hardware
  * enable physical UART device
  --
  Type: MCU
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  MCU: STM32H573II
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
    USART6* = 5;
    UART7* = 6;
    UART8* = 7;
    UART9* = 8;
    USART10* = 9;
    USART11* = 10;
    UART12* = 11;

    UART = {USART1 .. UART12};
    NumUART* = MCU.NumUART;

    (* functional/kernel clock values *)
    CLK_PCLK* = 0; (* reset *)
    CLK_PLL2Q* = 1;
    CLK_PLL3Q* = 2;
    CLK_HSI* = 3;
    CLK_CSI* = 4;
    CLK_LSE* = 5;

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
      devNo: INTEGER;     (* MCU.DEV_* *)
      clkSelReg: INTEGER; (* functional/kernel clock: MCU.RCC_CCIPR1 or MCU.RCC_CCIPR2 *)
      clkSelPos: INTEGER; (* bit position in RCC_CCIPRx *)
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
      CASE uartId OF
        USART1: base := MCU.USART1_BASE; dev.devNo := MCU.DEV_USART1
      | USART2: base := MCU.USART2_BASE; dev.devNo := MCU.DEV_USART2
      | USART3: base := MCU.USART3_BASE; dev.devNo := MCU.DEV_USART3
      | UART4:  base := MCU.UART4_BASE; dev.devNo := MCU.DEV_UART4
      | UART5:  base := MCU.UART5_BASE; dev.devNo := MCU.DEV_UART5
      | USART6: base := MCU.USART6_BASE; dev.devNo := MCU.DEV_USART6
      | UART7:  base := MCU.UART7_BASE; dev.devNo := MCU.DEV_UART7
      | UART8:  base := MCU.UART8_BASE; dev.devNo := MCU.DEV_UART8
      | UART9:  base := MCU.UART9_BASE; dev.devNo := MCU.DEV_UART9
      | USART10: base := MCU.USART10_BASE; dev.devNo := MCU.DEV_USART10
      | USART11: base := MCU.USART11_BASE; dev.devNo := MCU.DEV_USART11
      | UART12:  base := MCU.UART12_BASE; dev.devNo := MCU.DEV_UART12
      END;
      IF uartId < USART11 THEN
        dev.clkSelPos := uartId * 3;
        dev.clkSelReg := MCU.RCC_CCIPR1;
      ELSE
        dev.clkSelPos := (uartId - USART11) * 4;
        dev.clkSelReg := MCU.RCC_CCIPR2;
      END;
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
      CONST ThreeBits = 3;
      VAR div, brr: INTEGER; cr1: SET;
    BEGIN
      ASSERT(dev # NIL, Errors.ProgError);

      (* set functional/kernel clock, start bus clock *)
      CLK.ConfigDevClock(dev.clkSelReg, cfg.clkSel, dev.clkSelPos, ThreeBits);
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
