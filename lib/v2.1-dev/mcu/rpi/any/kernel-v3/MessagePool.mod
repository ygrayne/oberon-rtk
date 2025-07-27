MODULE MessagePool;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
  Message pool for event generators/sources.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Types, Errors;

  TYPE
    Make* = PROCEDURE(): Types.Message;


  PROCEDURE Init*(mp: Types.MessagePool; make: Make; n: INTEGER);
    VAR m: Types.Message; i: INTEGER;
  BEGIN
    ASSERT(mp # NIL, Errors.PreCond);
    mp.head := NIL;
    i := 0;
    REPEAT
      m := make(); ASSERT(m # NIL, Errors.HeapOverflow);
      m.next := mp.head;
      mp.head := m;
      m.pool := mp;
      INC(i)
    UNTIL i = n;
    mp.cnt := n
  END Init;


  PROCEDURE Get*(mp: Types.MessagePool; VAR msg: Types.Message);
  BEGIN
    SYSTEM.EMIT(MCU.CPSID);
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
    SYSTEM.EMIT(MCU.CPSIE)
  END Get;


  PROCEDURE Put*(mp: Types.MessagePool; msg: Types.Message);
  (* caller protects queue access *)
  BEGIN
    IF msg # NIL THEN
      msg.next := mp.head;
      mp.head := msg;
      INC(mp.cnt)
    END
    (*Out.String("msg cnt put: "); Out.Int(mp.cnt, 0); Out.Ln;*)
  END Put;

END MessagePool.
