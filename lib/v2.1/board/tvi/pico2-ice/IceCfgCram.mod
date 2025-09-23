MODULE IceCfgCram;
(**
  Oberon RTK Framework v2.1
  --
  Configure the iCE FPGA by writing the configuration RAM (CRAM).
  FPGA: Lattice Semi iCE40 UltraPlus 5k
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    MCU := MCU2, Ice := ICE40UP5K, SPIdev, SPIdata, GPIO, Errors, Timers, BinRes;

  CONST
    (* wired/defined by hardware *)
    SPIno = Ice.SPIno;
    SPIsclkFreq = Ice.SPIsclkFreq;
    SPItxPin = Ice.SPItxPinCram;
    SPIrxPin = Ice.SPIrxPin;
    SPIsclkPin = Ice.SPIsclkPin;
    IceCsPin = Ice.IceCsPin;
    IceResetPin = Ice.IceResetPin;
    IceDonePin = Ice.IceDonePin;
    SPIcpol = Ice.SPIcpol;
    SPIcpha = Ice.SPIcpha;
    SPItxShift = Ice.SPItxShift;


  PROCEDURE configSPI(spiDev: SPIdev.Device);
    VAR spiCfg: SPIdev.DeviceCfg;
  BEGIN
    ASSERT(spiDev # NIL, Errors.PreCond);
    SPIdev.GetBaseCfg(spiCfg);
    spiCfg.cpol := SPIcpol;
    spiCfg.cpha := SPIcpha;
    spiCfg.txShift := SPItxShift;
    SPIdev.Configure(spiDev, spiCfg, SPIsclkFreq)
  END configSPI;


  PROCEDURE configSPIpins(spiTxPin, spiRxPin, spiSclkPin, iceCsPin: INTEGER);
  (* all SPI pins are left in hi-z via ResetPin *)
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    (* tx/mosi *)
    GPIO.ResetPin(spiTxPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;    
    GPIO.ConfigurePad(spiTxPin, padCfg);

    (* sclk *)
    GPIO.ResetPin(spiSclkPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Enabled;
    GPIO.ConfigurePad(spiSclkPin, padCfg);

    (* rx/miso (unused) *)
    GPIO.ResetPin(spiRxPin);

    (* cs: output, ice-internal/on-board pull-up *)
    GPIO.ResetPin(iceCsPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    GPIO.ConfigurePad(iceCsPin, padCfg);
    GPIO.OutputEnable2({iceCsPin}, {});
    GPIO.Set2({iceCsPin}, {}); (* active low *)
  END configSPIpins;


  PROCEDURE configIcePins(iceResetPin, iceDonePin: INTEGER);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    (* reset: output, on-board pull-down *)
    GPIO.ResetPin(iceResetPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    padCfg.outputDe := GPIO.OutputConn;
    GPIO.ConfigurePad(iceResetPin, padCfg);
    GPIO.SetFunction(iceResetPin, MCU.IO_BANK0_Fsio);
    GPIO.OutputEnable2({iceResetPin}, {});
    GPIO.Clear2({iceResetPin}, {}); (* keep CRESET low = reset status *)

    (* done: input *)
    GPIO.ResetPin(iceDonePin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    padCfg.inputEn := GPIO.Enabled;
    GPIO.ConfigurePad(iceDonePin, padCfg);
    GPIO.SetFunction(iceDonePin, MCU.IO_BANK0_Fsio)
  END configIcePins;


  PROCEDURE ConfigCram*(VAR binRes: BinRes.BinDataRes; VAR done: BOOLEAN);
  CONST Delay0 = 2; Delay1 = 1400; (* microseconds *)
    VAR
      spi: SPIdev.Device; timer: Timers.Device;
      i, donePinH: INTEGER; data: BYTE; inL, inH: SET;
  BEGIN
    (* delay timer *)
    NEW(timer); ASSERT(timer # NIL, Errors.HeapOverflow);
    Timers.Init(timer, Timers.TIMER0);

    (* SPI device and pins *)
    NEW(spi); ASSERT(spi # NIL, Errors.HeapOverflow);
    SPIdev.Init(spi, SPIno);
    configSPI(spi);
    SPIdev.Enable(spi);
    configSPIpins(SPItxPin, SPIrxPin, SPIsclkPin, IceCsPin);
    configIcePins(IceResetPin, IceDonePin);

    (* reset fpga, pull cs low, release reset after 200+ ns *)
    (* sets fpga into cram configuration mode *)
    (* connect all spi and cs pins, release after configuration *)
    GPIO.Clear2({IceResetPin}, {});
    GPIO.SetFunction(IceCsPin, MCU.IO_BANK0_Fsio); (* connects from hi-z *)
    GPIO.Clear2({IceCsPin}, {});
    Timers.DelayBlk(timer, Delay0);
    GPIO.Set2({IceResetPin}, {});

    (* wait for 1200+ us to allow fpga clearing configuration/housekeeping *)
    Timers.DelayBlk(timer, Delay1);

    (* connect spi (no rx/miso) *)
    GPIO.SetFunction(SPItxPin, MCU.IO_BANK0_Fspi);
    GPIO.SetFunction(SPIsclkPin, MCU.IO_BANK0_Fspi);
    
    (* set cs high, send 8 spi clock cycles = 1 byte *)
    GPIO.Set2({IceCsPin}, {});
    SPIdata.PutByte(spi, spi.txShift);

    (* set cs low, send cram data *)
    (* ice config data is binary resource in program *)
    GPIO.Clear2({IceCsPin}, {});
    done := FALSE; (* misuse parameter for a second *)
    WHILE ~done DO
      data := BinRes.NextByte(binRes, done);
      SPIdata.PutByte(spi, data);
    END;

    (* set cs high, wait ~100 spi clock cycles for fgpa DONE pin go high *)
    GPIO.Set2({IceCsPin}, {});
    donePinH := IceDonePin - 32;
    i := 0; done := FALSE;
    WHILE (i < 14) & ~done DO
      SPIdata.PutByte(spi, spi.txShift);
      GPIO.Get2(inL, inH);
      done := donePinH IN inH;
      INC(i)
    END;

    (* wait 49+ spi clock cycles for fpga to release its spi pins *)
    i := 0;
    WHILE i < 8 DO
      SPIdata.PutByte(spi, spi.txShift);
      INC(i)
    END;
    
    (* disconnect cs and spi pins *)
    (* ICE pins can then be used in the fpga logic *)
    (* reset physical SPI device, dispose SPI device data *)
    (* dispose timer device data, leave physical device untouched *)
    GPIO.ResetPin(IceCsPin);
    GPIO.ResetPin(SPItxPin);
    GPIO.ResetPin(SPIsclkPin);
    SPIdev.Disable(spi);
    SPIdev.ApplyReset(spi);
    DISPOSE(spi);
    DISPOSE(timer)
  END ConfigCram;

END IceCfgCram.
