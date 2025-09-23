MODULE ReadyQueue;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Actor ready queues.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Types, Exceptions, Errors, Out;


  PROCEDURE Install*(q: Types.ReadyQueue; h: Types.RunHandler; intNo, prio, cid, id: INTEGER);
  BEGIN
    ASSERT(q # NIL, Errors.PreCond);
    q.head := NIL;
    q.tail := NIL;
    q.cid := cid;
    q.id := id;
    (* no need to store these *)
    q.handler := h;
    q.intNo := intNo;
    q.prio := prio;
    (* --- *)
    Exceptions.InstallIntHandler(intNo, h);
    Exceptions.SetIntPrio(intNo, prio);
    Exceptions.EnableInt(intNo)
  END Install;


  PROCEDURE Put*(q: Types.ReadyQueue; act: Types.Actor);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Out.String("rdyQ put");
    Out.Hex(SYSTEM.VAL(INTEGER, q), 12);
    Out.Hex(SYSTEM.VAL(INTEGER, act), 12);
    Out.Ln;
    SYSTEM.EMITH(MCU.CPSID_I);
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL;
    SYSTEM.PUT(MCU.PPB_STIR, q.intNo); (* trigger the readyQ's interrupt *)
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Put;


  PROCEDURE Get*(q: Types.ReadyQueue; VAR act: Types.Actor);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    act := q.head;
    IF act # NIL THEN
      q.head := q.head.next
    ELSE
      q.tail := NIL
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Get;


END ReadyQueue.
