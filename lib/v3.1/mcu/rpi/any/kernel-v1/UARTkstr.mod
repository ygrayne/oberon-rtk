MODULE UARTkstr;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  UART string device driver for kernel use
  --
  * string IO procedures
  * hw-buffered (fifo)
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, EXC, UART, TextIO, Kernel, Exceptions, Errors;

  CONST
    RxIntPrio = 2;
    EOL = TextIO.EOL;
    TxFifoLvl = UART.TXIFLSEL_val_48;  (* 4/8 = 16 entries *)
    RxFifoLvl = UART.RXIFLSEL_val_48;  (* 4/8 = 16 entries *)

  TYPE
    UARTint = POINTER TO UARTintDesc;
    UARTintDesc = RECORD
      dev: UART.Device;
      strAddr: INTEGER;
      bufLen: INTEGER;
      cnt: INTEGER;
      res: INTEGER
    END;

  VAR
    uartInts: ARRAY UART.NumUART OF UARTint;


  PROCEDURE PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UART.Device; i: INTEGER;
  BEGIN
    dev0 := dev(UART.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF ~SYSTEM.BIT(dev0.FR, UART.FR_TXFF) THEN (* not full *)
        SYSTEM.PUT(dev0.TDR, s[i]);
        INC(i)
      ELSE
        Kernel.AwaitDeviceFlags(dev0.FR, {UART.FR_TXFE}, {}) (* empty *)
      END
    END
  END PutString;


  PROCEDURE readFifo(uartInt: UARTint; VAR ch: CHAR; VAR overflow: BOOLEAN);
  BEGIN
    overflow := FALSE;
    WHILE ~SYSTEM.BIT(uartInt.dev.FR, UART.FR_RXFE) DO
      SYSTEM.GET(uartInt.dev.RDR, ch);
      IF ch >= " " THEN
        overflow := uartInt.cnt = uartInt.bufLen;
        IF ~overflow THEN
          SYSTEM.PUT(uartInt.strAddr, ch);
          INC(uartInt.cnt);
          INC(uartInt.strAddr)
        END
      END
    END
  END readFifo;


  PROCEDURE rxHandler[0];
    CONST
      UART0exc = EXC.IRQ_UART0 + EXC.IRQ_BASE;
      UART1exc = EXC.IRQ_UART1 + EXC.IRQ_BASE;
    VAR mis: SET; uartInt: UARTint; ch: CHAR; excNo: INTEGER; overflow: BOOLEAN;
  BEGIN
    Exceptions.GetExcNo(excNo);
    ASSERT((excNo = UART0exc) OR (excNo = UART1exc), Errors.ProgError);
    uartInt := uartInts[excNo - UART0exc]; (* UART exceptions have adjacent number *)
    UART.GetIntStatus(uartInt.dev, mis);
    (* rx fifo at trigger level *)
    IF UART.MIS_RXMIS IN mis THEN
      readFifo(uartInt, ch, overflow);
      IF ch = EOL THEN (* timeout int will not fire is rx fifo is empty => handle case with (trigger level - 1) chars sent. *)
        SYSTEM.PUT(uartInt.strAddr, 0X);
        IF overflow THEN uartInt.res := TextIO.BufferOverflow END;
        UART.DisableInt(uartInt.dev, {UART.IMSC_RXIM, UART.IMSC_RTIM})
      END;
    (* rx timeout *)
    ELSIF UART.MIS_RTMIS IN mis THEN
      readFifo(uartInt, ch, overflow);
      SYSTEM.PUT(uartInt.strAddr, 0X);
      IF overflow THEN uartInt.res := TextIO.BufferOverflow END;
      UART.DisableInt(uartInt.dev, {UART.IMSC_RXIM, UART.IMSC_RTIM})
    END
  END rxHandler;


  PROCEDURE GetString*(dev: TextIO.Device; VAR s: ARRAY OF CHAR; VAR numCh, res: INTEGER);
    VAR dev0: UART.Device; uartInt: UARTint;
  BEGIN
    dev0 := dev(UART.Device);
    uartInt := uartInts[dev0.uartNo];
    uartInt.strAddr := SYSTEM.ADR(s);
    uartInt.bufLen := LEN(s);
    uartInt.cnt := 0;
    uartInt.res := TextIO.NoError;
    UART.EnableInt(dev0, {UART.IMSC_RXIM, UART.IMSC_RTIM});
    Kernel.AwaitDeviceFlags(dev0.IMSC, {}, {UART.IMSC_RXIM}); (* await int disabled *)
    numCh := uartInt.cnt;
    res := uartInt.res
  END GetString;


  PROCEDURE DeviceStatus*(dev: TextIO.Device): SET;
  (*
    Mainly for getting fifo full/empty status, ie.
    "TxAvail" and "RxAvail" extended for fifo
    bits as defined in UART.
  *)
    VAR dev0: UART.Device;
  BEGIN
    dev0 := dev(UART.Device);
    RETURN UART.Flags(dev0)
  END DeviceStatus;


  PROCEDURE Install*(dev: UART.Device);
  BEGIN
    NEW(uartInts[dev.uartNo]); ASSERT(uartInts[dev.uartNo] # NIL, Errors.HeapOverflow);
    uartInts[dev.uartNo].dev := dev;
    Exceptions.InstallIntHandler(dev.irqNo, rxHandler);
    Exceptions.SetIntPrio(dev.irqNo, RxIntPrio);
    Exceptions.EnableInt(dev.irqNo);
    UART.SetFifoLvl(dev, TxFifoLvl, RxFifoLvl)
  END Install;

END UARTkstr.
