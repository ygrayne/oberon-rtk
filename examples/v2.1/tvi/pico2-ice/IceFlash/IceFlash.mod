MODULE IceFlash;
(**
  Oberon RTK Framework v2.1
  --
  Example program: program the iCE flash configuration memory, then start iCE.
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Main, Ice := ICE40UP5K, IceCfg := IceCfgFlash, Out, BinRes, IceData, Timers;

  PROCEDURE run;
  (* configure iCE from binary resource data 'IceData' in this program *)
    VAR
      done: BOOLEAN;
      binRes: BinRes.BinDataRes;
      timer: Timers.Device; begin, end: INTEGER;
  BEGIN
    NEW(timer); Timers.Init(timer, Timers.TIMER0);
    BinRes.GetBinDataRes("IceData", binRes);
    IF binRes.resAddr = 0 THEN
      Out.String("resource data not found"); Out.Ln
    ELSE
      Out.String("write flash memory"); Out.Ln;
      Timers.GetTimeL(timer, begin);
      IceCfg.ConfigFlash(binRes, done);
      Timers.GetTimeL(timer, end);
      Out.String("start iCE"); Out.Ln;
      Ice.StartClock(Ice.IceClockDivInt);
      Ice.StartFpga;
      Out.String("config time (ms): "); Out.Int((end - begin) DIV 1000, 0); Out.Ln
    END
  END run;

BEGIN
  run
END IceFlash.
