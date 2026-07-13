MODULE StateSystem;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v2
  --
  State reporting system
  Components:
  * locked: TxBufWriter, StatusSource, LedGpioBinding
  * producer: TxData (indirectly via TextIO.Writer)
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT C := Components, Texts, TextIO, SIOgpio;

  CONST
    ExtString = " print some more to extend beyond FIFO depth (v2: char ring)";


  PROCEDURE Run*;
    VAR W: TextIO.Writer; i: INTEGER; leds, ledPins: SET;
  BEGIN
    W := C.txBufWriter.writer;
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
    Texts.WriteLn(W)
  END Run;

END StateSystem.
