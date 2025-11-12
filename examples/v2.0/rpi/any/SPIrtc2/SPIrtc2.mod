MODULE SPIrtc2;
(**
  Oberon RTK Framework v2
  --
  Example program, multi-threaded, one core
  Description: https://oberon-rtk.org/docs/examples/v2/spirtc2/
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, MCU := MCU2, Kernel, MultiCore, Out, Errors, SPIdev, GPIO, LEDext, RTC := RTCds3234test;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    SPIsclkPinNo = 10;
    SPImosiPinNo = 11;
    SPImisoPinNo = 12;
    RTCcsPinNo = 13;

    SPIno = SPIdev.SPI1;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;


  PROCEDURE writeThreadInfo(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0);
  END writeThreadInfo;

  PROCEDURE writeDateTime(year, month, day, hours, mins, secs: INTEGER);
  BEGIN
    Out.Int(year, 5); Out.Int(month, 3); Out.Int(day, 3);
    Out.Int(hours, 5); Out.Int(mins, 3); Out.Int(secs, 3)
  END writeDateTime;


  PROCEDURE t0c;
    VAR ledNo: INTEGER;
  BEGIN
    GPIO.Set({LEDext.LEDpico});
    ledNo := 0;
    REPEAT
      LEDext.SetValue(ledNo);
      INC(ledNo);
      GPIO.Toggle({LEDext.LEDpico});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    VAR tid, cid, year, month, day, hours, mins, secs, dt: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    REPEAT
      writeThreadInfo(tid, cid);
      (* read time, date, and timestamp *)
      RTC.GetTime(hours, mins, secs);
      RTC.GetDate(year, month, day);
      dt := RTC.Timestamp();
      (* write date and time, timestamp, and decoded timestamp *)
      writeDateTime(year, month, day, hours, mins, secs);
      Out.Int(dt, 12);
      RTC.Decode(dt, year, month, day, hours, mins, secs);
      writeDateTime(year, month, day, hours, mins, secs);
      Out.Ln;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE configPins;
    VAR mask: SET; padCfg: GPIO.PadCfg;
  BEGIN
    (* config miso pad *)
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Enabled;
    padCfg.inputEn := GPIO.Enabled;
    GPIO.ConfigurePad(SPImisoPinNo, padCfg);

    (* config chip select *)
    mask := {RTCcsPinNo};
    GPIO.OutputEnable(mask);
    GPIO.SetFunction(RTCcsPinNo, MCU.IO_BANK0_Fsio);
    GPIO.Set(mask); (* active low *)

    (* config SPI GPIO devices *)
    GPIO.SetFunction(SPImosiPinNo, MCU.IO_BANK0_Fspi);
    GPIO.SetFunction(SPImisoPinNo, MCU.IO_BANK0_Fspi);
    GPIO.SetFunction(SPIsclkPinNo, MCU.IO_BANK0_Fspi)
  END configPins;


  PROCEDURE run;
    VAR
      res: INTEGER;
      spi: SPIdev.Device;
      cfg: SPIdev.DeviceCfg;
  BEGIN
    NEW(spi); ASSERT(spi # NIL, Errors.HeapOverflow);

    (* SPI device cfg *)
    SPIdev.GetBaseCfg(cfg);
    cfg.cpha := RTC.CPHA;
    cfg.txShift := RTC.TxShift;

    (* init SPI device *)
    SPIdev.Init(spi, SPIno);
    SPIdev.Configure(spi, cfg, RTC.SclkRate);
    SPIdev.Enable(spi);

    (* configure the pins and pads *)
    configPins;

    (* pass required parameters to RTC *)
    RTC.Install(spi, RTCcsPinNo);

    (*
    RTC.SetClock(24, 11, 10, 3, 48, 0);
    *)

    (* threads *)
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t0, 100, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END SPIrtc2.
