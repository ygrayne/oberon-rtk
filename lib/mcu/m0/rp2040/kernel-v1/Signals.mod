MODULE Signals;
(**
  Oberon RTK Framework
  Signals for thread synchronisation
  --
  Based on Programming in Modula-2, N. Wirth, 3rd edition, 1985
  --
  Copyright (c) 2020-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Kernel;

  TYPE
    Signal* = POINTER TO SignalDesc;
    SignalDesc* = RECORD
      queue: Kernel.Thread
    END;

  PROCEDURE queue(s: Signal);
    VAR t: Kernel.Thread;
  BEGIN
    IF s.queue = NIL THEN
      s.queue := Kernel.Ct();
      s.queue.next := NIL
    ELSE
      t := s.queue;
      WHILE t.next # NIL DO
        t := t.next
      END;
      t.next := Kernel.Ct();
      t.next.next := NIL
    END
  END queue;


  PROCEDURE Await*(s: Signal);
  BEGIN
    queue(s);
    Kernel.SuspendMe
  END Await;


  PROCEDURE Send*(s: Signal);
    VAR t: Kernel.Thread;
  BEGIN
    IF s.queue # NIL THEN
      t := s.queue;
      s.queue := t.next;
      Kernel.Enable(t)
    END
  END Send;


  PROCEDURE* Awaited*(s: Signal): BOOLEAN;
    RETURN s.queue # NIL
  END Awaited;


  PROCEDURE Init*(s: Signal);
  BEGIN
    s.queue := NIL
  END Init;

END Signals.

