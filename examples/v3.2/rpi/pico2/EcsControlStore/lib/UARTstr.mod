MODULE UARTstr;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  UART string IO
  * Texts.mod Writer and Reader compatible API
  * device handles management
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UART, Texts;


  PROCEDURE* PutChar*(uartHandle: INTEGER; ch: CHAR);
    VAR dev: UART.Device;
  BEGIN
    dev := UART.Devices[uartHandle];
    REPEAT UNTIL ~SYSTEM.BIT(dev.FR, UART.FR_TXFF); (* not full *)
    SYSTEM.PUT(dev.TDR, ch)
  END PutChar;


  PROCEDURE* PutString*(uartHandle: INTEGER; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev: UART.Device; i: INTEGER;
  BEGIN
    dev := UART.Devices[uartHandle];
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF ~SYSTEM.BIT(dev.FR, UART.FR_TXFF) THEN (* not full *)
        SYSTEM.PUT(dev.TDR, s[i]);
        INC(i)
      END
    END
  END PutString;


  PROCEDURE* getChar(dev: UART.Device; VAR ch: CHAR);
  BEGIN
    REPEAT UNTIL ~SYSTEM.BIT(dev.FR, UART.FR_RXFE);
    SYSTEM.GET(dev.RDR, ch)
  END getChar;


  PROCEDURE GetString*(uartHandle: INTEGER; VAR s: ARRAY OF CHAR; VAR numCh, res: INTEGER);
    VAR dev: UART.Device; bufLimit: INTEGER; ch: CHAR;
  BEGIN
    dev := UART.Devices[uartHandle];
    bufLimit := LEN(s) - 1; (* space for 0X *)
    res := Texts.NoError;
    numCh := 0;
    getChar(dev, ch);
    WHILE (ch >= " ") & (numCh < bufLimit) DO
      s[numCh] := ch;
      INC(numCh);
      getChar(dev, ch)
    END;
    s[numCh] := 0X;
    (* if buffer overflow, flush the rest *)
    IF ch >= " "  THEN
      res := Texts.BufferOverflow;
      getChar(dev, ch);
      WHILE ch >= " " DO
        getChar(dev, ch)
      END;
    END
  END GetString;


  PROCEDURE DeviceStatus*(uartHandle: INTEGER): SET;
    RETURN UART.Flags(uartHandle)
  END DeviceStatus;


END UARTstr.
