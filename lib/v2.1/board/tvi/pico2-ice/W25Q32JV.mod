MODULE W25Q32JV;
(**
  Oberon RTK Framework v2.1
  --
  FPGA flash memory on Pico2-Ice
  Winbond W25Q32JV 4 MB
  --
  Note: iCE config bitstream file is < 128 kB
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    MCU := MCU2, GPIO, SPIdev, SPIdata, Errors;

  CONST
    (* SPI cfg *)
    SPIsclkFreq = 12 * 1000000;
    SPIcpol = 0;
    SPIcpha = 0;

    (* Flash status registers *)
    StatusReg1* = 1;
    StatusReg2* = 2;
    StatusReg3* = 3;

    (* Flash commands *)
    CmdPageProgram  = 002H;
    CmdRead         = 003H;
    CmdStatusReg1   = 005H;
    CmdStatusReg2   = 035H;
    CmdStatusReg3   = 015H;
    CmdWriteEnable  = 006H;
    CmdWriteDisable  = 004H;
    CmdSectorErase  = 020H;
    CmdBlockErase32 = 052H;
    CmdBlockErase64 = 0D8H;
    CmdChipErase    = 0C7H;
    CmdReleasePowerdown = 0ABH;
    CmdPowerdown    = 0B9H;
    CmdResetEnable  = 066H;
    CmdChipReset    = 099H;

    (* flash status bits *)
    StatusBusy   = 0;

    (* flash sizes *)
    PageSize*     = 256; (* bytes *)
    SectorSize*   =    16 * PageSize;  (*    0100H / 4,096 bytes *)
    BlockSize32*  =   128 * PageSize;  (*   08000H / 32,768 bytes *)
    BlockSize64*  =   256 * PageSize;  (*  010000H / 65,536 bytes *)
    Size*         = 16384 * PageSize;  (* 0400000H / 4,194,304 bytes *)


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      spi: SPIdev.Device;
      spiTxPin: INTEGER;
      spiRxPin: INTEGER;
      spiSclkPin: INTEGER;
      csPin: INTEGER
    END;

    DeviceCfg* = RECORD
      spi*: SPIdev.Device;
      spiTxPin*, spiRxPin*, spiSclkPin*: INTEGER;
      csPin*: INTEGER
    END;


  PROCEDURE Init*(dev: Device; cfg: DeviceCfg);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    dev.spi := cfg.spi;
    dev.spiTxPin := cfg.spiTxPin;
    dev.spiRxPin := cfg.spiRxPin;
    dev.spiSclkPin := cfg.spiSclkPin;
    dev.csPin := cfg.csPin
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


  PROCEDURE ConfigPins*(dev: Device);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    (* mosi/tx *)
    GPIO.ResetPin(dev.spiTxPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Enabled;
    padCfg.pullupEn := GPIO.Disabled;
    GPIO.ConfigurePad(dev.spiTxPin, padCfg);
    GPIO.SetFunction(dev.spiTxPin, MCU.IO_BANK0_Fspi);

    (* miso/rx, on-board pull-down *)
    GPIO.ResetPin(dev.spiRxPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    padCfg.inputEn := GPIO.Enabled;
    GPIO.ConfigurePad(dev.spiRxPin, padCfg);
    GPIO.SetFunction(dev.spiRxPin, MCU.IO_BANK0_Fspi);

    (* sclk *)
    GPIO.ResetPin(dev.spiSclkPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Enabled;
    GPIO.ConfigurePad(dev.spiSclkPin, padCfg);
    GPIO.SetFunction(dev.spiSclkPin, MCU.IO_BANK0_Fspi);

    (* cs: output, ice-internal/on-board pull-up  *)
    GPIO.ResetPin(dev.csPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    GPIO.ConfigurePad(dev.csPin, padCfg);
    GPIO.SetFunction(dev.csPin, MCU.IO_BANK0_Fsio);
    GPIO.OutputEnable2({dev.csPin}, {});
    GPIO.Set2({dev.csPin}, {}); (* active low *)
  END ConfigPins;


  PROCEDURE ResetPins*(dev: Device);
  BEGIN
    GPIO.ResetPin(dev.spiTxPin);
    GPIO.ResetPin(dev.spiRxPin);
    GPIO.ResetPin(dev.spiSclkPin);
    GPIO.ResetPin(dev.csPin)
  END ResetPins;


  PROCEDURE GetStatus*(dev: Device; reg: INTEGER; VAR status: BYTE);
    CONST Cmd1 = CmdStatusReg1; Cmd2 = CmdStatusReg2; Cmd3 = CmdStatusReg3;
    VAR cmd: BYTE;
  BEGIN
    ASSERT(reg IN {1 .. 3}, Errors.PreCond);
    IF reg = 1 THEN
      cmd := Cmd1
    ELSIF reg = 2 THEN
      cmd := Cmd2
    ELSIF reg = 3 THEN
      cmd := Cmd3
    END;
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutByte(dev.spi, cmd);
    SPIdata.GetByte(dev.spi, status);
    GPIO.Set2({dev.csPin}, {})
  END GetStatus;


  PROCEDURE awaitDone(dev: Device);
    CONST Cmd = CmdStatusReg1;
    VAR status: BYTE;
  BEGIN
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutByte(dev.spi, Cmd);
    REPEAT
      SPIdata.GetByte(dev.spi, status);
    UNTIL ~(StatusBusy IN BITS(ORD(status)));
    GPIO.Set2({dev.csPin}, {})
  END awaitDone;


  PROCEDURE Wakeup*(dev: Device);
    CONST Cmd = CmdReleasePowerdown;
  BEGIN
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutByte(dev.spi, Cmd);
    GPIO.Set2({dev.csPin}, {})
  END Wakeup;


  PROCEDURE WriteEnable*(dev: Device);
    CONST Cmd = CmdWriteEnable;
  BEGIN
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutByte(dev.spi, Cmd);
    GPIO.Set2({dev.csPin}, {})
  END WriteEnable;


  PROCEDURE WriteDisable*(dev: Device);
    CONST Cmd = CmdWriteDisable;
  BEGIN
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutByte(dev.spi, Cmd);
    GPIO.Set2({dev.csPin}, {})
  END WriteDisable;


  PROCEDURE WritePage*(dev: Device; addr: INTEGER; data: ARRAY OF BYTE; n: INTEGER);
    CONST Cmd = CmdPageProgram;
    VAR cmd: ARRAY 4 OF BYTE;
  BEGIN
    ASSERT(n <= LEN(data), Errors.PreCond);
    ASSERT(n <= PageSize, Errors.PreCond);
    ASSERT(addr MOD PageSize = 0, Errors.PreCond);
    cmd[0] := Cmd;
    cmd[1] := LSR(addr, 16);
    cmd[2] := LSR(addr, 8);
    cmd[3] := addr;
    WriteEnable(dev);
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutBytes(dev.spi, cmd, 4);
    SPIdata.PutBytes(dev.spi, data, n);
    GPIO.Set2({dev.csPin}, {});
    awaitDone(dev)
  END WritePage;


  PROCEDURE Read*(dev: Device; addr: INTEGER; VAR data: ARRAY OF BYTE; n: INTEGER);
    CONST Cmd = CmdRead;
    VAR cmd: ARRAY 4 OF BYTE;
  BEGIN
    cmd[0] := Cmd;
    cmd[1] := LSR(addr, 16);
    cmd[2] := LSR(addr, 8);
    cmd[3] := addr;
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutBytes(dev.spi, cmd, 4);
    SPIdata.GetBytes(dev.spi, data, n);
    GPIO.Set2({dev.csPin}, {})
  END Read;


  PROCEDURE erase(dev: Device; addr, cmd: INTEGER);
    VAR cmd0: ARRAY 4 OF BYTE;
  BEGIN
    cmd0[0] := cmd;
    cmd0[1] := LSR(addr, 16);
    cmd0[2] := LSR(addr, 8);
    cmd0[3] := addr;
    WriteEnable(dev);
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutBytes(dev.spi, cmd, 4);
    GPIO.Set2({dev.csPin}, {});
    awaitDone(dev)
  END erase;


  PROCEDURE EraseSector*(dev: Device; addr: INTEGER);
    CONST Cmd = CmdSectorErase;
  BEGIN
    ASSERT(addr MOD SectorSize = 0, Errors.PreCond);
    erase(dev, addr, Cmd)
  END EraseSector;


  PROCEDURE EraseBlock32*(dev: Device; addr: INTEGER);
    CONST Cmd = CmdBlockErase32;
  BEGIN
    ASSERT(addr MOD BlockSize32 = 0, Errors.PreCond);
    erase(dev, addr, Cmd)
  END EraseBlock32;


  PROCEDURE EraseBlock64*(dev: Device; addr: INTEGER);
    CONST Cmd = CmdBlockErase64;
  BEGIN
    ASSERT(addr MOD BlockSize64 = 0, Errors.PreCond);
    erase(dev, addr, Cmd)
  END EraseBlock64;


  PROCEDURE EraseChip*(dev: Device);
    CONST Cmd = CmdChipErase;
  BEGIN
    GPIO.Clear2({dev.csPin}, {});
    SPIdata.PutByte(dev.spi, Cmd);
    GPIO.Set2({dev.csPin}, {});
    awaitDone(dev)
  END EraseChip;

END W25Q32JV.
