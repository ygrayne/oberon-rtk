MODULE Semaphores;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Kernel-v4
  Semaphores for exclusive access to resources shared among actors
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Kernel, Errors;

  TYPE
    Semaphore* = POINTER TO SemaphoreDesc;
    SemaphoreDesc* = RECORD
      evQ: Kernel.EventQ;
      msg: Kernel.Message
    END;


  PROCEDURE Claim*(s: Semaphore; act: Kernel.Actor);
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
    Kernel.NewEvQ(s.evQ);
    NEW(s.msg); ASSERT(s.msg # NIL, Errors.HeapOverflow);
    Kernel.InitMsg(s.msg);
    Kernel.PutMsg(s.evQ, s.msg)
  END Init;

END Semaphores.
