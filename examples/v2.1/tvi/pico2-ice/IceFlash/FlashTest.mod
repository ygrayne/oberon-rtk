MODULE FlashTest;
(**
  Oberon RTK Framework v2.1
  --
  Test program: write and read Ice flash test data.
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Ice := ICE40UP5K, Flash := W25Q32JV, SPIdev, Errors, Out;

  CONST
    DataSizePage = Flash.PageSize;
    DataSizeSector = Flash.SectorSize;
    DataSizeBlock32 = Flash.BlockSize32;
    DataSizeBlock64 = Flash.BlockSize64;

    DataSize = DataSizeBlock64;

  PROCEDURE run;
    CONST BaseAddr = 0H;
    VAR
      i, pages, addr: INTEGER;
      flash: Flash.Device; flashCfg: Flash.DeviceCfg;
      spi: SPIdev.Device;
      wrData, rdData: ARRAY DataSize OF BYTE;
  BEGIN
    Out.String("begin test"); Out.Ln;
    NEW(spi); ASSERT(spi # NIL, Errors.HeapOverflow);
    SPIdev.Init(spi, Ice.SPIno);
    Flash.ConfigSPI(spi);
    SPIdev.Enable(spi);

    NEW(flash); ASSERT(flash # NIL, Errors.HeapOverflow);
    flashCfg.spi := spi;
    flashCfg.spiTxPin := Ice.SPItxPinFlash;
    flashCfg.spiRxPin := Ice.SPIrxPin;
    flashCfg.spiSclkPin := Ice.SPIsclkPin;
    flashCfg.csPin := Ice.IceCsPin;
    Flash.Init(flash, flashCfg);
    Flash.ConfigPins(flash);

    Out.String("create test data"); Out.Ln;
    i := 0;
    WHILE i < DataSize DO
      wrData[i] := i MOD 256; INC(i)
    END;

    Out.String("wake-up"); Out.Ln;
    Flash.Wakeup(flash);
    
    IF DataSize <= DataSizePage THEN
      Out.String("erase sector 4k"); Out.Ln;
      Flash.EraseSector(flash, BaseAddr)
    ELSIF DataSize <= DataSizeSector THEN
      Out.String("erase sector 4k"); Out.Ln;
      Flash.EraseSector(flash, BaseAddr)
    ELSIF DataSize <= DataSizeBlock32 THEN
      Out.String("erase block 32k"); Out.Ln;
      Flash.EraseBlock32(flash, BaseAddr)
    ELSIF DataSize <= DataSizeBlock64 THEN
      Out.String("erase block 64k"); Out.Ln;
      Flash.EraseBlock64(flash, BaseAddr)
    ELSE
      ASSERT(FALSE)
    END;

    Out.String("read erased, print any errors");
    Flash.Read(flash, BaseAddr, rdData, DataSize);
    i := 0;
    WHILE i < DataSize DO
      IF rdData[i] # 0FFH THEN
        Out.Hex(rdData[i], 10); Out.Ln
      END;
      INC(i)
    END;
    Out.String(" - done"); Out.Ln;

    pages := DataSize DIV Flash.PageSize;
    addr := BaseAddr;
    Out.String("write data (bytes/pages): "); Out.Int(DataSize, 0);
    Out.String("/"); Out.Int(pages, 0); Out.Ln;
    i := 0;
    WHILE i < pages DO
      Flash.WritePage(flash, addr, wrData, Flash.PageSize);
      INC(addr, Flash.PageSize); INC(i)
    END;

    Out.String("read back data, print any errors");
    Flash.Read(flash, BaseAddr, rdData, DataSize);
    i := 0;
    WHILE i < DataSize DO
      IF rdData[i] # i MOD 256 THEN
        Out.Hex(rdData[i], 10); Out.Ln
      END;
      INC(i)
    END;
    Out.String(" - done"); Out.Ln;

    Flash.ResetPins(flash);
    SPIdev.Disable(spi);
    Out.String("end test"); Out.Ln
  END run;

BEGIN
  run
END FlashTest.
