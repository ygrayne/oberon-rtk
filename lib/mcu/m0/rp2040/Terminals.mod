MODULE Terminals;
(**
  Oberon RTK Framework
  --
  Max two serial text terminals via UARTs
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

  IMPORT TextIO, UARTd := UARTdev, Errors;

  CONST
    UART0* = 0;
    UART1* = 1;
    UARTs = {0, 1};
    NumUarts = 2;

  TYPE
    Ws* = ARRAY NumUarts OF TextIO.Writer;
    Rs* = ARRAY NumUarts OF TextIO.Reader;

  VAR
    W*, Werr*: Ws;
    R*: Rs;
    StdOut*, StdErr*: Ws;
    StdIn*: Rs;


  PROCEDURE initUARTdevice(VAR dev: UARTd.Device; uartNo, txPinNo, rxPinNo, baudrate: INTEGER);
  BEGIN
    NEW(dev); ASSERT(dev # NIL, Errors.HeapOverflow);
    UARTd.Init(dev, uartNo, txPinNo, rxPinNo);
    UARTd.Configure(dev, baudrate);
    UARTd.Enable(dev)
  END initUARTdevice;


  PROCEDURE Open*(uartNo, txPinNo, rxPinNo, baudrate: INTEGER; psp: TextIO.PutStringProc; gsp: TextIO.GetStringProc);
    VAR dev: UARTd.Device;
  BEGIN
    ASSERT(uartNo IN UARTs);
    IF W[uartNo] = NIL THEN
      (* uart *)
      initUARTdevice(dev, uartNo,  txPinNo, rxPinNo, baudrate);
      (* writers and readers *)
      NEW(W[uartNo]); ASSERT(W[uartNo] # NIL, Errors.HeapOverflow);
      NEW(R[uartNo]); ASSERT(R[uartNo] # NIL, Errors.HeapOverflow);
      TextIO.OpenWriter(W[uartNo], dev, psp);
      TextIO.OpenReader(R[uartNo], dev, gsp);
      StdOut[uartNo] := W[uartNo];
      StdIn[uartNo] := R[uartNo];
    END
  END Open;


  PROCEDURE OpenErr*(uartNo: INTEGER; psp: TextIO.PutStringProc);
  (**
    Add an error output terminal, eg. using a simple busy-wait output.
    Not much worries about thread mis-timing in case of an error, better get that
    error message out intact. :)
    See module Main for an example.
  **)
  BEGIN
    ASSERT(uartNo IN UARTs, Errors.PreCond);
    ASSERT(W[uartNo] # NIL, Errors.ProgError); (* main terminal must be open *)
    IF Werr[uartNo] = NIL THEN
      NEW(Werr[uartNo]); ASSERT(Werr[uartNo] # NIL, Errors.HeapOverflow);
      TextIO.OpenWriter(Werr[uartNo], W[uartNo].dev, psp);
      StdErr[uartNo] := Werr[uartNo];
    END
  END OpenErr;


BEGIN
  W[0] := NIL; W[1] := NIL;
  R[0] := NIL; R[1] := NIL;
  Werr[0] := NIL; Werr[1] := NIL
END Terminals.
