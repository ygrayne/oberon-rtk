MODULE SPIrtc;
(**
  Oberon RTK Framework
  --
  Example program, multi-threaded, one core
  Description: https://oberon-rtk.org/examples/spirtc/
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Kernel, MultiCore, Out, Errors, GPIO, LED, SPId := SPIdev, SPIp := SPIper, RTC := RTCds3234, LEDext;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

    SPIsclkPinNo = 10;
    SPImosiPinNo = 11;
    SPImisoPinNo = 12;
    RTCcsPinNo = 13;

    SPIno = SPId.SPI1;

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
      RTC.GetTime(hours, mins, secs);
      RTC.GetDate(year, month, day);
      writeDateTime(year, month, day, hours, mins, secs);
      dt := RTC.Timestamp();
      Out.Int(dt, 12);
      RTC.Decode(dt, year, month, day, hours, mins, secs);
      writeDateTime(year, month, day, hours, mins, secs);
      Out.Ln;
      Kernel.Next
    UNTIL FALSE
  END t1c;


  PROCEDURE run;
    VAR res, sclkFreq, dataSize, cpol, cpha, txShift: INTEGER; spi: SPId.Device;
  BEGIN
    NEW(spi); ASSERT(spi # NIL, Errors.HeapOverflow);
    RTC.Install(spi, RTCcsPinNo, SPIp.CSsio);
    RTC.GetSPIparams(sclkFreq, dataSize, cpol, cpha, txShift);
    SPId.Init(spi, SPIno, txShift);
    SPId.Configure(spi, sclkFreq, dataSize, cpol, cpha, SPImosiPinNo, SPImisoPinNo, SPIsclkPinNo);
    SPId.Enable(spi);
    Kernel.Install(MillisecsPerTick);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t0, 500, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.OK, Errors.ProgError);
    Kernel.SetPeriod(t1, 1000, 0); Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END SPIrtc.

