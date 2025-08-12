MODULE ReadyQueues;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  Actor ready queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, T := KernelTypes, Exceptions, Errors, Out, GPIO;

  CONST
    PutPin = 16;

  PROCEDURE* Init*(q: T.ReadyQ; cid, id: INTEGER);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL;
    q.intNo := 0;
    q.cid := cid;
    q.id := id
  END Init;


  PROCEDURE Install*(q: T.ReadyQ; h: T.RunHandler; intNo, prio, cid, id: INTEGER);
  BEGIN
    Init(q, cid, id);
    q.intNo := intNo;
    Exceptions.InstallIntHandler(intNo, h);
    Exceptions.SetIntPrio(intNo, prio);
    Exceptions.EnableInt(intNo)
  END Install;


  PROCEDURE* Put*(q: T.ReadyQ; act: T.Actor);
  BEGIN
    (*
    Out.String("rdyQ put");
    Out.Hex(SYSTEM.VAL(INTEGER, q), 12);
    Out.Hex(SYSTEM.VAL(INTEGER, act), 12);
    Out.Ln;
    *)
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {PutPin});
    SYSTEM.EMITH(MCU.CPSID_I);
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL;
    IF q.intNo # 0 THEN
      (*
      Out.String("rdyQ trigger"); Out.Ln;
      *)
      SYSTEM.PUT(MCU.PPB_STIR, q.intNo); (* trigger the readyQ's interrupt *)
    END;
    SYSTEM.EMITH(MCU.CPSIE_I);
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {PutPin})
  END Put;


  PROCEDURE* Get*(q: T.ReadyQ; VAR act: T.Actor);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    act := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Get;


BEGIN
  GPIO.SetFunction(PutPin, MCU.IO_BANK0_Fsio);
  GPIO.OutputEnable({PutPin});
  GPIO.Clear({PutPin})
END ReadyQueues.
