MODULE Types;
(**
  Oberon RTK Framework v2.1
  --
  Kernel-v3
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
    ReadyQueue* = POINTER TO ReadyQueueDesc;
    MessageQueue* = POINTER TO MessageQueueDesc;
    ActorQueue* = POINTER TO ActorQueueDesc;
    EventQueue* = POINTER TO EventQueueDesc;
    MessagePool* = POINTER TO MessagePoolDesc;

    ActorRun* = PROCEDURE(actor: Actor);
    ActorDesc* = RECORD
      id*: INTEGER;
      rdyQ*: ReadyQueue;
      run*: ActorRun;
      msg*: Message;
      next*: Actor
    END;

    MessageDesc* = RECORD
      next*: Message;
      pool*: MessagePool
    END;

    RunHandler* = PROCEDURE;
    ReadyQueueDesc* = RECORD
      head*, tail*: Actor;
      handler*: RunHandler;
      intNo*, prio*, cid*, id*: INTEGER
    END;

    MessageQueueDesc* = RECORD
      head*, tail*: Message
    END;

    ActorQueueDesc* = RECORD
      head*, tail*: Actor
    END;

    EventQueueDesc* = RECORD
      msgQ*: MessageQueue;
      actQ*: ActorQueue
    END;

    MessagePoolDesc* = RECORD
      head*: Message;
      cnt*: INTEGER
    END;

END Types.
