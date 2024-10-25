MODULE LEDext;
(**
  Oberon RTK Framework
  --
  Eight additional LEDs, connected via GPIO pins.
  Include also the green one on the Pico for convenience.
  --
  MCU: RP2040
  Board: Pico
  --
  Usage:
  * Via SIO:
    GPIO.Set({LEDext.LED0}),
    GPIO.Clear({LEDext.LED0}),
    GPIO.Toggle({LEDext.LED0})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LEDext.SET, {LEDext.LED0}),
    SYSTEM.PUT(LEDext.CLR, {LEDext.LED0}),
    SYSTEM.PUT(LEDext.XOR, {LEDext.LED0})
  * A set of LEDs can be set on or off with one call.
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  IMPORT GPIO, MCU := MCU2;

  CONST
    LEDpinNoPico = 25;
    LEDpinNo0 = 2;
    LEDpinNo1 = 3;
    LEDpinNo2 = 6;
    LEDpinNo3 = 7;
    LEDpinNo4 = 8;
    LEDpinNo5 = 9;
    LEDpinNo6 = 14;
    LEDpinNo7 = 15;

    LEDpico* = LEDpinNoPico;
    LED0* = LEDpinNo0;
    LED1* = LEDpinNo1;
    LED2* = LEDpinNo2;
    LED3* = LEDpinNo3;
    LED4* = LEDpinNo4;
    LED5* = LEDpinNo5;
    LED6* = LEDpinNo6;
    LED7* = LEDpinNo7;

    SET* = MCU.SIO_GPIO_OUT_SET;
    CLR* = MCU.SIO_GPIO_OUT_CLR;
    XOR* = MCU.SIO_GPIO_OUT_XOR;

    NumLeds = 8;

  VAR LED*: ARRAY 8 OF INTEGER;


  PROCEDURE SetLedBits*(v, highBit, lowBit: INTEGER);
    VAR i, numBits: INTEGER; setMask, clearMask: INTEGER;
  BEGIN
    setMask := 0; clearMask := 0;
    i := 0; numBits := highBit - lowBit;
    WHILE i <= numBits DO
      IF i IN BITS(v) THEN
        INCL(BITS(setMask), LED[i + lowBit])
      ELSE
        INCL(BITS(clearMask), LED[i + lowBit])
      END;
      INC(i)
    END;
    GPIO.Clear(BITS(clearMask));
    GPIO.Set(BITS(setMask))
  END SetLedBits;


  PROCEDURE SetValue*(v: INTEGER);
  BEGIN
    SetLedBits(v, 7, 0)
  END SetValue;


  PROCEDURE init;
    VAR i: INTEGER; en: INTEGER;
  BEGIN
    LED[0] := LEDpinNo0;
    LED[1] := LEDpinNo1;
    LED[2] := LEDpinNo2;
    LED[3] := LEDpinNo3;
    LED[4] := LEDpinNo4;
    LED[5] := LEDpinNo5;
    LED[6] := LEDpinNo6;
    LED[7] := LEDpinNo7;
    GPIO.SetFunction(LEDpinNoPico, GPIO.Fsio);
    GPIO.OutputEnable({LEDpinNoPico});
    i := 0;
    WHILE i < NumLeds DO
      GPIO.SetFunction(LED[i], GPIO.Fsio);
      GPIO.OutputEnable(BITS(ORD({LED[i]})));
      INC(i)
    END
  END init;

BEGIN
  init
END LEDext.
