MODULE Coroutines;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Simple coroutines
  --
  MCU: MCX-A346
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors;

  TYPE
    PROC* = PROCEDURE;
    Coroutine* = POINTER TO CoroutineDesc;
    CoroutineDesc* = RECORD
      sp: INTEGER; (* stored stack pointer when transferring *)
      proc: PROC; (* the coroutine's code *)
      stAddr: INTEGER; (* stack address *)
      stSize: INTEGER; (* stack size *)
      id: INTEGER (* same as thread id *)
    END;


  PROCEDURE* Reset*(cor: Coroutine);
    VAR addr: SET;
  BEGIN
    ASSERT(cor # NIL, Errors.PreCond);
    (* set up the stack memory for the initial 'Transfer' to 'cor' *)
    cor.sp := cor.stAddr + cor.stSize;
    (* skip top value = stack seal, see module Memory*)
    DEC(cor.sp, 4);
    (* put 'lr' *)
    DEC(cor.sp, 4);
    addr := SYSTEM.VAL(SET, cor.proc);
    INCL(addr, 0); (* thumb bit *)
    SYSTEM.PUT(cor.sp, addr);
    (* keep slot for 't' *)
    DEC(cor.sp, 4);
    (* put 'f', see 'Transfer' *)
    DEC(cor.sp, 4);
    SYSTEM.PUT(cor.sp, SYSTEM.VAL(INTEGER, cor))
    (* initialised stack: with SP = 0: 'f' = 'cor', +4: don't care, +8: 'lr' *)
  END Reset;


  PROCEDURE Allocate*(cor: Coroutine; p: PROC);
  BEGIN
    ASSERT(cor # NIL, Errors.PreCond);
    cor.proc := p;
    Reset(cor)
  END Allocate;


  PROCEDURE* Init*(cor: Coroutine; stAddr, stSize, id: INTEGER);
  BEGIN
    ASSERT(cor # NIL, Errors.PreCond);
    cor.stAddr := stAddr;
    cor.stSize := stSize;
    cor.id := id
  END Init;


  PROCEDURE Transfer*(f, t: Coroutine);
    CONST SP = 13; LR = 14; R12 = 12;
  BEGIN
    (* enter "as" f, f's stack in use *)
    (* prologue: push caller's 'lr' and parameters 'f' and 't' onto f's stack *)
    (* stack: 0: 'f', +4: 't', +8: 'lr' *)
    (* stack switching *)
    (* save f's SP *)
    f.sp := SYSTEM.REG(SP);
    (* switch stack: load t's SP *)
    (* 't' is still accessible on f's stack here *)
    SYSTEM.LDREG(SP, t.sp);
    (* now t's stack in use *)
    (* stack: 0: 'f', +4: 't', +8: 'lr' *)
    (* note: meaning of 'f' and 't' as per the procedure call when transferring AWAY from 't' *)
    (* ie. 'f' is the coroutine on the stack here that we transfer to *)
    SYSTEM.LDREG(R12, f.id);
    SYSTEM.LDREG(LR, 0); (* get clean stack trace -- overkill? :) *)
    (* epilogue: adjust stack by +8, pop 'lr' from stack into 'pc' *)
    (* continue "as" t with 'lr' as 'pc' value *)
    (* Voila. *)
  END Transfer;

END Coroutines.
