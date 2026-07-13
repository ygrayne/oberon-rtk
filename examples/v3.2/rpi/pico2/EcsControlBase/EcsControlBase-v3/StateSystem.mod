MODULE StateSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v3
  --
  State reporting system
  Components:
  * locked: StatusSource, LedGpioBinding
  * producer: TextMsgQueue
  * consumer: TextMsgPool
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, Texts, TextIO, Messages, TextMessages, BUFstr, RingBuffer, SIOgpio;

  CONST
    ExtString = " print some more to extend beyond FIFO depth (v3: msg ring)";


  PROCEDURE Run*;
    VAR
      i: INTEGER; leds, ledPins: SET; W: TextIO.Writer;
      textMsg: TextMessages.Message; msg: Messages.Message;
  BEGIN
    (* note: 2 drop conditions: 1) no textMsg available, 2) text output too long *)
    IF ~RingBuffer.Empty(C.textMsgPool.ring) THEN
      RingBuffer.Get(C.textMsgPool.ring, msg);
      textMsg := msg(TextMessages.Message);
      BUFstr.Reset(textMsg.device);
      W := textMsg.writer;
      Texts.WriteString(W, "LED 0..3 states: ");
      i := 0;
      leds := C.statusSource.leds;
      WHILE i < C.NumLed DO
        IF i IN leds THEN
          SIOgpio.Get(C.ledGpioBinding[i].ledPinPort, ledPins);
          IF C.ledGpioBinding[i].ledPin IN ledPins THEN
            Texts.WriteInt(W, 1, 2)
          ELSE
            Texts.WriteInt(W, 0, 2)
          END
        ELSE
          Texts.WriteString(W, " -")
        END;
        INC(i)
      END;
      Texts.WriteString(W, ExtString);
      Texts.WriteLn(W);
      RingBuffer.Put(C.textMsgQueue.ring, msg)
    END
  END Run;

END StateSystem.
