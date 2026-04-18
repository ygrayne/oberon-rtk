MODULE Console;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Test program Secure5
  Program-specific console configuration, NS program.
  Since S has set up the UART, NS simply creates a UART device "cloak" RECORD
  to access the UART hardware with NS addresses;
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT UART, UARTstr, TextIO, Out, In, Errors, RuntimeErrorsOut;

  CONST
    SYSTERM0* = 0;
    NumSysTerms* = 1;
    UART0 = UART.USART1;

  TYPE
    Ws* = ARRAY NumSysTerms OF TextIO.Writer;
    Rs* = ARRAY NumSysTerms OF TextIO.Reader;

  VAR
    Wsys*, Werr*: Ws;
    Rsys*: Rs;

  (* terminal *)
  PROCEDURE installTerm(termNo: INTEGER; dev: TextIO.Device; pspStd, pspErr: TextIO.PutStringProc; gspStd: TextIO.GetStringProc);
  BEGIN
    NEW(Wsys[termNo]); ASSERT(Wsys[termNo] # NIL, Errors.HeapOverflow);
    NEW(Rsys[termNo]); ASSERT(Rsys[termNo] # NIL, Errors.HeapOverflow);
    NEW(Werr[termNo]); ASSERT(Werr[termNo] # NIL, Errors.HeapOverflow);
    TextIO.OpenWriter(Wsys[termNo], dev, pspStd);
    TextIO.OpenReader(Rsys[termNo], dev, gspStd);
    TextIO.OpenWriter(Werr[termNo], Wsys[termNo].dev, pspErr)
  END installTerm;


  PROCEDURE Install*;
    VAR uartDev: UART.Device;
  BEGIN
    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    UART.Init(uartDev, UART0);

    (* install one system terminal *)
    installTerm(SYSTERM0, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys[SYSTERM0]);
    In.Open(Rsys[SYSTERM0]);

    (* run-time errors console output *)
    RuntimeErrorsOut.SetWriter(Werr[SYSTERM0])
  END Install;

BEGIN
  Wsys[SYSTERM0] := NIL; Rsys[SYSTERM0] := NIL; Werr[SYSTERM0] := NIL
END Console.
