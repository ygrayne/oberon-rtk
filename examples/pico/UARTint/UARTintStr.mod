MODULE UARTintStr;
(**
  Oberon RTK Framework
  --
  UART string output device driver, using interrupts
  For example program: https://oberon-rtk.org/examples/uartint/
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, UARTdev, TextIO, LEDext, GPIO, Exceptions;

  CONST
    PutPinNo = 16;
    IntDisablePinNo = 17;
    TxFifoLvlPinNo = 18;
    AwaitPinNo = 19;


    IntMask* = {UARTdev.IMSC_TXIM};
    IntPrio = 1;
    TxFifoLvl* = UARTdev.TXIFLSEL_val_48;
    RxFifoLvl* = UARTdev.RXIFLSEL_val_48;


  TYPE
    UARTint = RECORD
      dev: UARTdev.Device;
      strAddr: INTEGER;
      numChar: INTEGER;
      cnt: INTEGER
    END;

  VAR
    uartInt: ARRAY UARTdev.NumUART OF UARTint;


  PROCEDURE txFifoLvl[0];
  (* for UART 0 only *)
    VAR x: INTEGER; ch: CHAR; (* intStatus: SET; *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {TxFifoLvlPinNo});
    (*
    UARTdev.GetIntStatus(uartInt[0].dev, intStatus);
    ASSERT(UARTdev.IMSC_TXIM IN intStatus);
    UARTdev.ClearInt(uartInt[0].dev, intStatus);
    *)
    (* refill fifo from watermark level *)
    WHILE (uartInt[0].cnt < uartInt[0].numChar) & ~SYSTEM.BIT(uartInt[0].dev.FR, UARTdev.FR_TXFF) DO
      SYSTEM.GET(uartInt[0].strAddr, ch);
      SYSTEM.PUT(uartInt[0].dev.TDR, ch);
      INC(uartInt[0].cnt);
      INC(uartInt[0].strAddr)
    END;
    x := 0; WHILE x < 200 DO INC(x) END;
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {TxFifoLvlPinNo});
    (* if done, disable int *)
    IF uartInt[0].cnt = uartInt[0].numChar THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {IntDisablePinNo});
      UARTdev.DisableInt(uartInt[0].dev, {UARTdev.IMSC_TXIM});
      x := 0; WHILE x < 200 DO INC(x) END;
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {IntDisablePinNo});
    END
  END txFifoLvl;


  PROCEDURE InstallIntHandlers*(dev: UARTdev.Device);
    VAR en: SET;
  BEGIN
    uartInt[dev.uartNo].dev := dev;
    Exceptions.InstallIntHandler(dev.intNo, txFifoLvl);
    Exceptions.SetIntPrio(dev.intNo, IntPrio);
    en := {dev.intNo}; (* workaround v9.1 *)
    Exceptions.EnableInt(en)
  END InstallIntHandlers;


  PROCEDURE PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UARTdev.Device; intStatus: SET; cnt, uartNo, x: INTEGER;
  BEGIN
    dev0 := dev(UARTdev.Device);
    uartNo := dev0.uartNo;
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {TxFifoLvlPinNo, IntDisablePinNo, AwaitPinNo});
    (* don't interfere with int handler, use int enabled hw flag as sentinel *)
    UARTdev.GetEnabledInt(dev0, intStatus);
    WHILE UARTdev.IMSC_TXIM IN intStatus DO
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {AwaitPinNo});
      UARTdev.GetEnabledInt(dev0, intStatus);
    END;
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {AwaitPinNo});
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {PutPinNo});
    (* fill tx fifo *)
    cnt := 0;
    WHILE (cnt < numChar) & ~SYSTEM.BIT(dev0.FR, UARTdev.FR_TXFF) DO
      SYSTEM.PUT(dev0.TDR, s[cnt]);
      INC(cnt)
    END;
    x := 0; WHILE x < 200 DO INC(x) END;
    (* if any, leave rest to int handler *)
    IF cnt < numChar THEN
      uartInt[uartNo].strAddr := SYSTEM.ADR(s[cnt]);
      uartInt[uartNo].numChar := numChar;
      uartInt[uartNo].cnt := cnt;
      UARTdev.EnableInt(dev0, {UARTdev.IMSC_TXIM});
      (*
      UARTdev.GetEnabledInt(dev0, intStatus);
      ASSERT(UARTdev.IMSC_TXIM IN intStatus)
      *)
    END;
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {PutPinNo})
  END PutString;


  PROCEDURE init;
  (* test init *)
  BEGIN
    GPIO.SetFunction(PutPinNo, GPIO.Fsio);
    GPIO.SetFunction(TxFifoLvlPinNo, GPIO.Fsio);
    GPIO.SetFunction(IntDisablePinNo, GPIO.Fsio);
    GPIO.SetFunction(AwaitPinNo, GPIO.Fsio);
    GPIO.OutputEnable({PutPinNo, IntDisablePinNo, TxFifoLvlPinNo, AwaitPinNo});
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {PutPinNo, IntDisablePinNo, TxFifoLvlPinNo, AwaitPinNo})
  END init;


BEGIN
  init
END UARTintStr.
