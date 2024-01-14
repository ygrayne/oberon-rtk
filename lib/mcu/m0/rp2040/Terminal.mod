MODULE Terminal;
(**
  Oberon RTK Framework
  Max two serial text terminals via UARTs
  Use module Texts to write/read to/from any open terminal
  See module Out for a use case
  --
  Copyright (c) 2020-2023 Gray gray@grayraven.org
**)

  IMPORT TextIO, UARTd, UART, Error;

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
    open: ARRAY NumUarts OF BOOLEAN;


  PROCEDURE initUARTdevice(VAR dev: UARTd.Device; uartNo, txPinNo, rxPinNo, baudrate: INTEGER);
  BEGIN
    NEW(dev); ASSERT(dev # NIL, Error.HeapOverflow);
    UARTd.Init(dev, uartNo, txPinNo, rxPinNo);
    UARTd.Configure(dev, baudrate);
    UARTd.Enable(dev)
  END initUARTdevice;


  PROCEDURE Open*(uartNo, txPinNo, rxPinNo, baudrate: INTEGER);
    VAR dev: UARTd.Device;
  BEGIN
    ASSERT(uartNo IN UARTs);
    IF ~open[uartNo] THEN
      (* UART device *)
      initUARTdevice(dev, uartNo,  txPinNo, rxPinNo, baudrate);

      (* writer and reader *)
      NEW(W[uartNo]); ASSERT(W[uartNo] # NIL, Error.HeapOverflow);
      NEW(R[uartNo]); ASSERT(R[uartNo] # NIL, Error.HeapOverflow);
      TextIO.OpenWriter(W[uartNo], dev, UART.PutChar, UART.PutString);
      TextIO.OpenReader(R[uartNo], dev, UART.GetChar);
      open[uartNo] := TRUE
    END
  END Open;

BEGIN
  open[0] := FALSE; open[1] := FALSE
END Terminal.
