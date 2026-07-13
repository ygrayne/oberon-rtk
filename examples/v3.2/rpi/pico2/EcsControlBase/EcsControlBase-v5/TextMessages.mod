MODULE TextMessages;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v5
  --
  The concrete message type: a pool/queue element (extending
  'Messages.Message') that carries formattable text. It composes
  rather than inherits -- a message *has* a 'BUFstr.Device' and a
  'TextIO.Writer', it is not one -- so a single object serves as both
  a ring element and a formatting target, which single inheritance
  could not express. 'MakeMsg' constructs one, allocating its buffer
  device and writer; the pool is filled with these at build time.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Messages, BUFstr, TextIO, Errors;

  TYPE
    Message* = POINTER TO MessageDesc;
    MessageDesc* = RECORD(Messages.MessageDesc)
      device*: BUFstr.Device;
      writer*: TextIO.Writer
    END;


  PROCEDURE MakeMsg*(): Messages.Message;
    VAR msg: Message;
  BEGIN
    NEW(msg); ASSERT(msg # NIL, Errors.HeapOverflow);
    NEW(msg.device); ASSERT(msg.device # NIL, Errors.HeapOverflow);
    NEW(msg.writer); ASSERT(msg.writer # NIL, Errors.HeapOverflow);
    TextIO.OpenWriter(msg.writer, msg.device, BUFstr.PutString)
    RETURN msg
  END MakeMsg;

END TextMessages.
