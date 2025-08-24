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

  IMPORT SYSTEM, MCU := MCU2, T := KernelTypes, Exceptions, Errors;

  CONST
    ExcPrioBlock = MCU.PPB_ExcPrioHigh;


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
    CONST R03 = 3;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    IF q.head = NIL THEN
      q.head := act
    ELSE
      q.tail.next := act
    END;
    q.tail := act;
    act.next := NIL;
    IF q.intNo # 0 THEN
      SYSTEM.PUT(MCU.PPB_STIR, q.intNo); (* trigger the readyQ's interrupt *)
    END;
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
  END Put;


  PROCEDURE* Get*(q: T.ReadyQ; VAR act: T.Actor);
    CONST R03  = 3;
  BEGIN
    SYSTEM.EMIT(MCU.MRS_R07_BASEPRI);
    SYSTEM.LDREG(R03, ExcPrioBlock);
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R03);
    act := q.head;
    IF q.head # NIL THEN
      q.head := q.head.next
    END;
    SYSTEM.EMIT(MCU.MSR_BASEPRI_R07)
  END Get;

END ReadyQueues.
