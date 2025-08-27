MODULE UARTstrKint;
(**
  Oberon RTK Framework v2.1
  --
  UART string device driver for kernel-v4 use
  Output only for now (PutString).
  --
  See https://oberon-rtk.org/docs/examples/v2/k4print/
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Kernel, UARTdev, TextIO, Exceptions, Errors;

  CONST
    MsgStrLen = 24;

    StateWriteUART = 0;
    StateAwaitDevInt = 1;

    TxFifoLvl = UARTdev.TXIFLSEL_val_18;  (* 1/8 = 4 entries *)
    RxFifoLvl = UARTdev.RXIFLSEL_val_48;  (* unused, no rx implemented yet *)


  TYPE
    PrintMsg = POINTER TO PrintMsgDesc;
    PrintMsgDesc = RECORD (Kernel.MessageDesc)
      str: ARRAY MsgStrLen OF CHAR;
      numChar: INTEGER
    END;

    DriverActor = POINTER TO DriverActorDesc;
    DriverActorDesc = RECORD (Kernel.ActorDesc)
      states: ARRAY 2 OF Kernel.ActorRun;
      uartNo: INTEGER
    END;

    UARTctx = POINTER TO UARTctxDesc;
    UARTctxDesc = RECORD
      dev: UARTdev.Device;
      rdyQ: Kernel.ReadyQ;
      printEvQ: Kernel.EventQ;
      printMsgP: Kernel.MessagePool;
      devEvQ: Kernel.EventQ;
      devMsg: Kernel.Message;
      act: DriverActor;
      ix: INTEGER;
      msg: PrintMsg
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
  (* write msg.str out to UART FIFO, then await UART int *)
    VAR a0: DriverActor; msg: PrintMsg; ux: UARTctx;
  BEGIN
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin4});*)
    a0 := act(DriverActor);
    msg := a0.msg(PrintMsg);
    ux := uartCon[a0.uartNo];
    ux.msg := msg;
    ux.ix := 1;
    SYSTEM.PUT(ux.dev.TDR, msg.str[0]);
    a0.run := a0.states[StateAwaitDevInt];
    Kernel.GetMsg(uartCon[a0.uartNo].devEvQ, a0);
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin4})*)
  END writeUART;


  PROCEDURE awaitDevInt(act: Kernel.Actor);
  (* UART int msg received, go get next msg.str from print queue *)
    VAR a0: DriverActor;
  BEGIN
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin3});*)
    a0 := act(DriverActor);
    a0.run := a0.states[StateWriteUART];
    Kernel.GetMsg(uartCon[a0.uartNo].printEvQ, a0);
    (*SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin3});*)
  END awaitDevInt;


  PROCEDURE init(act: Kernel.Actor);
    VAR a0: DriverActor;
  BEGIN
    a0 := act(DriverActor);
    a0.run := a0.states[StateWriteUART];
    Kernel.GetMsg(uartCon[a0.uartNo].printEvQ, a0)
  END init;


  PROCEDURE initActor(act: Kernel.Actor; uartNo: INTEGER);
    VAR a0: DriverActor;
  BEGIN
    a0 := act(DriverActor);
    a0.states[StateWriteUART] := writeUART;
    a0.states[StateAwaitDevInt] := awaitDevInt;
    a0.uartNo := uartNo
  END initActor;

(*
  PROCEDURE devHandler[0];
  (* generic for both UARTs *)
    CONST
      UART0excNo = MCU.PPB_UART0_IRQ + MCU.PPB_IRQ_BASE;
      UART1excNo = MCU.PPB_UART1_IRQ + MCU.PPB_IRQ_BASE;
    VAR excNo, uartNo: INTEGER; ux: UARTctx; mis: SET;
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {Pin2});
    Exceptions.GetExcNo(excNo);
    ASSERT((excNo = UART0excNo) OR (excNo = UART1excNo), Errors.ProgError);
    uartNo := excNo - UART0excNo;
    ux := uartCon[uartNo];
    SYSTEM.GET(ux.dev.MIS, mis); (* get status *)
    IF UARTdev.MIS_TXMIS IN mis THEN
      IF ux.ix < ux.msg.numChar THEN
        SYSTEM.PUT(ux.dev.TDR, ux.msg.str[ux.ix]);
        INC(ux.ix)
      ELSE
        SYSTEM.PUT(ux.dev.ICR + MCU.ASET, {UARTdev.ICR_TXIC}); (* clear/deassert int *)
        Kernel.PutMsgAwaited(ux.devEvQ, ux.devMsg);
      END
    END;
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {Pin2})
  END devHandler;
*)

  PROCEDURE devHandler0[0];
    VAR ux: UARTctx; mis: SET;
  BEGIN
    ux := uartCon[0];
    SYSTEM.GET(ux.dev.MIS, mis); (* get status *)
    IF UARTdev.MIS_TXMIS IN mis THEN
      IF ux.ix < ux.msg.numChar THEN
        SYSTEM.PUT(ux.dev.TDR, ux.msg.str[ux.ix]);
        INC(ux.ix)
      ELSE
        SYSTEM.PUT(ux.dev.ICR + MCU.ASET, {UARTdev.ICR_TXIC}); (* clear/deassert int *)
        Kernel.PutMsgAwaited(ux.devEvQ, ux.devMsg);
      END
    END
  END devHandler0;


  PROCEDURE devHandler1[0];
    VAR ux: UARTctx; mis: SET;
  BEGIN
    ux := uartCon[1];
    SYSTEM.GET(ux.dev.MIS, mis); (* get status *)
    IF UARTdev.MIS_TXMIS IN mis THEN
      IF ux.ix < ux.msg.numChar THEN
        SYSTEM.PUT(ux.dev.TDR, ux.msg.str[ux.ix]);
        INC(ux.ix)
      ELSE
        SYSTEM.PUT(ux.dev.ICR + MCU.ASET, {UARTdev.ICR_TXIC}); (* clear/deassert int *)
        Kernel.PutMsgAwaited(ux.devEvQ, ux.devMsg);
      END
    END
  END devHandler1;


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
    (* device event queue *)
    Kernel.NewEvQ(ux.devEvQ);
    (* print message pool *)
    Kernel.NewMsgPool(ux.printMsgP, makePrintMsg, numMsg);
    (* device message *)
    NEW(ux.devMsg);
    Kernel.InitMsg(ux.devMsg);
    (* print actor *)
    NEW(ux.act);
    Kernel.InitAct(ux.act, init, 0); initActor(ux.act, ux.dev.uartNo);
    (* uart interrupt *)
    IF ux.dev.uartNo = 0 THEN
      Exceptions.InstallIntHandler(dev.intNo, devHandler0)
    ELSE
      Exceptions.InstallIntHandler(dev.intNo, devHandler1)
    END;
    Exceptions.SetIntPrio(dev.intNo, intPrio);
    Exceptions.ClearPendingInt(dev.intNo);
    Exceptions.EnableInt(dev.intNo);
    UARTdev.SetFifoLvl(dev, TxFifoLvl, RxFifoLvl);
    UARTdev.EnableInt(dev, {UARTdev.IMSC_TXIM});
    (* get started *)
    Kernel.RunAct(ux.act, ux.rdyQ)
  END Install;

END UARTstrKint.
