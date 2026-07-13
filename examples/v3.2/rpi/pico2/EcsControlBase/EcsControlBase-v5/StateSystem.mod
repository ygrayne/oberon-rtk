MODULE StateSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v5
  --
  State reporting system
  Components:
  * locked: StatusSource, LedGpioBinding
  * producer: OutputPort
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    C := Components, Texts, TextIO, Messages, TextMessages, BUFstr, QueueingPort, SIOgpio;


  CONST
    ExtString = " print some more to extend the output (v5: sync/async drain, no FIFO)";


  PROCEDURE Run*;
    VAR
      i: INTEGER; leds, ledPins: SET; W: TextIO.Writer;
      textMsg: TextMessages.Message; msg: Messages.Message;
  BEGIN
    QueueingPort.Acquire(C.outputPort.port, msg);
    IF msg # NIL THEN
      textMsg := msg(TextMessages.Message);
      W := textMsg.writer;
      BUFstr.Reset(textMsg.device);
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
      QueueingPort.Emit(C.outputPort.port, msg)
    END
  END Run;

END StateSystem.
