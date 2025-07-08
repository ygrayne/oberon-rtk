MODULE IceCfgFlash;
(**
  Oberon RTK Framework v2.1
  --
  Configure the iCE FPGA by writing its dedicated on-board configuration flash memory.
  FPGA: Lattice Semi iCE40 UltraPlus 5k
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Ice := ICE40UP5K, Flash := W25Q32JV, SPIdev, Errors, BinRes;

  CONST
    (* wired/defined by hardware *)
    SPIno = Ice.SPIno;

    FlashCfgAddr = 0H; (* addr where iCE will read config data *)
    FlashPageSize = Flash.PageSize;
    FlashBlockSize = Flash.BlockSize64;


  PROCEDURE ConfigFlash*(VAR binRes: BinRes.BinDataRes; VAR done: BOOLEAN);
    VAR
      spi: SPIdev.Device; flash: Flash.Device; flashCfg: Flash.DeviceCfg;
      addr, cnt: INTEGER;
      page: ARRAY FlashPageSize OF BYTE;
  BEGIN
    (* SPI device and pins *)
    NEW(spi); ASSERT(spi # NIL, Errors.HeapOverflow);
    SPIdev.Init(spi, SPIno);
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

    Flash.Wakeup(flash);
    Flash.EraseBlock64(flash, FlashCfgAddr);
    Flash.EraseBlock64(flash, FlashCfgAddr + FlashBlockSize);

    done := FALSE;
    addr := FlashCfgAddr;
    WHILE ~done DO
      cnt := 0;
      WHILE (cnt < FlashPageSize) & ~done DO
        page[cnt] := BinRes.NextByte(binRes, done);
        INC(cnt)
      END;
      Flash.WritePage(flash, addr, page, cnt);
      INC(addr, FlashPageSize)
    END;

    Flash.ResetPins(flash);
    SPIdev.ApplyReset(spi);
    DISPOSE(flash);
    DISPOSE(spi)
  END ConfigFlash;

END IceCfgFlash.
