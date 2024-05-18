MODULE RTCds3234;
(**
  Oberon RTK Framework
  --
  SPI driver for Maxim DS3234 real-time clock
  For example program SPIrtc: https://oberon-rtk.org/examples/spirtc/
  --
  Not thread-safe to use from different cores.
  Day of the week is not used.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SPIp := SPIper, SPId := SPIdev, SPI := SPIdata, Errors;


  CONST
    (* peripheral register addresses *)
    TimeRegsAddr = 00H;
    DateRegsAddr = 04H;
    (* SPI device config parameters *)
    CPOL = 0;
    CPHA = 1;
    SclkFreq = 2000000;
    DataSize = SPId.DataSize8;
    TxShift = 0F0H;


  VAR
    rtc: SPIp.Peripheral;
    spi: SPId.Device;


  PROCEDURE decodeBCD(bcd: BYTE): BYTE;
  (* the compiler uses efficient shifts here *)
  BEGIN
    RETURN (bcd DIV 16) * 10 + (bcd MOD 16)
  END decodeBCD;


  PROCEDURE encodeBCD(b: BYTE): BYTE;
  (* less efficient, but also less used (SetClock) *)
  BEGIN
    RETURN (b DIV 10) * 16 + (b MOD 10)
  END encodeBCD;


  PROCEDURE ReadRegisters*(addr: BYTE; VAR regValues: ARRAY OF BYTE; n: INTEGER);
  BEGIN
    SPIp.Select(rtc);
    SPI.PutByte(spi, addr);
    SPI.GetBytes(spi, regValues, n);
    SPIp.Deselect(rtc)
  END ReadRegisters;


  PROCEDURE WriteRegisters*(addr: BYTE; regValues: ARRAY OF BYTE; n: INTEGER);
    CONST WriteEnable = 80H;
  BEGIN
    SPIp.Select(rtc);
    SPI.PutByte(spi, addr + WriteEnable);
    SPI.PutBytes(spi, regValues, n);
    SPIp.Deselect(rtc)
  END WriteRegisters;


  PROCEDURE GetTime*(VAR hours, mins, secs: INTEGER);
    CONST NumTimeRegs = 3;
    VAR regValues: ARRAY NumTimeRegs OF BYTE;
  BEGIN
    ReadRegisters(TimeRegsAddr, regValues, NumTimeRegs);
    secs := decodeBCD(regValues[0]);
    mins := decodeBCD(regValues[1]);
    hours := decodeBCD(regValues[2])
  END GetTime;


  PROCEDURE GetDate*(VAR year, month, day: INTEGER);
    CONST NumDateRegs = 3;
    VAR regValues: ARRAY NumDateRegs OF BYTE;
  BEGIN
    ReadRegisters(DateRegsAddr, regValues, NumDateRegs);
    day := decodeBCD(regValues[0]);
    month := decodeBCD(regValues[1]);
    year  := decodeBCD(regValues[2])
  END GetDate;


  PROCEDURE Decode*(dt: INTEGER; VAR year, month, day, hours, mins, secs: INTEGER);
  BEGIN
    secs := BFX(dt, 5, 0);
    mins := BFX(dt, 11, 6);
    hours := BFX(dt, 16, 12);
    day := BFX(dt, 21, 17);
    month := BFX(dt, 25, 22);
    year := BFX(dt, 31, 26)
  END Decode;


  PROCEDURE Encode*(year, month, day, hours, mins, secs: INTEGER; VAR dt: INTEGER);
  BEGIN
    dt := secs;
    BFI(dt, 11,  6, mins);
    BFI(dt, 16, 12, hours);
    BFI(dt, 21, 17, day);
    BFI(dt, 25, 22, month);
    BFI(dt, 31, 26, year)
  END Encode;


  PROCEDURE SetClock*(year, month, day, hours, mins, secs: INTEGER);
    CONST NumRegs = 7;
    VAR regValues: ARRAY NumRegs OF BYTE;
  BEGIN
    regValues[0] := encodeBCD(secs);
    regValues[1] := encodeBCD(mins);
    regValues[2] := encodeBCD(hours);
    regValues[3] := 1; (* day of the week unused *)
    regValues[4] := encodeBCD(day);
    regValues[5] := encodeBCD(month);
    regValues[6] := encodeBCD(year);
    WriteRegisters(TimeRegsAddr, regValues, NumRegs)
  END SetClock;


  PROCEDURE Timestamp*(): INTEGER;
    CONST NumRegs = 7;
    VAR
      year, month, day, hours, mins, secs, dt: INTEGER;
      regValues: ARRAY NumRegs OF BYTE;
  BEGIN
    ReadRegisters(TimeRegsAddr, regValues, NumRegs);
    secs := decodeBCD(regValues[0]);
    mins := decodeBCD(regValues[1]);
    hours := decodeBCD(regValues[2]);
    (* omit [3]: day of the week *)
    day := decodeBCD(regValues[4]);
    month := decodeBCD(regValues[5]);
    year := decodeBCD(regValues[6]);
    Encode(year, month, day, hours, mins, secs, dt)
    RETURN dt
  END Timestamp;


  PROCEDURE GetSPIparams*(VAR sclkFreq, dataSize, cpol, cpha, txShift: INTEGER);
  BEGIN
    SPIp.GetSPIparams(rtc, sclkFreq, dataSize, cpol, cpha, txShift)
  END GetSPIparams;


  PROCEDURE Install*(spiDev: SPId.Device; csPinNo: INTEGER; csMode: INTEGER);
  BEGIN
    ASSERT(spiDev # NIL, Errors.PreCond);
    NEW(rtc); ASSERT(rtc # NIL, Errors.HeapOverflow);
    SPIp.Init(rtc, SclkFreq, DataSize, CPOL, CPHA, csPinNo, TxShift, csMode);
    SPIp.Configure(rtc);
    spi := spiDev
  END Install;

END RTCds3234.

