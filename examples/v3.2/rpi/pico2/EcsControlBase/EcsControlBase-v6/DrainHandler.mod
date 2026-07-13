MODULE DrainHandler;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v6
  --
  UART drain, interrupt-driven
  Components:
  * locked: UartBinding
  * consumer: TxData
  --
  * The TX interrupt (with FIFO off) fires after a char has been sent, hence the first
  handler invocation is triggered by setting the interrupt pending at the NVIC.
  * Consequently, we cannot check for the type of interrupt (via dev.MIS), since via NVIC
  that type flag is not set.
  * We check 1) the availability of data in the ring, and 2) if the TX transmit register
  is empty. The second check would allow other UART interrupt types to be handled.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, ASM, C := Components, UARTdrain, RingBuffer, TextIO;


  PROCEDURE TxHandler*[0];
    VAR ch: CHAR;
  BEGIN
    IF ~RingBuffer.Empty(C.txData.ring) THEN
      IF ~UARTdrain.Full(C.uartBinding.device) THEN
        RingBuffer.Get(C.txData.ring, ch);
        UARTdrain.Put(C.uartBinding.device, ch)
      END
    ELSE
      UARTdrain.ClearTxInt(C.uartBinding.device);
      SYSTEM.EMIT(ASM.DSB)
    END
  END TxHandler;


  PROCEDURE Flush*(dev: TextIO.Device);
  BEGIN
    UARTdrain.Kick(C.uartBinding.device)
  END Flush;


END DrainHandler.

