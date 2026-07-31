MODULE QueueingPort;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v7
  --
  A queueing port: a message queue and its backing pool of free
  messages, behind an Acquire/Emit (producer) and Receive/Return
  (consumer) interface. The crossing's machinery lives here, below the
  store; only a reference to the port is a Component.

  The producer 'Acquire's a free message from the pool, fills it, and
  'Emit's it to the queue; the consumer 'Receive's it, uses it, and
  'Return's it to the pool. Ownership travels with the message -- at
  most one side holds a reference at a time, so nothing is copied and
  no lock is needed. 'Acquire' and 'Receive' yield NIL when their ring
  is empty; the caller guards. Queue and pool are both SPSC rings;
  'Init' creates them and fills the pool via the supplied constructor.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Messages, RingBuffer, Errors;


  TYPE
    Port* = POINTER TO PortDesc;
    PortDesc* = RECORD
      queue: RingBuffer.Buffer;
      pool: RingBuffer.Buffer
    END;

    MakeMsgProc* = PROCEDURE(): Messages.Message;


  PROCEDURE Acquire*(p: Port; VAR msg: Messages.Message);
  (* acquire a message from the pool => acquirer owns message *)
  (* sets msg = NIL if pool is empty *)
  BEGIN
    msg := NIL;
    IF ~RingBuffer.Empty(p.pool) THEN
      RingBuffer.Get(p.pool, msg)
    END
  END Acquire;


  PROCEDURE Return*(p: Port; msg: Messages.Message);
  (* return a message to the pool => pool owns message *)
  (* caller must ensure not to use this message after the call *)
  BEGIN
    ASSERT(msg # NIL, Errors.ProgError);
    RingBuffer.Put(p.pool, msg)
  END Return;


  PROCEDURE Receive*(p: Port; VAR msg: Messages.Message);
  (* receive a message from queue => receiver owns message *)
  (* set msg = NIL if queue is empty *)
  BEGIN
    msg := NIL;
    IF ~RingBuffer.Empty(p.queue) THEN
      RingBuffer.Get(p.queue, msg)
    END
  END Receive;


  PROCEDURE Emit*(p: Port; msg: Messages.Message);
  (* put a message on queue => queue owns message *)
  (* caller must ensure not to use this message after the call *)
  BEGIN
    ASSERT(msg # NIL, Errors.ProgError);
    RingBuffer.Put(p.queue, msg)
  END Emit;


  PROCEDURE Init*(p: Port; make: MakeMsgProc);
  (* create rings, fill pool *)
  BEGIN
    NEW(p.queue); ASSERT(p.queue # NIL, Errors.HeapOverflow);
    NEW(p.pool); ASSERT(p.pool # NIL, Errors.HeapOverflow);
    RingBuffer.Init(p.queue);
    RingBuffer.Init(p.pool);
    WHILE ~RingBuffer.Full(p.pool) DO
      RingBuffer.Put(p.pool,  make())
    END
  END Init;

END QueueingPort.
