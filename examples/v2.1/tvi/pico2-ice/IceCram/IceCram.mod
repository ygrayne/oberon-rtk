MODULE IceCram;
(**
  Oberon RTK Framework v2.1
  --
  Example program: configure the iCE FPGA by loading a bitstram file
  directly into its configuration RAM (CRAM). This also starts iCE.
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Ice := ICE40UP5K, IceCfg := IceCfgCram, Out, BinRes, IceData, Timers;

  PROCEDURE run;
  (* configure iCE from binary resource data 'IceData' in this program *)
    VAR
      done: BOOLEAN; binRes: BinRes.BinDataRes;
      timer: Timers.Device; begin, end: INTEGER;
  BEGIN
    NEW(timer); Timers.Init(timer, Timers.TIMER0);
    Timers.GetTimeL(timer, begin);
    Ice.StartClock(Ice.IceClockDivInt);
    BinRes.GetBinDataRes("IceData", binRes);
    done := FALSE;
    IF binRes.resAddr = 0 THEN
      Out.String("resource data not found"); Out.Ln
    ELSE
      Out.String("write CRAM");
      Timers.GetTimeL(timer, begin);
      IceCfg.ConfigCram(binRes, done);
      Timers.GetTimeL(timer, end);
      IF done THEN
        Out.String(" - success")
      ELSE
        Out.String("- failed")
      END;
      Out.Ln;
      Out.String("iCE running"); Out.Ln;
      Out.String("config time (ms): "); Out.Int((end - begin) DIV 1000, 0); Out.Ln
    END
  END run;

BEGIN
  run
END IceCram.
