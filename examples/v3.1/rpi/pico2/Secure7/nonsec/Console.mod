MODULE Console;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Test program Secure5
  Program-specific console configuration, NS program.
  Since S has set up the UART, NS simply creates a UART device "cloak" RECORD
  to access the UART hardware.
  --
  MCU: RP2350A
  Board: Pico2
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Cores, UART, UARTstr, TextIO, Out, In, RuntimeErrorsOut, Errors;

  CONST
    SYSTERM0* = 0;
    SYSTERM1* = 1;
    NumSysTerms* = 2;
    UART0 = UART.UART0;
    UART1 = UART.UART1;

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
    CONST Core0 = 0;
    VAR uartDev: UART.Device; cid: INTEGER;
  BEGIN
    Cores.GetCoreId(cid);
    ASSERT(cid IN {0, 1}, Errors.ProgError);
    IF cid = Core0 THEN
      NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
      UART.Init(uartDev, UART0);

      (* install system terminal *)
      installTerm(SYSTERM0, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

      (* Out/In wrappers *)
      Out.Open(Wsys[SYSTERM0]);
      In.Open(Rsys[SYSTERM0]);

      (* run-time errors console output *)
      RuntimeErrorsOut.SetWriter(Werr[SYSTERM0])
    ELSE
      NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
      UART.Init(uartDev, UART1);

      (* install system terminal *)
      installTerm(SYSTERM1, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

      (* Out/In wrappers *)
      Out.Open(Wsys[SYSTERM1]);
      In.Open(Rsys[SYSTERM1]);

      (* run-time errors console output *)
      RuntimeErrorsOut.SetWriter(Werr[SYSTERM1])
    END
  END Install;

BEGIN
  Wsys[0] := NIL; Rsys[0] := NIL; Werr[0] := NIL;
  Wsys[1] := NIL; Rsys[1] := NIL; Werr[1] := NIL
END Console.
