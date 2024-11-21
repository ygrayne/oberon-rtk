MODULE SPIrtc;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, one core
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, MultiCore, Out, Errors, GPIO, SPIdev, SPIper, RTC := RTCds3234, LEDext;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;
    NumCfg = 4;

    SPIsclkPinNo = 10;
    SPImosiPinNo = 11;
    SPImisoPinNo = 12;
    RTCcsPinNo = 13;

    SPIno = SPIdev.SPI1;

  TYPE
    Cfgs = ARRAY NumCfg OF SPIdev.DeviceCfg;
    RunCfgs = ARRAY NumCfg OF SPIdev.DeviceRunCfg;
    TxShifts = ARRAY NumCfg OF INTEGER;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;
    runCfgs: RunCfgs;
    cfgs: Cfgs;
    txShifts: TxShifts;
    spi: SPIdev.Device;


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
    VAR tid, cid, cfgNo, year, month, day, hours, mins, secs, dt: INTEGER;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cfgNo := 0;
    REPEAT
      writeThreadInfo(tid, cid);
      SPIdev.PutRunCfg(spi, runCfgs[cfgNo]);
      (* read time, date, and timestamp *)
      RTC.GetTime(hours, mins, secs);
      RTC.GetDate(year, month, day);
      dt := RTC.Timestamp();
      (* write date and time, timestamp, and decoded timestamp *)
      writeDateTime(year, month, day, hours, mins, secs);
      Out.Int(dt, 12);
      RTC.Decode(dt, year, month, day, hours, mins, secs);
      writeDateTime(year, month, day, hours, mins, secs);
      (* write SPI parameters *)
      Out.Int(SPIdev.SclkRate(spi), 10);
      Out.Int(cfgs[cfgNo].cpol, 3);
      Out.Hex(txShifts[cfgNo], 11);
      Out.Ln;
      cfgNo := (cfgNo + 1) MOD NumCfg;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE configMisoPad(misoPinNo: INTEGER);
    VAR cfg: GPIO.PadCfg;
  BEGIN
    GPIO.GetPadBaseCfg(cfg);
    cfg.pullupEn := GPIO.Enabled;     (* pull-up on *)
    cfg.pulldownEn := GPIO.Disabled;  (* pull-down off *)
    GPIO.ConfigurePad(misoPinNo, cfg)
  END configMisoPad;


  PROCEDURE createCfgVariants(cfg: SPIdev.DeviceCfg; txShift: INTEGER; VAR cfgRuns: RunCfgs);
    VAR i: INTEGER;
  BEGIN
    (* copy base cfg and txShift *)
    i := 0;
    WHILE i < NumCfg DO
      cfgs[i] := cfg;
      txShifts[i] := txShift;
      INC(i)
    END;
    (* make some changes *)
    cfgs[1].scr := SPIdev.SCRvalue(spi, 1000000);
    cfgs[2].cpol := 1;
    txShifts[3] := 0AAH;
    (* make run cfgs *)
    i := 0;
    WHILE i < NumCfg DO
      SPIdev.MakeRunCfg(cfgs[i], txShifts[i], cfgRuns[i]); INC(i)
    END
  END createCfgVariants;


  PROCEDURE run;
    VAR res, sclkRate, txShift, low, high: INTEGER; cfg: SPIdev.DeviceCfg;
  BEGIN
    NEW(spi); ASSERT(spi # NIL, Errors.HeapOverflow);
    RTC.Install(spi, RTCcsPinNo, SPIper.CSsio);
    RTC.GetSPIparams(sclkRate, cfg.dataSize, cfg.cpol, cfg.cpha, txShift);

    SPIdev.Init(spi, SPIno);
    SPIdev.Configure(spi, sclkRate, SPImosiPinNo, SPImisoPinNo, SPIsclkPinNo, cfg.scr);
    createCfgVariants(cfg, txShift, runCfgs);
    configMisoPad(SPImisoPinNo);

    SPIdev.GetSclkRateRange(spi, low, high);
    Out.String("lowRate:"); Out.Int(low, 10);
    Out.String(" highRate:"); Out.Int(high, 10);
    Out.String(" SCR:"); Out.Int(cfg.scr, 10);
    Out.Ln;

    SPIdev.Enable(spi);
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
END SPIrtc.
