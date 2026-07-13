MODULE DrainSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v0
  --
  UART drain system
  Components:
  * locked: UartBinding
  * consumer: TxData
  * producer: TxCursor
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, UARTdrain, BUFstr;


  PROCEDURE Run*;
    VAR remChar, accChar, res: INTEGER; txCursor: C.TxCursor;
  BEGIN
    txCursor := C.txCursor;
    IF C.txCursor.done THEN
      IF C.txData.seq # txCursor.seqDone THEN
        BUFstr.GetString(C.txData.device, txCursor.buf, txCursor.numChar, res);
        (* assert res as needed for error/disturbance handling *)
        txCursor.seqDone := C.txData.seq;
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
