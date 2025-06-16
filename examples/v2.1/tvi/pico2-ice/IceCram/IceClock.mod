MODULE IceClock;
(**
  Oberon RTK Framework v2.1
  --
  Test clock output to ICE.
  --
  MCU: RRP2350B
  Board: Pico2-ICE
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, MCU := MCU2, ClockOut, GPIO, Out;

  CONST
    ClkPin = 21;
    Cout = ClockOut.COUT0;

  PROCEDURE run;
  BEGIN
    Out.String("begin"); Out.Ln;
    ClockOut.Start(Cout, MCU.CLK_GPOUT_ClkPeri, 2, 0);
    GPIO.SetFunction(ClkPin, MCU.IO_BANK0_Fclk)
  END run;

BEGIN
  run
END IceClock.
