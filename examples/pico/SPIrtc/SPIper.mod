MODULE SPIper;
(**
  Oberon RTK Framework
  --
  SPI peripheral (Motorola SPI)
  * initialisation of SPI peripheral data structure
  * configure peripheral
  * select/deselect SPI peripheral (chip select, CS)
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, Errors;

  CONST
    CSsio* = 0; (* use SIO to toggle CS pin, can use several peripherals with shared MOSI, MISO, and SCLK *)
    CSspi* = 1; (* let SPI device toggle CS pin, can only use one peripheral *)

  TYPE
    Peripheral* = POINTER TO PeripheralDesc;
    PeripheralDesc* = RECORD
      csPinNo: INTEGER;       (* GPIO pin no *)
      cpol, cpha: INTEGER;    (* 0 or 1 *)
      sclkFreq: INTEGER;      (* in Hz *)
      dataSize: INTEGER;      (* SPId.DataSize8 or SPId.DataSize16 *)
      txShift: INTEGER;       (* value to transmit to peripheral to receive data *)
      csMode: INTEGER         (* CSsio or CSspi *)
    END;


  PROCEDURE Init*(per: Peripheral; sclkFreq, dataSize, cpol, cpha, csPinNo, txShift, csMode: INTEGER);
  BEGIN
    ASSERT(per # NIL, Errors.PreCond);
    ASSERT(csMode IN {CSsio, CSspi});
    per.csPinNo := csPinNo;
    per.cpol := cpol;
    per.cpha := cpha;
    per.sclkFreq := sclkFreq;
    per.dataSize := dataSize;
    per.txShift := txShift;
    per.csMode := csMode
  END Init;


  PROCEDURE Configure*(per: Peripheral);
    VAR en: SET;
  BEGIN
    IF per.csMode = CSsio THEN
      GPIO.SetFunction(per.csPinNo, GPIO.Fsio);
      en := {per.csPinNo};
      GPIO.OutputEnable(en);
      GPIO.Set(en)
    ELSE
      GPIO.SetFunction(per.csPinNo, GPIO.Fspi)
    END
  END Configure;


  PROCEDURE Select*(per: Peripheral);
    VAR en: SET;
  BEGIN
    IF per.csMode = CSsio THEN
      en := {per.csPinNo}; (* workaround v9.1 *)
      GPIO.Clear(en)
    END
  END Select;


  PROCEDURE Deselect*(per: Peripheral);
    VAR en: SET;
  BEGIN
    IF per.csMode = CSsio THEN
      en := {per.csPinNo}; (* workaround v9.1 *)
      GPIO.Set(en)
    END
  END Deselect;


  PROCEDURE GetSPIparams*(per: Peripheral; VAR sclkFreq, dataSize, cpol, cpha, txShift: INTEGER);
  BEGIN
    cpol := per.cpol;
    cpha := per.cpha;
    sclkFreq := per.sclkFreq;
    dataSize := per.dataSize;
    txShift := per.txShift
  END GetSPIparams;

END SPIper.

