MODULE StateSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v0
  --
  State reporting system
  Components:
  * locked: TxBufWriter, LedGpioBinding
  * producer: TxData (indirectly via TextIO.Writer)
  * consumer: TxCursor
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, Console, Texts, TextIO, BUFstr, SIOgpio;

  CONST
    ExtString = " print some more to extend beyond FIFO depth (v0: one LED)";


  PROCEDURE Run*;
    VAR W: TextIO.Writer; txData: C.TxData; ledPins: SET;
  BEGIN
    (* debug console output *)
    Texts.WriteString(Console.Wsys[0], "StateSystem"); Texts.WriteLn(Console.Wsys[0]);
    (* buffer output *)
    IF C.txCursor.done THEN
      W := C.txBufWriter.writer;
      txData := C.txData;
      INC(txData.seq);
      BUFstr.Reset(txData.device);
      Texts.WriteString(W, "LED state: ");
      SIOgpio.Get(C.ledGpioBinding.ledPinPort, ledPins);
      IF C.ledGpioBinding.ledPin IN ledPins THEN
        Texts.WriteInt(W, 1, 2)
      ELSE
        Texts.WriteInt(W, 0, 2)
      END;
      Texts.WriteString(W, ExtString);
      Texts.WriteLn(W)
    END
  END Run;


END StateSystem.
