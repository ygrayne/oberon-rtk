MODULE Actors;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  Actor as base for a task-based control process.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT T := KernelTypes, Errors;

  PROCEDURE* Init*(act: T.Actor; init: T.ActorRun; id: INTEGER);
  BEGIN
    ASSERT(act # NIL, Errors.PreCond);
    act.id := id;
    act.run := init;
    act.rdyQ := NIL;
    act.msg := NIL;
    act.time := 0;
    act.next := NIL
  END Init;


  PROCEDURE Run*(act: T.Actor; rdyQ: T.ReadyQ);
  BEGIN
    act.rdyQ := rdyQ;
    act.run(act)
  END Run;

END Actors.
