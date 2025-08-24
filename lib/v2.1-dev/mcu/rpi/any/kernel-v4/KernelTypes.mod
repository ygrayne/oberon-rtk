MODULE KernelTypes;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v4
  Type definitions.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  TYPE
    Actor* = POINTER TO ActorDesc;
    Message* = POINTER TO MessageDesc;
    ReadyQ* = POINTER TO ReadyQueueDesc;
    MessageQ* = POINTER TO MessageQueueDesc;
    ActorQ* = POINTER TO ActorQueueDesc;
    EventQ* = POINTER TO EventQueueDesc;
    MessagePool* = POINTER TO MessagePoolDesc;

    ActorRun* = PROCEDURE(actor: Actor);
    ActorDesc* = RECORD
      (* kernel data *)
      id*: INTEGER;
      rdyQ*: ReadyQ;
      run*: ActorRun;
      msg*: Message;
      ticker*: INTEGER;
      next*: Actor;
      (* user data *)
      time*: INTEGER
    END;

    MessageDesc* = RECORD
      next*: Message;
      pool*: MessagePool;
      data*: INTEGER (* application data *)
    END;

    RunHandler* = PROCEDURE;
    ReadyQueueDesc* = RECORD
      head*, tail*: Actor;
      intNo*: INTEGER;
      cid*, id*: INTEGER
    END;

    MessageQueueDesc* = RECORD
      head*, tail*: Message
    END;

    ActorQueueDesc* = RECORD
      head*, tail*: Actor
    END;

    EventQueueDesc* = RECORD
      msgQ*: MessageQ;
      actQ*: ActorQ
    END;

    MessagePoolDesc* = RECORD
      head*: Message;
      cnt*: INTEGER
    END;

END KernelTypes.
