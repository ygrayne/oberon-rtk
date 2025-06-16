MODULE Ice40up5k;
(**
  Oberon RTK Framework v2.1
  --
  Lattice Semi iCE40 UltraPlus 5k FPGA
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, ClockOut, SPIdev, GPIO, Errors, Timers, BinRes;

  CONST
    SPIno* = SPIdev.SPI0;
    SPIsclkFreq* = 4 * 1000000;
    SPImosiPin = 35;
    SPImisoPin = 4;
    SPIsclkPin = 6;
    iceCsCramPin = 5;
    IceResetPin = 31;
    IceDonePin = 40;
    IceClockPin = 21;
    SPIcpol* = 1;
    SPIcpha* = 1;
    IceClockDivInt* = 1; (* full 48 MHz peri clock *)


  TYPE
    Pin = INTEGER;
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      spi: SPIdev.Device;
      spiMosiPin: Pin;      (* SPI_SI, via jumper cable from RP36 = SPIO Tx *)
      spiMisoPin: Pin;      (* unused for CRAM *)
      spiSclkPin: Pin;      (* SPI_SCK *)
      iceCsCramPin: Pin;    (* SPI_SS *)
      iceResetPin: Pin;
      iceDonePin: Pin;
      iceClockPin: Pin;
    END;

  VAR
    timer: Timers.Device; (* delay timer *)


  PROCEDURE Init*(dev: Device; spiDev: SPIdev.Device);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    dev.spi := spiDev;
    dev.spiMosiPin := SPImosiPin;
    dev.spiMisoPin := SPImisoPin;
    dev.spiSclkPin := SPIsclkPin;
    dev.iceCsCramPin := iceCsCramPin;
    dev.iceResetPin := IceResetPin;
    dev.iceClockPin := IceClockPin;
    dev.iceDonePin := IceDonePin;
  END Init;


  PROCEDURE ConfigSPI*(spiDev: SPIdev.Device);
    VAR spiCfg: SPIdev.DeviceCfg;
  BEGIN
    ASSERT(spiDev # NIL, Errors.PreCond);
    SPIdev.GetBaseCfg(spiCfg);
    spiCfg.cpol := SPIcpol;
    spiCfg.cpha := SPIcpha;
    SPIdev.Configure(spiDev, spiCfg, SPIsclkFreq)
  END ConfigSPI;


  PROCEDURE ConfigSPIpins*(dev: Device);
  (* all SPI pins are left in hi-z via ResetPad *)
  (* only used for CRAM configuration, ice pins can then be used for FPGA logic *)
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    (* mosi *)
    GPIO.ResetPad(dev.spiMosiPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Enabled;
    padCfg.pullupEn := GPIO.Disabled;
    GPIO.ConfigurePad(dev.spiMosiPin, padCfg);

    (* sclk *)
    GPIO.ResetPad(dev.spiSclkPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Enabled; (* cpol = 1 *)
    GPIO.ConfigurePad(dev.spiSclkPin, padCfg);

    (* miso (unused) *)
    GPIO.ResetPad(dev.spiSclkPin);

    (* cs: output, ice-internal pull-up *)
    GPIO.ResetPad(dev.iceCsCramPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    GPIO.ConfigurePad(dev.iceCsCramPin, padCfg);
    GPIO.OutputEnable2({dev.iceCsCramPin}, {});
    GPIO.Set2({dev.iceCsCramPin}, {}); (* active low *)
  END ConfigSPIpins;


  PROCEDURE ConfigIcePins*(dev: Device);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    (* reset: output, on-board pull-down *)
    GPIO.ResetPad(dev.iceResetPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    padCfg.outputDe := GPIO.OutputConn;
    GPIO.ConfigurePad(dev.iceResetPin, padCfg);
    GPIO.OutputEnable2({dev.iceResetPin}, {});
    GPIO.Clear2({dev.iceResetPin}, {}); (* keep CRESET low = reset status *)
    GPIO.SetFunction(dev.iceResetPin, MCU.IO_BANK0_Fsio);

    (* clock: output *)
    GPIO.ResetPad(dev.iceClockPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    GPIO.ConfigurePad(dev.iceClockPin, padCfg);
    GPIO.SetFunction(dev.iceClockPin, MCU.IO_BANK0_Fclk);

    (* done: input *)
    GPIO.ResetPad(dev.iceDonePin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    padCfg.inputEn := GPIO.Enabled;
    GPIO.ConfigurePad(dev.iceDonePin, padCfg);
    GPIO.SetFunction(dev.spiMosiPin, MCU.IO_BANK0_Fsio);
  END ConfigIcePins;


  PROCEDURE putByte(dev: SPIdev.Device; data: BYTE);
  (* SPI tx, neglect miso *)
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(dev.SR, SPIdev.SR_TNF);
    SYSTEM.PUT(dev.TDR, data)
  END putByte;


  PROCEDURE awaitTxFifoEmpty(dev: SPIdev.Device);
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(dev.SR, SPIdev.SR_TFE);
  END awaitTxFifoEmpty;


  PROCEDURE StartClock*(freqDivInt: INTEGER); (* integer divisor *)
  (* clock out 0 on RP21 feeds ICE35 *)
  BEGIN
    ClockOut.Start(ClockOut.COUT0, MCU.CLK_GPOUT_ClkPeri, freqDivInt, 0)
  END StartClock;


  PROCEDURE StartCram*(dev: Device; VAR binRes: BinRes.BinDataRes; VAR done: BOOLEAN);
  CONST Dummy = 055H; Delay0 = 2; Delay1 = 1400; (* microseconds *)
    VAR i, donePinH: INTEGER; data: BYTE; inL, inH: SET;
  BEGIN
    (* reset fpga, pull cs low, release reset after 200+ ns *)
    (* sets fpga into cram configuration mode *)
    (* connects all spi and cs pins, releases after configuration *)
    GPIO.Clear2({dev.iceResetPin}, {});
    GPIO.SetFunction(dev.iceCsCramPin, MCU.IO_BANK0_Fsio); (* connects from hi-z *)
    GPIO.Clear2({dev.iceCsCramPin}, {});
    Timers.DelayBlk(timer, Delay0);
    GPIO.Set2({dev.iceResetPin}, {});

    (* wait for 1200+ us to allows fpga to clear configuration/housekeeping *)
    Timers.DelayBlk(timer, Delay1);

    (* connect spi (no miso) *)
    GPIO.SetFunction(dev.spiMosiPin, MCU.IO_BANK0_Fspi);
    GPIO.SetFunction(dev.spiSclkPin, MCU.IO_BANK0_Fspi);

    (* set cs high, send 8 spi clock cycles = 1 byte *)
    GPIO.Set2({dev.iceCsCramPin}, {});
    putByte(dev.spi, Dummy);
    awaitTxFifoEmpty(dev.spi);

    (* set cs low, send cram data *)
    (* ice config data is binary resource in program *)
    GPIO.Clear2({dev.iceCsCramPin}, {});
    done := FALSE; (* misuse parameter for a second *)
    WHILE ~done DO
      data := BinRes.NextByte(binRes, done);
      putByte(dev.spi, data);
    END;
    awaitTxFifoEmpty(dev.spi);

    (* set cs high, wait ~100 spi clock cycles for fgpa DONE pin go high *)
    GPIO.Set2({dev.iceCsCramPin}, {});
    donePinH := dev.iceDonePin - 32;
    i := 0; done := FALSE;
    WHILE (i < 14) & ~done DO
      putByte(dev.spi, Dummy);
      GPIO.Get2(inL, inH);
      done := donePinH IN inH;
      INC(i)
    END;

    (* wait 49+ spi clock cycles for fpga to release its spi pins *)
    i := 0;
    WHILE i < 8 DO
      putByte(dev.spi, Dummy);
      INC(i)
    END;

    (* disconnect cs and spi pins *)
    (* ICE pins can then be used in the fpga logic *)
    GPIO.ResetPad(dev.iceCsCramPin);
    GPIO.ResetPad(dev.spiMosiPin);
    GPIO.ResetPad(dev.spiSclkPin)
  END StartCram;


  PROCEDURE StartFlash*(dev: Device);
    CONST Delay0 = 2; (* microseconds *)
  BEGIN
    GPIO.Clear2({dev.iceResetPin}, {});
    Timers.DelayBlk(timer, Delay0);
    GPIO.Set2({dev.iceResetPin}, {})
  END StartFlash;


  PROCEDURE Stop*(dev: Device);
  (* pull iCE CRESET low *)
  BEGIN
    GPIO.Clear2({dev.iceResetPin}, {});
    GPIO.DisconnectOutput(dev.iceResetPin) (* hi-z, let pull-down take over *)
  END Stop;


  PROCEDURE init;
  BEGIN
    NEW(timer);
    Timers.Init(timer, Timers.TIMER0)
  END init;

BEGIN
  init
END Ice40up5k.
