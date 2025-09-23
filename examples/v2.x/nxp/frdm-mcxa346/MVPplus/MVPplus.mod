MODULE MVPplus;
(**
  Oberon RTK Framework v2.x
  --
  Extended Minimal Viable Program
  --
  MCU: MCX-A346
  Board: FRDM-MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    MCU := MCU2, Main, ClockCtrl, StartUp, GPIO, TextIO, Texts;

  CONST
    (* LED *)
    LEDpin = 19;

    (* clock out *)
    ClkOutPin = (MCU.PORT4 * 32) + 2; (* p4_2 *)

  VAR
    W: TextIO.Writer;


  PROCEDURE init;
  BEGIN
    W := Main.W;

    (* LED *)
    StartUp.ReleaseReset(MCU.DEV_PORT3);
    StartUp.ReleaseReset(MCU.DEV_GPIO3);
    ClockCtrl.EnableClock(MCU.DEV_PORT3);
    ClockCtrl.EnableClock(MCU.DEV_GPIO3);
    GPIO.EnableOutput(MCU.PORT3, {LEDpin});

    (* clk out *)
    StartUp.ReleaseReset(MCU.DEV_PORT4);
    ClockCtrl.ConfigClock(MCU.CLK_CLKOUT, 1, 0);
    ClockCtrl.EnableClock(MCU.DEV_PORT4);
    GPIO.SetFunction(ClkOutPin, GPIO.Fclkout0)
  END init;


  PROCEDURE run;
    VAR i, cnt: INTEGER;
  BEGIN
    cnt := 0;
    REPEAT
      GPIO.Toggle(MCU.PORT3, {LEDpin});
      Texts.WriteString(W, "123456789012345678901234567890");
      Texts.WriteInt(W, cnt, 10); Texts.WriteLn(W);
      INC(cnt);
      i := 0;
      WHILE i < 10000000 DO INC(i) END (* busy loop shows effect of flash cache *)
    UNTIL FALSE
  END run;

BEGIN
  init;
  run
END MVPplus.
