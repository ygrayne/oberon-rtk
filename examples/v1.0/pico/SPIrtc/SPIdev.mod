MODULE SPIdev;
(**
  Oberon RTK Framework
  --
  SPI device (master mode, Motorola SPI only)
  * initialisation of SPI device data structure
  * configure serial clock rate, data size, CPOL, CPHA
  * enable physical device
  * utility functionality
  Other modules implement the actual specific IO functionality. 'SPIdata'
  implements binary data IO with busy waiting, a module 'SPIstr' could
  implement string IO, etc.
  --
  Chip Select (CS) must be done by client.
  Tx and Rx FIFOs are always enabled in hardware (each 8x 16 bits).
  Only master mode is considered/implemented here.
  --
  The RP2040 also supports TI synchronous serial and
  National Semiconductor Microwire frame formats.
  These formats are not considered/implemented here.
  --
  Serial clock rate conditions:
  * clkRate (max) * 2 <= MCU.PeriClkFreq
  * clkRate (min) * 254 * 256 <= MCU.PeriClkFreq
  That is, with PeriClkFreq = 48 MHz:
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
    CR0_SCR1*         = 15;   (* [15:8] serial clock frequency *)
    CR0_SCR0*         = 8;
    CR0_SPH*          = 7;    (* serial clock phase, CPHA, Motorola SPI only, reset = 0 *)
    CR0_SPO*          = 6;    (* serial clock polarity, CPOL, Motorola SPI only, reset = 0 *)
    CR0_FRF1*         = 5;    (* [5:4] frame format *)
    CR0_FRF0*         = 4;
      FRF_val_SPI* = 0;  (* Motorola SPI, reset value *)
      FRF_val_SS*  = 1;  (* TI synchronous serial *)
      FRF_val_MW*  = 2;  (* National Semiconductor Microwire *)
    CR0_DSS1*         = 3;   (* [3:0] data size select *)
    CR0_DSS0*         = 0;
      DSS_val_8*  = 7;   (* 8 bits *)
      DSS_val_16* = 15;  (* 16 bits *)

    DataSize8* =  DSS_val_8;
    DataSize16* =  DSS_val_16;

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

    (* "human readable" config form *)
    (* see ASSERTs in 'MakeRunCfg' for valid values *)
    DeviceCfg* = RECORD
      (* reg CR0 *)
      scr*: INTEGER;
      cpha*: INTEGER;
      cpol*: INTEGER;
      (* frameFormat*: INTEGER; fixed to Motorola SPI *)
      dataSize*: INTEGER
    END;

    (* config form to be used at run time, see 'MakeRunCfg' *)
    DeviceRunCfg* = RECORD
      regValue: INTEGER;
      txShift: INTEGER;
    END;


  PROCEDURE Init*(dev: Device; spiNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(spiNo IN {SPI0, SPI1}, Errors.PreCond);
    dev.spiNo := spiNo;
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


  PROCEDURE Configure*(dev: Device; sclkRate, mosiPinNo, misoPinNo, sclkPinNo: INTEGER; VAR scr: INTEGER);
  (**
    Base configuration. Use 'SetRunCfg' before any transaction to completely configure the device,
    using a 'DeviceRunCfg' created with 'MakeRunCfg'.
    'scr' is the SCR value corresponding to 'sclkRate'.
    If several serial clock rates are required, set 'sclkRate' to the lowest one.
  **)
    VAR preScale, x: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);

    (* release reset on SPI device *)
    StartUp.ReleaseReset(dev.devNo);
    StartUp.AwaitReleaseDone(dev.devNo);

    (* disable, set master mode *)
    SYSTEM.PUT(dev.CR1, {});

    (* find/set serial clock rate *)
    (* preScale is an even integer between 2 and 254, inclusive *)
    (* scr is an integer between 1 and 255, inclusive *)
    x := (MCU.PeriClkFreq * 8) DIV sclkRate;
    preScale := 2;
    WHILE (preScale < 255) & (preScale * 2048 <= x) DO
      INC(preScale, 2)
    END;
    ASSERT(preScale < 255, Errors.ProgError);

    x := (x DIV (preScale * 8)) - 1;
    scr := 255;
    WHILE (scr >=0) & (scr > x) DO
      DEC(scr)
    END;
    (* set pre-scaler config reg *)
    SYSTEM.PUT(dev.CPSR, preScale);

    (* config GPIO device *)
    GPIO.SetFunction(mosiPinNo, GPIO.Fspi);
    GPIO.SetFunction(misoPinNo, GPIO.Fspi);
    GPIO.SetFunction(sclkPinNo, GPIO.Fspi)
  END Configure;


  PROCEDURE MakeRunCfg*(cfg: DeviceCfg; txShift: INTEGER; VAR cfgRun: DeviceRunCfg);
  (**
    Make a DeviceCfgRun to be used for an SPI transaction, via 'PutRunCfg'.
  **)
    VAR x: INTEGER;
  BEGIN
    ASSERT((cfg.scr >= 0) & (cfg.scr <= 255), Errors.PreCond);
    ASSERT(cfg.cpha IN {0, 1}, Errors.PreCond);
    ASSERT(cfg.cpol IN {0, 1}, Errors.PreCond);
    ASSERT(cfg.dataSize IN {DSS_val_8, DSS_val_16}, Errors.PreCond);

    x := cfg.dataSize;
    x := x + LSL(FRF_val_SPI, CR0_FRF0); (* fixed to Motorola SPI *)
    x := x + LSL(cfg.cpol, CR0_SPO);
    x := x + LSL(cfg.cpha, CR0_SPH);
    x := x + LSL(cfg.scr, CR0_SCR0);
    cfgRun.regValue := x;
    cfgRun.txShift := txShift
  END MakeRunCfg;


  PROCEDURE PutRunCfg*(dev: Device; cfgRun: DeviceRunCfg);
  (**
    Set a DeviceCfgRun for the following SPI transfer/receive
    transaction (or series of transactions).
  **)
  BEGIN
    SYSTEM.PUT(dev.CR1 + MCU.ACLR, {CR1_SSE});
    SYSTEM.PUT(dev.CR0, cfgRun.regValue);
    dev.txShift := cfgRun.txShift;
    SYSTEM.PUT(dev.CR1 + MCU.ASET, {CR1_SSE})
  END PutRunCfg;


  PROCEDURE GetSclkRateRange*(dev: Device; VAR lowRate, highRate: INTEGER);
  (**
    The possible serial clock rate range as configured by 'Configure'.
  **)
    VAR cpsr, scr: INTEGER;
  BEGIN
    SYSTEM.GET(dev.CPSR, cpsr);
    SYSTEM.GET(dev.CR0, scr);
    scr := LSR(scr, CR0_SCR0);
    highRate := MCU.PeriClkFreq DIV cpsr;
    lowRate := highRate DIV 256
  END GetSclkRateRange;


  PROCEDURE SclkRate*(dev: Device): INTEGER;
  (**
    The current serial clock rate.
    Only useful after 'PutRunCfg' has been issued.
  **)
    VAR cpsr, scr: INTEGER;
  BEGIN
    SYSTEM.GET(dev.CPSR, cpsr);
    SYSTEM.GET(dev.CR0, scr);
    scr := LSR(scr, CR0_SCR0)
    RETURN MCU.PeriClkFreq DIV (cpsr * (1 + scr))
  END SclkRate;


  PROCEDURE SCRvalue*(dev: Device; sclkRate: INTEGER): INTEGER;
  (**
    The SCR value for ConfigDev for 'sclkRate' as configured with 'Configure'.
    Use to prepare an SCR value for 'DeviceCfg' for different 'sclkRate' than used for 'Configure'.
  **)
    VAR cpsr, scr, x: INTEGER;
  BEGIN
    SYSTEM.GET(dev.CPSR, cpsr);
    x := (MCU.PeriClkFreq * 8) DIV sclkRate;
    x := (x DIV (cpsr * 8)) - 1;
    scr := 255;
    WHILE (scr >=0) & (scr > x) DO
      DEC(scr)
    END
    RETURN scr
  END SCRvalue;


  PROCEDURE GetBaseCfg*(VAR cfg: DeviceCfg);
  (**
    sclkFreq  = 255,        hardware reset override, lowest configured serial clock rate
    cpha      = 0,          hardware reset value
    cpol      = 0,          hardware reset value
    (* frameFormat = fixed to Motorola SPI *)
    dataSize  = DSS_val_8,  hardware reset override
    --
    See ASSERTs in 'MakeRunCfg' for valid values.
  **)
  BEGIN
    CLEAR(cfg);
    cfg.scr := 255;
    cfg.dataSize := DSS_val_8
  END GetBaseCfg;


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
