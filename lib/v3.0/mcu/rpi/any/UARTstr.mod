MODULE UARTstr;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  UART string device driver, kernel not required (busy waiting)
  --
  * string IO procedures
  * hw-buffered (fifo)
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UARTdev, TextIO;


  PROCEDURE* PutChar*(dev: TextIO.Device; ch: CHAR);
    VAR dev0: UARTdev.Device;
  BEGIN
    dev0 := dev(UARTdev.Device);
    REPEAT UNTIL ~SYSTEM.BIT(dev0.FR, UARTdev.FR_TXFF); (* not full *)
    SYSTEM.PUT(dev0.TDR, ch)
  END PutChar;


  PROCEDURE* PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UARTdev.Device; i: INTEGER;
  BEGIN
    dev0 := dev(UARTdev.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF ~SYSTEM.BIT(dev0.FR, UARTdev.FR_TXFF) THEN (* not full *)
        SYSTEM.PUT(dev0.TDR, s[i]);
        INC(i)
      END
    END
  END PutString;


  PROCEDURE* GetChar*(dev: TextIO.Device; VAR ch: CHAR);
    VAR dev0: UARTdev.Device;
  BEGIN
    dev0 := dev(UARTdev.Device);
    REPEAT UNTIL ~SYSTEM.BIT(dev0.FR, UARTdev.FR_RXFE);
    SYSTEM.GET(dev0.RDR, ch)
  END GetChar;


  PROCEDURE GetString*(dev: TextIO.Device; VAR s: ARRAY OF CHAR; VAR numCh, res: INTEGER);
    VAR dev0: UARTdev.Device; bufLimit: INTEGER; ch: CHAR;
  BEGIN
    dev0 := dev(UARTdev.Device);
    bufLimit := LEN(s) - 1; (* space for 0X *)
    res := TextIO.NoError;
    numCh := 0;
    GetChar(dev, ch);
    WHILE (ch >= " ") & (numCh < bufLimit) DO
      s[numCh] := ch;
      INC(numCh);
      GetChar(dev, ch)
    END;
    s[numCh] := 0X;
    (* if buffer overflow, flush the rest *)
    IF ch >= " "  THEN
      res := TextIO.BufferOverflow;
      GetChar(dev, ch);
      WHILE ch >= " " DO
        GetChar(dev, ch)
      END;
    END
  END GetString;


  PROCEDURE DeviceStatus*(dev: TextIO.Device): SET;
  (*
    Mainly for getting fifo full/empty status, ie.
    "TxAvail" and "RxAvail" extended for fifo
    Bits as defined in UARTdev
  *)
    VAR dev0: UARTdev.Device;
  BEGIN
    dev0 := dev(UARTdev.Device);
    RETURN UARTdev.Flags(dev0)
  END DeviceStatus;


END UARTstr.
