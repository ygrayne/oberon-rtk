MODULE SPIdev;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  SPI device (master mode, Motorola SPI only)
  * initialisation of SPI device data structure
  * configure hardware device: serial clock rate, data size, CPOL, CPHA
  * enable physical device
  * change selected SPI parameters after initial configuration
    * serial clock rate
    * txShift
    (For now, may add more as needed. )
  * utility functionality
    * loop back
  Other modules implement the actual specific IO functionality. 'SPIdata'
  implements binary data IO with busy waiting, a module 'SPIstr' could
  implement string IO, etc.
  --
  The GPIO pins and pads used must be configured by the client module or program.
  --
  The Tx and Rx FIFOs are always enabled in hardware (each 8x 16 bits).
  Only master mode is considered/implemented here.
  --
  The RPx also support TI synchronous serial and
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
  Clock polarity and phase:
  cpol cpha idle_clk clk_phase
   0    0    low      data sampled on rising edge and shifted out on the falling edge
   0    1    low      data sampled on the falling edge and shifted out on the rising edge
   1    0    high     data sampled on the falling edge and shifted out on the rising edge
   1    1    high     data sampled on the rising edge and shifted out on the falling edge
  --
  Type: MCU
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2024-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Errors, MCU := MCU2, RST, Clocks;

  CONST
    SPI0* = 0;
    SPI1* = 1;
    NumSPI = MCU.NumSPI;
    SPIs = {SPI0 .. NumSPI - 1};

    (* generic values *)
    Enabled* = 1;
    Disabled* = 0;

    (* CR0 bits and values *)
    CR0_SCR1*         = 15;   (* [15:8] serial clock frequency *)
    CR0_SCR0*         = 8;
    CR0_SPH*          = 7;    (* serial clock phase, CPHA, Motorola SPI only, reset = 0 *)
    CR0_SPO*          = 6;    (* serial clock polarity, CPOL, Motorola SPI only, reset = 0 *)
    CR0_FRF1*         = 5;    (* [5:4] frame format *)
    CR0_FRF0*         = 4;
      FRF_val_SPI* = 0;     (* Motorola SPI, reset value *)
      FRF_val_SS*  = 1;     (* TI synchronous serial *)
      FRF_val_MW*  = 2;     (* National Semiconductor Microwire *)
    CR0_DSS1*         = 3;    (* [3:0] data size select *)
    CR0_DSS0*         = 0;
      DSS_val_8*   = 7;     (* 8 bits *)
      DSS_val_16*  = 15;    (* 16 bits *)

    (* value aliases *)
    DataSize8*  =  DSS_val_8;
    DataSize16* =  DSS_val_16;

    (* CR1 bits *)
    CR1_SOD* = 3;  (* slave output disable, reset = enabled *)
    CR1_MS*  = 2;  (* master/slave select, reset = master *)
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
    (* used with 'PutRunCfg' *)
    RunCfg* = RECORD
      cr0Value: INTEGER;
      txShift: INTEGER
    END;

    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      spiNo: INTEGER;
      devNo: INTEGER;
      txShift*: INTEGER;
      CR0, CR1, CPSR, IMSC: INTEGER;
      TDR*, RDR*, SR*: INTEGER;
      sclkRateMax*, sclkRateMin*: INTEGER;
      runCfg: RunCfg
    END;

    (* "human readable" config form *)
    DeviceCfg* = RECORD
      dataSize*: INTEGER;     (* {DSS_val_8, DSS_val_16} *)
      cpha*, cpol*: INTEGER;  (* {0, 1} *)
      txShift*: INTEGER
    END;


  PROCEDURE* Init*(dev: Device; spiNo: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(spiNo IN SPIs, Errors.ProgError);
    dev.spiNo := spiNo;
    dev.devNo := MCU.RESETS_SPI0 + spiNo;
    base := MCU.SPI0_BASE + (spiNo * MCU.SPI_Offset);
    dev.CR0  := base + MCU.SPI_CR0_Offset;
    dev.CR1  := base + MCU.SPI_CR1_Offset;
    dev.CPSR := base + MCU.SPI_CPSR_Offset;
    dev.IMSC := base + MCU.SPI_IMSC_Offset;
    dev.TDR  := base + MCU.SPI_DR_Offset;
    dev.RDR  := base + MCU.SPI_DR_Offset;
    dev.SR   := base + MCU.SPI_SR_Offset
  END Init;


  PROCEDURE Configure*(dev: Device; cfg: DeviceCfg; sclkRate: INTEGER);
  (**
    If several serial clock rates are required, set 'sclkRate' to the lowest one.
    Check if highest required serial clock rate is in range of the pre-scaler.
    Don't forget to configure the SPI and CS pins and pads.
  **)
    VAR preScale, scr, x: INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    ASSERT(cfg.dataSize IN {DSS_val_8, DSS_val_16}, Errors.PreCond);
    ASSERT(cfg.cpha IN {0, 1}, Errors.PreCond);
    ASSERT(cfg.cpol IN {0, 1}, Errors.PreCond);

    (* release reset on SPI device *)
    RST.ReleaseResets({dev.devNo});

    (* disable, set master mode *)
    SYSTEM.PUT(dev.CR1, {});

    (* find/set serial clock rate *)
    (* preScale is an even integer between 2 and 254, inclusive *)
    x := (Clocks.PERICLK_FREQ * 8) DIV sclkRate;
    preScale := 2;
    WHILE (preScale < 255) & (preScale * 2048 <= x) DO
      INC(preScale, 2)
    END;
    ASSERT(preScale < 255, Errors.ProgError); (* no valid pre-scaler to get this sclkRate *)
    SYSTEM.PUT(dev.CPSR, preScale);

    (* scr is an integer between 0 and 255, inclusive *)
    x := (x DIV (preScale * 8)) - 1;
    scr := 255;
    WHILE (scr >= 0) & (scr > x) DO
      DEC(scr)
    END;

    (* set CR0 *)
    x := cfg.dataSize;
    x := x + LSL(FRF_val_SPI, CR0_FRF0); (* fixed to Motorola SPI *)
    x := x + LSL(cfg.cpol, CR0_SPO);
    x := x + LSL(cfg.cpha, CR0_SPH);
    x := x + LSL(scr, CR0_SCR0);
    SYSTEM.PUT(dev.CR0, x);

    (* record initial runCfg *)
    dev.runCfg.cr0Value := x;
    dev.runCfg.txShift := cfg.txShift;
    dev.txShift := cfg.txShift;

    (* record possible sclkRate band *)
    dev.sclkRateMax := Clocks.PERICLK_FREQ DIV preScale;
    dev.sclkRateMin := dev.sclkRateMax DIV 256;
  END Configure;


  PROCEDURE* GetBaseCfg*(VAR cfg: DeviceCfg);
  BEGIN
    CLEAR(cfg);
    cfg.dataSize := DSS_val_8;
    cfg.txShift := 0FFH
  END GetBaseCfg;

  (* dynamic config adaptations *)

  PROCEDURE* GetBaseRunCfg*(dev: Device; VAR runCfg: RunCfg);
  (**
    As set by 'Configure'.
  *)
  BEGIN
    runCfg := dev.runCfg
  END GetBaseRunCfg;


  PROCEDURE* GetCurrentRunCfg*(dev: Device; VAR runCfg: RunCfg);
  (**
    As currently set in hardware and 'dev', either by 'Configure' or 'SetRunCfg'.
    Use for save current cfg => set own cfg => operation => restore saved cfg.
  **)
  BEGIN
    SYSTEM.GET(dev.CR0, runCfg.cr0Value);
    runCfg.txShift := dev.txShift
  END GetCurrentRunCfg;


  PROCEDURE* SetSclkRate*(dev: Device; VAR runCfg: RunCfg; sclkRate: INTEGER);
    VAR cpsr, scr, x: INTEGER;
  BEGIN
    SYSTEM.GET(dev.CPSR, cpsr);
    x := (Clocks.PERICLK_FREQ * 8) DIV sclkRate;
    x := (x DIV (cpsr * 8)) - 1;
    scr := 255;
    WHILE (scr >= 0) & (scr > x) DO
      DEC(scr)
    END;
    BFI(runCfg.cr0Value, CR0_SCR1, CR0_SCR0, scr)
  END SetSclkRate;


  PROCEDURE* SetTxShift*(VAR runCfg: RunCfg; txShift: INTEGER);
  BEGIN
    runCfg.txShift := txShift
  END SetTxShift;


  PROCEDURE* PutRunCfg*(dev: Device; runCfg: RunCfg);
  BEGIN
    SYSTEM.PUT(dev.CR0, runCfg.cr0Value);
    dev.txShift := runCfg.txShift
  END PutRunCfg;

  (* enable/disable *)

  PROCEDURE* Enable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.PUT(dev.CR1 + MCU.ASET, {CR1_SSE})
  END Enable;


  PROCEDURE* Disable*(dev: Device);
  BEGIN
    ASSERT(dev # NIL, Errors.PreCond);
    SYSTEM.PUT(dev.CR1 + MCU.ACLR, {CR1_SSE})
  END Disable;


  PROCEDURE ApplyReset*(dev: Device);
  BEGIN
    SYSTEM.PUT(MCU.RESETS_RESET + MCU.ASET, {dev.devNo})
  END ApplyReset;

  (* status flags *)

  PROCEDURE* Flags*(dev: Device): SET;
    VAR flags: SET;
  BEGIN
    SYSTEM.GET(dev.SR, flags)
    RETURN flags
  END Flags;

  (* MOSI to MISO loop back *)

  PROCEDURE* EnableLoopback*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.CR1 + MCU.ASET, {CR1_LBM})
  END EnableLoopback;


  PROCEDURE* DisableLoopback*(dev: Device);
  BEGIN
    SYSTEM.PUT(dev.CR1 + MCU.ACLR, {CR1_LBM})
  END DisableLoopback;

END SPIdev.
