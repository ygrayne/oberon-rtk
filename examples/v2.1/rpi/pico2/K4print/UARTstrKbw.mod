MODULE UARTstrKbw;
(**
  Oberon RTK Framework v2.1
  --
  UART string device driver for kernel-v4 use.
  Output only for now (PutString).
  Version with GPIO pins for test program K4print.
  --
  See https://oberon-rtk.org/docs/examples/v2/k4print/
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Kernel, UARTdev, TextIO, Errors;

  CONST
    MsgStrLen = 24;

    (* test GPIO pins are set up in main program module *)
    Pin2 = 17;
    Pin3 = 18;
    Pin4 = 19;

  TYPE
    PrintMsg = POINTER TO PrintMsgDesc;
    PrintMsgDesc = RECORD (Kernel.MessageDesc)
      str: ARRAY MsgStrLen OF CHAR;
      numChar: INTEGER
    END;

    DriverActor = POINTER TO DriverActorDesc;
    DriverActorDesc = RECORD (Kernel.ActorDesc)
      uartNo: INTEGER
    END;

    UARTctx = POINTER TO UARTctxDesc;
    UARTctxDesc = RECORD
      dev: UARTdev.Device;
      rdyQ: Kernel.ReadyQ;
      printEvQ: Kernel.EventQ;
      printMsgP: Kernel.MessagePool;
      act: DriverActor
    END;

  VAR
    uartCon: ARRAY UARTdev.NumUART OF UARTctx;


  PROCEDURE PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UARTdev.Device; i, nc: INTEGER; m: Kernel.Message; msg: PrintMsg; ux: UARTctx;
  BEGIN
    dev0 := dev(UARTdev.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    IF numChar > 0 THEN
      ux := uartCon[dev0.uartNo];
      nc := 0;
      WHILE nc < numChar DO
        Kernel.GetFromMsgPool(ux.printMsgP, m);
        IF m # NIL THEN
          msg := m(PrintMsg);
          i := 0;
          WHILE (i < MsgStrLen) & (nc < numChar) DO
            msg.str[i] := s[nc];
            INC(i); INC(nc)
          END;
          msg.numChar := i;
          Kernel.PutMsg(ux.printEvQ, msg)
        ELSE
          nc := numChar
        END
      END
    END
  END PutString;


  PROCEDURE writeUART(act: Kernel.Actor);
  (* write msg.str out to UART FIFO, then get next msg.str *)
    VAR a0: DriverActor; msg: PrintMsg; n: INTEGER; ux: UARTctx;
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin2});
    a0 := act(DriverActor);
    msg := a0.msg(PrintMsg);
    ux := uartCon[a0.uartNo];
    n := 0;
    WHILE n < msg.numChar DO
      IF ~SYSTEM.BIT(ux.dev.FR, UARTdev.FR_TXFF) THEN
        SYSTEM.PUT(ux.dev.TDR, msg.str[n]);
        INC(n)
      END
    END;
    Kernel.GetMsg(uartCon[a0.uartNo].printEvQ, a0);
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin2})
  END writeUART;


  PROCEDURE init(act: Kernel.Actor);
    VAR a0: DriverActor;
  BEGIN
    a0 := act(DriverActor);
    a0.run := writeUART;
    Kernel.GetMsg(uartCon[a0.uartNo].printEvQ, a0)
  END init;


  PROCEDURE initActor(act: Kernel.Actor; uartNo: INTEGER);
    VAR a0: DriverActor;
  BEGIN
    a0 := act(DriverActor);
    a0.uartNo := uartNo
  END initActor;


  PROCEDURE printRdyHandler0[0];
  BEGIN
    Kernel.RunQueue(uartCon[0].rdyQ)
  END printRdyHandler0;

  PROCEDURE printRdyHandler1[0];
  BEGIN
    Kernel.RunQueue(uartCon[1].rdyQ)
  END printRdyHandler1;


  PROCEDURE DeviceStatus*(dev: TextIO.Device): SET;
    VAR dev0: UARTdev.Device;
  BEGIN
    dev0 := dev(UARTdev.Device);
    RETURN UARTdev.Flags(dev0)
  END DeviceStatus;


  PROCEDURE makePrintMsg(): Kernel.Message;
    VAR msg: PrintMsg;
  BEGIN
    NEW(msg); ASSERT(msg # NIL, Errors.HeapOverflow);
    RETURN msg
  END makePrintMsg;


PROCEDURE Install*(dev: UARTdev.Device; rdyQintNo, intPrio, numMsg: INTEGER);
    VAR ux: UARTctx;
  BEGIN
    NEW(uartCon[dev.uartNo]); ASSERT(uartCon[dev.uartNo] # NIL, Errors.HeapOverflow);
    ux := uartCon[dev.uartNo];
    ux.dev := dev;
    (* ready queue *)
    Kernel.NewRdyQ(ux.rdyQ, 0, 0);
    IF ux.dev.uartNo = 0 THEN
      Kernel.InstallRdyQ(ux.rdyQ, printRdyHandler0, rdyQintNo, intPrio)
    ELSE
      Kernel.InstallRdyQ(ux.rdyQ, printRdyHandler1, rdyQintNo, intPrio)
    END;
    (* print event queue *)
    Kernel.NewEvQ(ux.printEvQ);
    (* print message pool *)
    Kernel.NewMsgPool(ux.printMsgP, makePrintMsg, numMsg);
    (* print actor *)
    NEW(ux.act);
    Kernel.InitAct(ux.act, init, 0); initActor(ux.act, ux.dev.uartNo);
    (* get started *)
    Kernel.RunAct(ux.act, ux.rdyQ)
  END Install;

END UARTstrKbw.
