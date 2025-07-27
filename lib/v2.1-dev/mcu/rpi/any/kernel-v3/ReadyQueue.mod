MODULE ReadyQueue;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Ready queue: handle actors ready to run triggered by messages.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Types, Exceptions, Errors, Out;

  TYPE
    Queue* = Types.ReadyQueue;


  PROCEDURE Install*(q: Queue; h: Types.RunHandler; intNo, prio, cid, id: INTEGER);
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


  PROCEDURE Put*(q: Queue; act: Types.Actor);
  (* caller protects queue *)
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    Out.String("rdyQ put");
    Out.Hex(SYSTEM.VAL(INTEGER, q), 12);
    Out.Hex(SYSTEM.VAL(INTEGER, act), 12);
    Out.Ln;
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL;
    SYSTEM.PUT(MCU.PPB_STIR, q.intNo) (* trigger the readyQ's interrupt *)
  END Put;


  PROCEDURE Run*(q: Queue);
  (* to be called by run int handler of ready queue *)
    VAR act: Types.Actor;
  BEGIN
    SYSTEM.EMIT(MCU.CPSID);
    Out.String("rdyQ run");
    Out.Hex(SYSTEM.VAL(INTEGER, q), 12);
    Out.Ln;
    act := q.head;
    WHILE act # NIL DO
      Out.Hex(SYSTEM.VAL(INTEGER, act), 12); Out.Ln;
      q.head := q.head.next;
      IF q.head = NIL THEN
        q.tail := NIL
      END;
      SYSTEM.EMIT(MCU.CPSIE);
      act.run(act); (* must re-subscribe to a MessageQueue *)
      SYSTEM.EMIT(MCU.CPSID);
      act := q.head
    END;
    SYSTEM.EMIT(MCU.CPSIE)
  END Run;

END ReadyQueue.
