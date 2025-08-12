MODULE MessagePools;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  Message pools for event generators/sources.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, T := KernelTypes, Errors;

  TYPE
    Make* = PROCEDURE(): T.Message;


  PROCEDURE makeMsg(): T.Message;
    VAR m: T.Message;
  BEGIN
    NEW(m); ASSERT(m # NIL, Errors.HeapOverflow);
    RETURN m
  END makeMsg;


  PROCEDURE Init*(mp: T.MessagePool; make: Make; n: INTEGER);
    VAR m: T.Message; i: INTEGER;
  BEGIN
    ASSERT(mp # NIL, Errors.PreCond);
    mp.head := NIL;
    IF make = NIL THEN
      make := makeMsg
    END;
    i := 0;
    REPEAT
      m := make(); (* NIL check in make() *)
      m.next := mp.head;
      mp.head := m;
      m.pool := mp;
      INC(i)
    UNTIL i = n;
    mp.cnt := n
  END Init;


  PROCEDURE Get*(mp: T.MessagePool; VAR msg: T.Message);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    msg := mp.head;
    IF msg # NIL THEN
      IF mp.head.next # NIL THEN
        mp.head := mp.head.next
      ELSE
        mp.head := NIL
      END;
      DEC(mp.cnt);
      (*Out.String("msg cnt get: "); Out.Int(mp.cnt, 0); Out.Ln;*)
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
  END Get;


  PROCEDURE Put*(mp: T.MessagePool; msg: T.Message);
  BEGIN
    SYSTEM.EMITH(MCU.CPSID_I);
    IF msg.pool # NIL THEN
      msg.next := mp.head;
      mp.head := msg;
      INC(mp.cnt)
    END;
    SYSTEM.EMITH(MCU.CPSIE_I)
    (*Out.String("msg cnt put: "); Out.Int(mp.cnt, 0); Out.Ln;*)
  END Put;

END MessagePools.
