MODULE Semaphores;
(**
  Oberon RTK Framework v2
  --
  Semaphores for exclusive access to resources shared among threads
  --
  Based on signals
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Signals, Errors;

  TYPE
    Semaphore* = POINTER TO SemaphoreDesc;
    SemaphoreDesc* = RECORD
      signal: Signals.Signal;
      claimed: BOOLEAN
    END;

  PROCEDURE Claim*(s: Semaphore);
  BEGIN
    IF s.claimed THEN
      Signals.Await(s.signal)
    ELSE
      s.claimed := TRUE
    END
  END Claim;


  PROCEDURE Release*(s: Semaphore);
  BEGIN
    ASSERT(s.claimed, Errors.ConsCheck); (* unbalanced claim/release sequence *)
    IF Signals.Awaited(s.signal) THEN
      Signals.Send(s.signal)
    ELSE
      s.claimed := FALSE
    END
  END Release;


  PROCEDURE* Claimed*(s: Semaphore): BOOLEAN;
    RETURN s.claimed
  END Claimed;


  PROCEDURE Init*(s: Semaphore);
  BEGIN
    s.claimed := FALSE;
    NEW(s.signal); ASSERT(s.signal # NIL, Errors.HeapOverflow);
    Signals.Init(s.signal)
  END Init;

END Semaphores.
