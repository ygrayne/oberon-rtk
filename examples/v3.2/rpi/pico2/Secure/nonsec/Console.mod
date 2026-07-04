MODULE Console;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  Test program Secure
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

  IMPORT UART, UARTstr, TextIO, Out, In, RuntimeErrorsOut, Errors;

  CONST
    SYSTERM0* = 0;
    SYSTERM1* = 1;
    NumSysTerms* = 2;
    UART0 = UART.UART0;
    UART1 = UART.UART1;
    SYSTERM0_UART = UART0;
    SYSTERM1_UART = UART1;

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


  PROCEDURE Install*(sysTerm: INTEGER);
    VAR uartDev: UART.Device; uartNo: INTEGER;
  BEGIN
    ASSERT(sysTerm IN {SYSTERM0, SYSTERM1}, Errors.ProgError);

    IF sysTerm = SYSTERM0 THEN
      uartNo := SYSTERM0_UART
    ELSE
      uartNo := SYSTERM1_UART;
    END;

    (* create device RECORD *)
    NEW(uartDev); ASSERT(uartDev # NIL, Errors.HeapOverflow);
    UART.Init(uartDev, uartNo);

    (* install system terminal *)
    installTerm(sysTerm, uartDev, UARTstr.PutString, UARTstr.PutString, UARTstr.GetString);

    (* Out/In wrappers *)
    Out.Open(Wsys[sysTerm]);
    In.Open(Rsys[sysTerm]);

    (* run-time errors console output *)
    RuntimeErrorsOut.SetWriter(Werr[sysTerm])
  END Install;

BEGIN
  Wsys[0] := NIL; Rsys[0] := NIL; Werr[0] := NIL;
  Wsys[1] := NIL; Rsys[1] := NIL; Werr[1] := NIL
END Console.
