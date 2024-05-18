MODULE UARTkstr;
(**
  Oberon RTK Framework
  UART string device driver for kernel use
  --
  * string IO procedures
  * hw-buffered (fifo)
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UARTd := UARTdev, TextIO, Kernel, GPIO, LED;


  PROCEDURE PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UARTd.Device; i: INTEGER;
  BEGIN
    dev0 := dev(UARTd.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF ~SYSTEM.BIT(dev0.FR, UARTd.FR_TXFF) THEN (* not full *)
        SYSTEM.PUT(dev0.TDR, s[i]);
        INC(i)
      ELSE
        Kernel.AwaitDeviceFlags(dev0.FR, {UARTd.FR_TXFE}, {})
      END
    END
  END PutString;


  PROCEDURE GetChar*(dev: TextIO.Device; VAR ch: CHAR);
    VAR dev0: UARTd.Device;
  BEGIN
    dev0 := dev(UARTd.Device);
    IF SYSTEM.BIT(dev0.FR, UARTd.FR_RXFE) THEN
      (* debug/test
      GPIO.Clear({20}); (* for oscilloscope on pin 20 *)
      *)
      Kernel.AwaitDeviceFlags(dev0.FR, {}, {UARTd.FR_RXFE});
      (* debug/test
      ASSERT(Kernel.Trigger() = Kernel.TrigDevice);
      GPIO.Set({20})
      *)
    END;
    SYSTEM.GET(dev0.RDR, ch)
  END GetChar;


  PROCEDURE checkFifoOverrun(dev0: UARTd.Device; VAR overrun: BOOLEAN);
  BEGIN
    overrun := SYSTEM.BIT(dev0.RSR, UARTd.RSR_OR)
  END checkFifoOverrun;

  PROCEDURE GetString*(dev: TextIO.Device; VAR s: ARRAY OF CHAR; VAR numCh, res: INTEGER);
    CONST FifoCapture = 30;
    VAR dev0: UARTd.Device; bufLimit, fifoLimit: INTEGER; ch: CHAR; overrun, done: BOOLEAN;
  BEGIN
    dev0 := dev(UARTd.Device);
    bufLimit := LEN(s) - 1; (* space for 0X *)
    res := TextIO.NoError;
    numCh := 0;
    done := FALSE;
    GetChar(dev, ch);
    checkFifoOverrun(dev0, overrun);
    WHILE ~overrun & ~done DO
      done := (ch < " ") OR (numCh = bufLimit);
      IF ~done THEN
        s[numCh] := ch;
        INC(numCh);
        GetChar(dev, ch);
        checkFifoOverrun(dev0, overrun)
      END
    END;
    IF numCh = bufLimit THEN
      res := TextIO.BufferOverflow
    END;
    (* capture the valid data in the fifo before the overrun *)
    IF overrun & ~done THEN
      res := TextIO.FifoOverrun;
      fifoLimit := numCh + FifoCapture;
      WHILE (ch >= " ") & (numCh < bufLimit) & (numCh < fifoLimit) DO
        s[numCh] := ch;
        INC(numCh);
        GetChar(dev, ch)
      END
    END;
    s[numCh] := 0X;
    (* if buffer overflow or fifo overrun, ignore and flush the rest *)
    (* we have no idea how many chars that are *)
    IF ch >= " " THEN
      REPEAT
        (* read all incoming data until we have a timeout *)
        Kernel.StartTimeout(10);
        GetChar(dev0, ch)
      UNTIL Kernel.Trigger() = Kernel.TrigDelay
    END;
    Kernel.CancelAwaitDeviceFlags;
    SYSTEM.PUT(dev0.RSR, 0)
  END GetString;


  PROCEDURE DeviceStatus*(dev: TextIO.Device): SET;
  (*
    Mainly for getting fifo full/empty status, ie.
    "TxAvail" and "RxAvail" extended for fifo
    Bits as defined in UARTd.
  *)
    VAR dev0: UARTd.Device;
  BEGIN
    dev0 := dev(UARTd.Device);
    RETURN UARTd.Flags(dev0)
  END DeviceStatus;

BEGIN
  (* debug/test with oscilloscope
  GPIO.SetFunction(20, GPIO.Fsio);
  GPIO.OutputEnable({20});
  GPIO.Clear({20})
  *)
END UARTkstr.
