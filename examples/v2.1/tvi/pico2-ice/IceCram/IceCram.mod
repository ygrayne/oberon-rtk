MODULE IceCram;
(**
  Oberon RTK Framework v2.1
  --
  Example program: configure the iCE FPGA by loading a bitstram file
  directly into its configuration RAM (CRAM).
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Ice := Ice40up5k, SPIdev, Errors, Out, BinRes, IceData;

  PROCEDURE run;
  (* configure iCE from binary resource data 'IceData' in this program *)
    VAR
      ice: Ice.Device;
      spi: SPIdev.Device;
      done: BOOLEAN;
      binRes: BinRes.BinDataRes;
  BEGIN
    Out.String("begin"); Out.Ln;
    NEW(spi); ASSERT(spi # NIL, Errors.HeapOverflow);
    SPIdev.Init(spi, Ice.SPIno);
    Ice.ConfigSPI(spi);
    SPIdev.Enable(spi);

    NEW(ice); ASSERT(ice # NIL, Errors.HeapOverflow);
    Ice.Init(ice, spi);

    Ice.StartClock(Ice.IceClockDivInt);
    Ice.ConfigSPIpins(ice);
    Ice.ConfigIcePins(ice);

    BinRes.GetBinDataRes("IceData", binRes);
    done := FALSE;
    IF binRes.resAddr # 0 THEN
      Ice.StartCram(ice, binRes, done)
    END;

    IF done THEN
      Out.String("success")
    ELSE
      Out.String("failed")
    END;
    Out.Ln
  END run;


  PROCEDURE run2;
  (* start from iCE config on flash *)
    VAR ice: Ice.Device;
  BEGIN
    Out.String("begin"); Out.Ln;
    NEW(ice); ASSERT(ice # NIL, Errors.HeapOverflow);
    Ice.Init(ice, NIL);
    Ice.StartClock(Ice.IceClockDivInt);
    Ice.ConfigIcePins(ice);
    Ice.StartFlash(ice)
  END run2;


BEGIN
  run
END IceCram.
