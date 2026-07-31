MODULE LEDbinding;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SIO := SIOgpio, GPIO;


  CONST
    (* wired LEDs *)
    LEDpinNo0 = 27;
    LEDpinNo1 = 28;
    LEDpinNo2 = 26;
    LEDpinNo3 = 22;
    LEDpinNo4 = 8;
    LEDpinNo5 = 9;
    LEDpinNo6 = 14;
    LEDpinNo7 = 15;

    LED0* = LEDpinNo0;
    LED1* = LEDpinNo1;
    LED2* = LEDpinNo2;
    LED3* = LEDpinNo3;
    LED4* = LEDpinNo4;
    LED5* = LEDpinNo5;
    LED6* = LEDpinNo6;
    LED7* = LEDpinNo7;

    NumLeds* = 8;


  PROCEDURE Put*(led, val: INTEGER);
  BEGIN
    val := ORD(BITS(val) * {0});
    IF val = 1 THEN
      SIO.Set(SIO.GPIOA, {led})
    ELSE
      SIO.Clear(SIO.GPIOA, {led})
    END
  END Put;


  PROCEDURE Get*(led: INTEGER; VAR val: INTEGER);
    VAR val0: SET;
  BEGIN
    SIO.Get(SIO.GPIOA, val0);
    val := 0;
    IF led IN val0 THEN
      val := 1
    END
  END Get;


  PROCEDURE Config*;
    VAR i: INTEGER; LED: ARRAY NumLeds OF INTEGER;
  BEGIN
    LED[0] := LEDpinNo0;
    LED[1] := LEDpinNo1;
    LED[2] := LEDpinNo2;
    LED[3] := LEDpinNo3;
    LED[4] := LEDpinNo4;
    LED[5] := LEDpinNo5;
    LED[6] := LEDpinNo6;
    LED[7] := LEDpinNo7;
    GPIO.Attach;
    i := 0;
    WHILE i < NumLeds DO
      GPIO.SetFunction(LED[i], GPIO.Fsio);
      SIO.EnableOutput(SIO.GPIOA, BITS(ORD({LED[i]})));
      SIO.Clear(SIO.GPIOA, BITS(ORD({LED[i]})));
      GPIO.ConnectInput(LED[i]);
      INC(i)
    END
  END Config;

END LEDbinding.
