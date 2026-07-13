MODULE DrainSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v4
  --
  UART drain system
  Components:
  * locked: UartBinding
  * owned: TxCursor
  * consumer: OutputPort
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, UART, UARTdrain, Messages, TextMessages, QueueingPort, BUFstr;

  PROCEDURE Run*;
    VAR
      numChar: INTEGER; last: BOOLEAN;
      txCursor: C.TxCursor; uartDev: UART.Device; bufDev: BUFstr.Device;
      msg: Messages.Message; ch: CHAR;
  BEGIN
    txCursor := C.txCursor;
    IF txCursor.msg = NIL THEN
      QueueingPort.Receive(C.outputPort.port, msg);
      IF msg # NIL THEN
        txCursor.msg := msg(TextMessages.Message);
        BUFstr.InitGetChar(txCursor.msg.device, numChar);
        IF numChar = 0 THEN
          QueueingPort.Return(C.outputPort.port, txCursor.msg);
          txCursor.msg := NIL
        END
      END
    END;
    IF txCursor.msg # NIL THEN
      uartDev := C.uartBinding.device;
      bufDev := txCursor.msg.device;
      last := FALSE;
      WHILE ~(last OR UARTdrain.Full(uartDev)) DO
        BUFstr.GetNextChar(bufDev, ch, last);
        UARTdrain.Put(uartDev, ch)
      END;
      IF last THEN
        QueueingPort.Return(C.outputPort.port, txCursor.msg);
        txCursor.msg := NIL
      END
    END
  END Run;

END DrainSystem.

