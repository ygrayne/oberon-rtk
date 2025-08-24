MODULE Semaphores;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  Semaphores for exclusive access to resources shared among actors
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    T := KernelTypes, Kernel, ActorQueues, MessageQueues, Errors;

  TYPE
    Semaphore* = POINTER TO SemaphoreDesc;
    SemaphoreDesc* = RECORD
      evQ: T.EventQ;
      msg: T.Message
    END;


  PROCEDURE Claim*(s: Semaphore; act: T.Actor);
  BEGIN
    Kernel.GetMsg(s.evQ, act)
  END Claim;


  PROCEDURE Release*(s: Semaphore);
  BEGIN
    Kernel.PutMsg(s.evQ, s.msg)
  END Release;


  PROCEDURE Init*(s: Semaphore);
  BEGIN
    ASSERT(s # NIL, Errors.PreCond);
    NEW(s.evQ); ASSERT(s.evQ # NIL, Errors.HeapOverflow);
    NEW(s.evQ.msgQ); ASSERT(s.evQ.msgQ # NIL, Errors.HeapOverflow);
    NEW(s.evQ.actQ); ASSERT(s.evQ.actQ # NIL, Errors.HeapOverflow);
    MessageQueues.Init(s.evQ.msgQ);
    ActorQueues.Init(s.evQ.actQ);
    NEW(s.msg); ASSERT(s.msg # NIL, Errors.HeapOverflow);
    s.msg.pool := NIL;
    MessageQueues.Put(s.evQ.msgQ, s.msg)
  END Init;

END Semaphores.
