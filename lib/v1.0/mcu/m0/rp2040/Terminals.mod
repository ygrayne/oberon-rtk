MODULE Terminals;
(**
  Oberon RTK Framework
  --
  Max two text terminals via TextIO.Device, eg. UART
  --
  Use module Texts to write/read to/from any open terminal
  See module Out for a use case
  Each terminal can only be opened once.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, UARTdev, Errors;

  CONST
    TERM0* = 0;
    TERM1* = 1;
    NumTerms = 2;

  TYPE
    Ws* = ARRAY NumTerms OF TextIO.Writer;
    Rs* = ARRAY NumTerms OF TextIO.Reader;

  VAR
    W*, Werr*: Ws;
    R*: Rs;


  PROCEDURE InitUART*(uartNo: INTEGER; uartCfg: UARTdev.DeviceCfg; baudrate: INTEGER; VAR dev: UARTdev.Device);
  (* utility procedure *)
  BEGIN
    NEW(dev); ASSERT(dev # NIL, Errors.HeapOverflow);
    UARTdev.Init(dev, uartNo);
    UARTdev.Configure(dev, uartCfg, baudrate);
    UARTdev.Enable(dev)
  END InitUART;


  PROCEDURE Open*(termNo: INTEGER; dev: TextIO.Device; psp: TextIO.PutStringProc; gsp: TextIO.GetStringProc);
  BEGIN
    ASSERT(termNo IN {TERM0, TERM1}, Errors.PreCond);
    ASSERT(dev # NIL, Errors.PreCond);
    IF W[termNo] = NIL THEN
      NEW(W[termNo]); ASSERT(W[termNo] # NIL, Errors.HeapOverflow);
      NEW(R[termNo]); ASSERT(R[termNo] # NIL, Errors.HeapOverflow);
      TextIO.OpenWriter(W[termNo], dev, psp);
      TextIO.OpenReader(R[termNo], dev, gsp)
    END
  END Open;


  PROCEDURE Close*(termNo: INTEGER; VAR dev: TextIO.Device);
  BEGIN
    dev := W[termNo].dev;
    W[termNo] := NIL
  END Close;


  PROCEDURE OpenErr*(termNo: INTEGER; psp: TextIO.PutStringProc);
  (**
    Add an error output terminal, eg. using a simple busy-wait output.
    Not much worries about thread mis-timing in case of an error, better get that
    error message out intact. :)
    See module Main for an example.
  **)
  BEGIN
    ASSERT(termNo IN {TERM0, TERM1}, Errors.PreCond);
    ASSERT(W[termNo] # NIL, Errors.ProgError); (* main terminal must be open *)
    IF Werr[termNo] = NIL THEN
      NEW(Werr[termNo]); ASSERT(Werr[termNo] # NIL, Errors.HeapOverflow);
      TextIO.OpenWriter(Werr[termNo], W[termNo].dev, psp);
    END
  END OpenErr;


BEGIN
  W[0] := NIL; W[1] := NIL;
  R[0] := NIL; R[1] := NIL;
  Werr[0] := NIL; Werr[1] := NIL
END Terminals.
