MODULE DrainSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v5
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

  IMPORT SYSTEM, C := Components, UART, UARTdrain, Messages, TextMessages, QueueingPort, BUFstr, ASM;


  PROCEDURE TxHandler*[0];
    VAR ch: CHAR; last: BOOLEAN;
  BEGIN
    IF UARTdrain.IsTxInt(C.uartBinding.device) THEN
      BUFstr.GetNextChar(C.txCursor.msg.device, ch, last);
      UARTdrain.Put(C.uartBinding.device, ch); (* clears int *)
      IF last THEN
        UARTdrain.DisableTxInt(C.uartBinding.device);
        SYSTEM.EMIT(ASM.DSB);
        QueueingPort.Return(C.outputPort.port, C.txCursor.msg)
      END
    END
  END TxHandler;


  PROCEDURE Run*;
    VAR
      numChar: INTEGER; last: BOOLEAN; ch: CHAR;
      txCursor: C.TxCursor; uartDev: UART.Device; bufDev: BUFstr.Device;
      port: QueueingPort.Port; msg: Messages.Message;
  BEGIN
    txCursor := C.txCursor;
    uartDev := C.uartBinding.device;
    port := C.outputPort.port;
    IF ~UARTdrain.TxIntEnabled(uartDev) THEN
      QueueingPort.Receive(port, msg);
      IF msg # NIL THEN
        txCursor.msg := msg(TextMessages.Message);
        bufDev := txCursor.msg.device;
        BUFstr.InitGetChar(bufDev, numChar);
        IF numChar = 0 THEN
          QueueingPort.Return(port, txCursor.msg)
        ELSE
          BUFstr.GetNextChar(bufDev, ch, last);
          UARTdrain.Put(uartDev, ch);
          IF last THEN
            QueueingPort.Return(port, txCursor.msg)
          ELSE
            UARTdrain.EnableTxInt(uartDev)
          END
        END
      END
    END
  END Run;

END DrainSystem.

