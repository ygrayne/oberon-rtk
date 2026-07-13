MODULE DrainSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v3
  --
  UART drain system
  Components:
  * locked: UartBinding
  * owned: TxCursor
  * consumer: TextMsgQueue
  * producer: TextMsgPool
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, UARTdrain, Messages, TextMessages, RingBuffer, BUFstr;

  PROCEDURE Run*;
    VAR
      remChar, accChar, res: INTEGER;
      txCursor: C.TxCursor;
      textMsg: TextMessages.Message; msg: Messages.Message;
  BEGIN
    txCursor := C.txCursor;
    IF txCursor.done THEN
      IF ~RingBuffer.Empty(C.textMsgQueue.ring) THEN
        RingBuffer.Get(C.textMsgQueue.ring, msg);
        textMsg := msg(TextMessages.Message);
        BUFstr.GetString(textMsg.device, txCursor.buf, txCursor.numChar, res);
        (* assert res as needed for error/disturbance handling *)
        RingBuffer.Put(C.textMsgPool.ring, textMsg);
        txCursor.pos := 0;
        txCursor.done := FALSE
      END
    END;
    IF ~txCursor.done THEN
      remChar := txCursor.numChar - txCursor.pos;
      UARTdrain.PutBytes(C.uartBinding.device, txCursor.buf, txCursor.pos, remChar, accChar);
      INC(txCursor.pos, accChar);
      txCursor.done := txCursor.pos >= txCursor.numChar
    END
  END Run;

END DrainSystem.

