MODULE UARTkstr;
(**
  Oberon RTK Framework
  --
  UART string device driver for kernel use
  --
  Includes
  * the GPIO pins for performance and behaviour testing and measuring
  * delays in the interrupt handler
  --
  * string IO procedures
  * hw-buffered (fifo)
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, UARTdev, TextIO, Kernel, Exceptions, Errors, GPIO;

  CONST
    RxIntPrio = 2;
    EOL = TextIO.EOL;
    TxFifoLvl = UARTdev.TXIFLSEL_val_48;  (* 4/8 = 16 entries *)
    RxFifoLvl = UARTdev.RXIFLSEL_val_18;  (* 1/8 = 4 entries *)

    (* testing *)
    RxPin = 1;
    RxHandlerFifoPin = 16;
    RxHandlerTimeoutPin = 17;

  TYPE
    UARTint = POINTER TO UARTintDesc;
    UARTintDesc = RECORD
      dev: UARTdev.Device;
      strAddr: INTEGER;
      bufLen: INTEGER;
      cnt: INTEGER;
      res: INTEGER
    END;

  VAR
    uartInts: ARRAY UARTdev.NumUART OF UARTint;


  PROCEDURE PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UARTdev.Device; i: INTEGER;
  BEGIN
    dev0 := dev(UARTdev.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF ~SYSTEM.BIT(dev0.FR, UARTdev.FR_TXFF) THEN (* not full *)
        SYSTEM.PUT(dev0.TDR, s[i]);
        INC(i)
      ELSE
        Kernel.AwaitDeviceFlags(dev0.FR, {UARTdev.FR_TXFE}, {}) (* empty *)
      END
    END
  END PutString;


  PROCEDURE readFifo(uartInt: UARTint; VAR ch: CHAR; VAR overflow: BOOLEAN);
  BEGIN
    overflow := FALSE;
    WHILE ~SYSTEM.BIT(uartInt.dev.FR, UARTdev.FR_RXFE) DO
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
    VAR mis: SET; uartInt: UARTint; ch: CHAR; excNo, i: INTEGER; overflow: BOOLEAN;
  BEGIN
    Exceptions.GetIntStatus(excNo);
    ASSERT((excNo = MCU.NVIC_UART0_IRQ_EXC) OR (excNo = MCU.NVIC_UART0_IRQ_EXC), Errors.ProgError);
    uartInt := uartInts[excNo - MCU.NVIC_UART0_IRQ_EXC]; (* UART exceptions have adjacent number *)
    UARTdev.GetIntStatus(uartInt.dev, mis);
    (* rx fifo at trigger level *)
    IF UARTdev.MIS_RXMIS IN mis THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {RxHandlerFifoPin});
      readFifo(uartInt, ch, overflow);
      IF ch = EOL THEN (* timeout int will not fire is rx fifo is empty => handle case with (trigger level - 1) chars sent. *)
        SYSTEM.PUT(uartInt.strAddr, 0X);
        IF overflow THEN uartInt.res := TextIO.BufferOverflow END;
        UARTdev.DisableInt(uartInt.dev, {UARTdev.IMSC_RXIM, UARTdev.IMSC_RTIM});
      END;
      i := 0; WHILE i < 100 DO INC(i) END; (* some delay for nicer traces on oscilloscope *)
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {RxHandlerFifoPin})
    (* rx timeout *)
    ELSIF UARTdev.MIS_RTMIS IN mis THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {RxHandlerTimeoutPin});
      readFifo(uartInt, ch, overflow);
      SYSTEM.PUT(uartInt.strAddr, 0X);
      IF overflow THEN uartInt.res := TextIO.BufferOverflow END;
      UARTdev.DisableInt(uartInt.dev, {UARTdev.IMSC_RXIM, UARTdev.IMSC_RTIM});
      i := 0; WHILE i < 100 DO INC(i) END; (* some delay for nicer traces on oscilloscope *)
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {RxHandlerTimeoutPin})
    END
  END rxHandler;


  PROCEDURE GetString*(dev: TextIO.Device; VAR s: ARRAY OF CHAR; VAR numCh, res: INTEGER);
    VAR dev0: UARTdev.Device; uartInt: UARTint;
  BEGIN
    dev0 := dev(UARTdev.Device);
    uartInt := uartInts[dev0.uartNo];
    uartInt.strAddr := SYSTEM.ADR(s);
    uartInt.bufLen := LEN(s);
    uartInt.cnt := 0;
    uartInt.res := TextIO.NoError;
    UARTdev.EnableInt(dev0, {UARTdev.IMSC_RXIM, UARTdev.IMSC_RTIM});
    GPIO.Clear({RxHandlerFifoPin, RxHandlerTimeoutPin});
    Kernel.AwaitDeviceFlags(dev0.IMSC, {}, {UARTdev.IMSC_RXIM}); (* await int disabled *)
    numCh := uartInt.cnt;
    res := uartInt.res
  END GetString;


  PROCEDURE DeviceStatus*(dev: TextIO.Device): SET;
  (*
    Mainly for getting fifo full/empty status, ie.
    "TxAvail" and "RxAvail" extended for fifo
    bits as defined in UARTdev.
  *)
    VAR dev0: UARTdev.Device;
  BEGIN
    dev0 := dev(UARTdev.Device);
    RETURN UARTdev.Flags(dev0)
  END DeviceStatus;


  PROCEDURE Install*(dev: UARTdev.Device);
  BEGIN
    NEW(uartInts[dev.uartNo]); ASSERT(uartInts[dev.uartNo] # NIL, Errors.HeapOverflow);
    uartInts[dev.uartNo].dev := dev;
    Exceptions.InstallIntHandler(dev.intNo, rxHandler);
    Exceptions.SetIntPrio(dev.intNo, RxIntPrio);
    Exceptions.EnableInt({dev.intNo});
    UARTdev.SetFifoLvl(dev, TxFifoLvl, RxFifoLvl)
  END Install;


  PROCEDURE init;
  BEGIN
    GPIO.SetFunction(RxPin, GPIO.Fsio);
    GPIO.SetFunction(RxHandlerFifoPin, GPIO.Fsio);
    GPIO.SetFunction(RxHandlerTimeoutPin, GPIO.Fsio);
    GPIO.OutputEnable({RxPin, RxHandlerFifoPin, RxHandlerTimeoutPin})
  END init;

BEGIN
  init
END UARTkstr.
