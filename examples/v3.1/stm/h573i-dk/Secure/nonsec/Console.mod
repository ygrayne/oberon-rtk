MODULE Console;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Example/test program Secure
  Program-specific console configuration, NS program.
  Since S has set up the UART, NS simply creates a UART device "cloak" RECORD
  to access the UART hardware with NS addresses.
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT UART, UARTstr, TextIO, Out, In, Errors, RuntimeErrorsOut;

  CONST
    UART0 = UART.USART1;

  VAR
    Wsys*, Werr*: TextIO.Writer;
    Rsys*: TextIO.Reader;

  (* terminal *)
  PROCEDURE installTerm(dev: TextIO.Device; pspStd, pspErr: TextIO.PutStringProc; gspStd: TextIO.GetStringProc);
  BEGIN
    NEW(Wsys); ASSERT(Wsys # NIL, Errors.HeapOverflow);
    NEW(Rsys); ASSERT(Rsys # NIL, Errors.HeapOverflow);
    NEW(Werr); ASSERT(Werr # NIL, Errors.HeapOverflow);
    TextIO.OpenWriter(Wsys, dev, pspStd);
    TextIO.OpenReader(Rsys, dev, gspStd);
    TextIO.OpenWriter(Werr, Wsys.dev, pspErr)
  END installTerm;


  PROCEDURE Install*;
    VAR uartDev: UART.Device;
  BEGIN
    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    UART.Init(uartDev, UART0);

    (* install one system terminal *)
    installTerm(uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys);
    In.Open(Rsys);

    (* run-time errors console output *)
    RuntimeErrorsOut.SetWriter(Werr)
  END Install;

BEGIN
  Wsys := NIL; Rsys := NIL; Werr := NIL
END Console.
