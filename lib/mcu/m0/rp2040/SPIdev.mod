MODULE SPIdev;
(**
  Oberon RTK Framework
  SPI device (Motorola SPI only)
  * initialisation of SPI device data structure
  * configure IO bank and pads, serial clock rate, data size, CPOL, CPHA
  * enable physical device
  * utility functionality
  Other modules implement the actual specific IO functionality. 'SPIdata'
  implements binary data IO with busy waiting, a module 'SPIstr' could
  implement string IO, etc.
  --
  Chip Select (CS) must be done by client.
  Tx and Rx FIFOs are always enabled (each 8x 16 bits).
  Only master mode is considered/implemented here.
  --
  The RP2040 also supports TI synchronous serial and
  National Semiconductor Microwire frame formats.
  They are not considered/implemented here.
  --
  * 'Device' denotes the circuit in the MCU
  * 'Peripheral' denotes the MCU-external equipment, eg. a temperature sensor
  --
  Serial clock rate conditions:
  * clkRate (max) * 2 <= MCU.PeriClkFreq
  * clkRate (min) * 254 * 256 <= MCU.PeriClkFreq
  With PeriClkFreq = 48 MHz:
  * clkRate (max) = 24 MHz
  * clkRate (min) = 739 Hz
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, GPIO, StartUp;

  CONST
    SPI0* = 0;
    SPI1* = 1;

    (* generic values *)
    Enabled* = 1;
    Disabled* = 0;
    None* = 0;

    (* CR0 bits and values *)
    CR0_SCR1* = 15;  (* [15:8] serial clock frequency *)
    CR0_SCR0* = 8;
    CR0_SPH* = 7;    (* serial clock phase, CPHA, Motorola SPI only, reset = 0 *)
    CR0_SPO* = 6;    (* serial clock polarity, CPOL, Motorola SPI only, reset = 0 *)
    CR0_FRF1* = 5;   (* [5:4] frame format *)
    CR0_FRF0* = 4;
    FRFval_SPI* = 0; (* Motorola SPI, reset value *)
    FRFval_SS* = 1;  (* TI synchronous serial *)
    FRFval_MW* = 2;  (* National Semiconductor Microwire *)
    CR0_DSS1* = 3;   (* [3:0] data size select *)
    CR0_DSS0* = 0;
    DSSval_8* = 7;   (* 8 bits *)
    DSSval_16* = 15; (* 16 bits *)

    DataSize8* =  DSSval_8;
    DataSize16* =  DSSval_16;

    (* CR1 bits *)
    CR1_SOD* = 3;  (* slave output disable, reset = enabled *)
    CR1_MS* = 2;   (* master/slave select, reset = master *)
    CR1_SSE* = 1;  (* serial port enable, reset = disabled *)
    CR1_LBM* = 0;  (* loop back mode enable, reset = disabled *)

    (* SR bits *)
    SR_BSY* = 4;  (* busy *)
    SR_RFF* = 3;  (* receive fifo full *)
    SR_RNE* = 2;  (* receive fifo not empty *)
    SR_TNF* = 1;  (* transmit fifo not full *)
    SR_TFE* = 0;  (* transmit fifo empty *)

    FifoDepth* = 8;


  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      spiNo: INTEGER;
      devNo: INTEGER;
      txShift*: INTEGER;
      CR0, CR1, CPSR, IMSC: INTEGER;
      TDR*, RDR*, SR*: INTEGER
      (* interrupt/dma regs will be added as/when needed *)
    END;


  PROCEDURE Init*(dev: Device; spiNo, (*mosiPinNo, misoPinNo, sclkPinNo,*) txShift: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(spiNo IN {SPI0, SPI1}, Errors.PreCond);
    dev.spiNo := spiNo;
    dev.txShift := txShift;
    CASE spiNo OF
      SPI0: base := MCU.SPI0_Base; dev.devNo := MCU.RESETS_SPI0;
    | SPI1: base := MCU.SPI1_Base; dev.devNo := MCU.RESETS_SPI1;
    END;
    dev.CR0  := base + MCU.SPI_CR0_Offset;
    dev.CR1  := base + MCU.SPI_CR1_Offset;
    dev.CPSR := base + MCU.SPI_CPSR_Offset;
    dev.IMSC := base + MCU.SPI_IMSC_Offset;
    dev.TDR  := base + MCU.SPI_DR_Offset;
    dev.RDR  := base + MCU.SPI_DR_Offset;
    dev.SR   := base + MCU.SPI_SR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; sclkRate, dataSize, cpol, cpha, mosiPinNo, misoPinNo, sclkPinNo: INTEGER);
    VAR preDiv, scr, x: INTEGER; misoCfg: GPIO.PadConfig;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(dataSize IN {DSSval_8, DSSval_16}, Errors.PreCond);
    ASSERT(cpol IN {0, 1}, Errors.PreCond);
    ASSERT(cpha IN {0, 1}, Errors.PreCond);
    (* release reset on SPI device *)
    StartUp.ReleaseReset(dev.devNo);
    StartUp.AwaitReleaseDone(dev.devNo);
    SYSTEM.PUT(dev.CR1, {}); (* disable *)

    (* find/set serial clock rate *)
    (* preDiv is an even integer between 2 and 254, inclusive *)
    (* scr is an integer between 1 and 255, inclusive *)
    x := (MCU.PeriClkFreq * 8) DIV sclkRate;
    preDiv := 2;
    WHILE (preDiv < 255) & (preDiv * 2048 <= x) DO
      INC(preDiv, 2)
    END;
    ASSERT(preDiv < 255, Errors.ProgError);
    x := (x DIV (preDiv * 8)) - 1;
    scr := 255;
    WHILE (scr >=0) & (scr > x) DO
      DEC(scr)
    END;
    (* set config regs *)
    SYSTEM.PUT(dev.CPSR, preDiv);
    x := 0;
    BFI(x, CR0_DSS1, CR0_DSS0, dataSize);
    BFI(x, CR0_FRF1, CR0_FRF0, FRFval_SPI); (* fixed: SPI format *)
    BFI(x, CR0_SPO, cpol);
    BFI(x, CR0_SPH, cpha);
    BFI(x, CR0_SCR1, CR0_SCR0, scr);
    SYSTEM.PUT(dev.CR0, x);

    (* config GPIO device *)
    GPIO.SetFunction(mosiPinNo, GPIO.Fspi);
    GPIO.SetFunction(misoPinNo, GPIO.Fspi);
    GPIO.SetFunction(sclkPinNo, GPIO.Fspi);

    (* config miso pad *)
    misoCfg.drive := GPIO.CurrentValue;
    misoCfg.pullUp := GPIO.Enabled; (* pull-up on *)
    misoCfg.pullDown := GPIO.Disabled; (* pull-down off *)
    misoCfg.schmittTrig := GPIO.CurrentValue;
    misoCfg.slewRate := GPIO.CurrentValue;
    GPIO.ConfigurePad(misoPinNo, misoCfg)
  END Configure;


  PROCEDURE Enable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.PUT(dev.CR1 + MCU.ASET, {CR1_SSE})
  END Enable;


  PROCEDURE Disable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.PUT(dev.CR1 + MCU.ACLR, {CR1_SSE})
  END Disable;


  PROCEDURE Flags*(dev: Device): SET;
    VAR flags: SET;
  BEGIN
    SYSTEM.GET(dev.SR, flags)
    RETURN flags
  END Flags;


  PROCEDURE EnableLoopback*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.CR1 + MCU.ASET, {CR1_LBM})
  END EnableLoopback;


  PROCEDURE DisableLoopback*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.CR1 + MCU.ACLR, {CR1_LBM})
  END DisableLoopback;

END SPIdev.
