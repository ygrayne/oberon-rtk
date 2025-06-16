MODULE LEDext;
(**
  Oberon RTK Framework v2.1
  --
  Eight additional LEDs, connected via GPIO pins.
  Include also the green one on the Pico for convenience.
  --
  MCU: RP2350B
  Board: Pico2-Ice
  Needs updating with pins used on that board.
  --
  Usage:
  * Via SIO:
    GPIO.Set({LEDext.LED0}),
    GPIO.Clear({LEDext.LED0}),
    GPIO.Toggle({LEDext.LED0})
  * Direct, avoiding procedure calls, eg. for leaf procedures:
    SYSTEM.PUT(LEDext.LSET, {LEDext.LED0}),
    SYSTEM.PUT(LEDext.LCLR, {LEDext.LED0}),
    SYSTEM.PUT(LEDext.LXOR, {LEDext.LED0})
  * A set of LEDs can be set on or off with one call.
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  IMPORT MCU := MCU2, GPIO;

  CONST
    (* LED on the board *)
    LEDpinNoPico = 25;
    (* wired LEDs *)
    LEDpinNo0 = 27;
    LEDpinNo1 = 28;
    LEDpinNo2 = 26;
    LEDpinNo3 = 22;
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

    LEDx* = {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7};

    LSET* = MCU.SIO_GPIO_OUT_SET;
    LCLR* = MCU.SIO_GPIO_OUT_CLR;
    LXOR* = MCU.SIO_GPIO_OUT_XOR;

    NumLeds = 8;

  VAR LED*: ARRAY 8 OF INTEGER;


  PROCEDURE SetLedBits*(v, highBit, lowBit: INTEGER);
    VAR i, numBits: INTEGER; setMask, clearMask: INTEGER;
  BEGIN
  (*
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
  *)
  END SetLedBits;


  PROCEDURE SetValue*(v: INTEGER);
  BEGIN
    SetLedBits(v, 7, 0)
  END SetValue;


  PROCEDURE init;
    VAR i: INTEGER;
  BEGIN
    LED[0] := LEDpinNo0;
    LED[1] := LEDpinNo1;
    LED[2] := LEDpinNo2;
    LED[3] := LEDpinNo3;
    LED[4] := LEDpinNo4;
    LED[5] := LEDpinNo5;
    LED[6] := LEDpinNo6;
    LED[7] := LEDpinNo7;
    (*
    GPIO.SetFunction(LEDpinNoPico, MCU.IO_BANK0_Fsio);
    GPIO.OutputEnable({LEDpinNoPico});
    i := 0;
    WHILE i < NumLeds DO
      GPIO.SetFunction(LED[i], MCU.IO_BANK0_Fsio);
      GPIO.OutputEnable(BITS(ORD({LED[i]})));
      INC(i)
    END
    *)
  END init;

BEGIN
  init
END LEDext.
