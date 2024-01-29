MODULE Terminal;
(**
  Oberon RTK Framework
  Max two serial text terminals via UARTs
  --
  Use module Texts to write/read to/from any open terminal
  See module Out for a use case
  Each terminal can only be opened once.
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, UARTd, Error;

  CONST
    UART0* = 0;
    UART1* = 1;
    UARTs = {0, 1};
    NumUarts = 2;

  TYPE
    Ws* = ARRAY NumUarts OF TextIO.Writer;
    Rs* = ARRAY NumUarts OF TextIO.Reader;

  VAR
    W*: Ws;
    R*: Rs;


  PROCEDURE initUARTdevice(VAR dev: UARTd.Device; uartNo, txPinNo, rxPinNo, baudrate: INTEGER);
  BEGIN
    NEW(dev); ASSERT(dev # NIL, Error.HeapOverflow);
    UARTd.Init(dev, uartNo, txPinNo, rxPinNo);
    UARTd.Configure(dev, baudrate);
    UARTd.Enable(dev)
  END initUARTdevice;


  PROCEDURE Open*(uartNo, txPinNo, rxPinNo, baudrate: INTEGER; psp: TextIO.PutStringProc; gcp: TextIO.GetStringProc);
    VAR dev: UARTd.Device;
  BEGIN
    ASSERT(uartNo IN UARTs);
    IF W[uartNo] = NIL THEN
      (* UART device *)
      initUARTdevice(dev, uartNo,  txPinNo, rxPinNo, baudrate);

      (* writer and reader *)
      NEW(W[uartNo]); ASSERT(W[uartNo] # NIL, Error.HeapOverflow);
      NEW(R[uartNo]); ASSERT(R[uartNo] # NIL, Error.HeapOverflow);
      TextIO.OpenWriter(W[uartNo], dev, psp);
      TextIO.OpenReader(R[uartNo], dev, gcp)
    END
  END Open;

BEGIN
  W[0] := NIL; W[1] := NIL;
  R[0] := NIL; R[1] := NIL
END Terminal.
