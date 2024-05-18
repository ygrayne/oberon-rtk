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
    GPIO.Clear({LEDext.LED0},
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

    ClearMask = {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7};

  VAR LED*: ARRAY 8 OF INTEGER;


  PROCEDURE SetValue*(v: INTEGER);
    VAR i: INTEGER; mask: INTEGER;
  BEGIN
    mask := 0;
    FOR i := 0 TO 7 DO
      IF i IN BITS(v) THEN
        INCL(BITS(mask), LED[i])
      END
    END;
    GPIO.Clear(ClearMask);
    GPIO.Set(BITS(mask))
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
    WHILE i < 8 DO
      GPIO.SetFunction(LED[i], GPIO.Fsio);
      en := ORD({LED[i]}); (* workaround v9.1 and 9.2 *)
      GPIO.OutputEnable(BITS(en));
      INC(i)
    END
  END init;

BEGIN
  init
END LEDext.
