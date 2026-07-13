MODULE DrainSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v7
  --
  UART drain system
  Components:
  * locked: UartBinding
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
      uartDev: UART.Device; bufDev: BUFstr.Device;
      textMsg: TextMessages.Message; msg: Messages.Message; ch: CHAR;
  BEGIN
    IF UARTdrain.Empty(C.uartBinding.device) THEN
      QueueingPort.Receive(C.outputPort.port, msg);
      IF msg # NIL THEN
        textMsg := msg(TextMessages.Message);
        uartDev := C.uartBinding.device;
        bufDev := textMsg.device;
        BUFstr.InitGetChar(bufDev, numChar);
        IF numChar > 0 THEN
          last := FALSE;
          WHILE ~last DO (* FIFO is empty => all msg text fits *)
            BUFstr.GetNextChar(bufDev, ch, last);
            UARTdrain.Put(uartDev, ch)
          END;
        END;
        QueueingPort.Return(C.outputPort.port, textMsg)
      END
    END
  END Run;

END DrainSystem.

