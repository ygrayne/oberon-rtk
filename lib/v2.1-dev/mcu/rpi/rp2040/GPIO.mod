MODULE GPIO;
(**
  Oberon RTK Framework v2.1
  --
  General Purpose IO (GPIO)
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, StartUp, Errors;

  CONST
    (* generic values *)
    Enabled* = 1;
    Disabled* = 0;

    (* pad output *)
    OutputHiZ* = 1; (* pad output = disabled *)
    OutputConn* = 0;


    (* BANK0_GPIO bits and values *)
    BANK0_GPIO_OD*          = 7;
    BANK0_GPIO_IE*          = 6;
    BANK0_GPIO_DRIVE1*      = 5; (* [5:4], drive strength *)
    BANK0_GPIO_DRIVE0*      = 4;
      DRIVE_val_2mA*  = 0;
      DRIVE_val_4mA*  = 1;  (* reset *)
      DRIVE_val_8mA*  = 2;
      DRIVE_val_12mA* = 3;
    BANK0_GPIO_PUE*         = 3;
    BANK0_GPIO_PDE*         = 2;
    BANK0_GPIO_SCHMITT*     = 1;
    BANK0_GPIO_SLEWFAST*    = 0;
      SLEWFAST_val_slow* = 0;
      SLEWFAST_val_fast* = 1;

    (* value ranges *)
    DriveRange = {DRIVE_val_2mA .. DRIVE_val_12mA};
    SlewRange = {SLEWFAST_val_slow, SLEWFAST_val_fast};

    (* value aliases *)
    Drive2mA*  = DRIVE_val_2mA;
    Drive4mA*  = DRIVE_val_4mA;  (* reset *)
    Drive8mA*  = DRIVE_val_8mA;
    Drive12mA* = DRIVE_val_12mA;
    SlewSlow*  = SLEWFAST_val_slow;  (* reset *)
    SlewFast*  = SLEWFAST_val_fast;

    (* PADS_BANK0_GPIOx BITS *)
    PADS_OD   = 7;  (* output disable *)
    PADS_IE   = 6;  (* input enable *)

    (* GPIO inverters *)
    InvOff* = 0;
    InvOn* = 1;
    InvLow* = 2;
    InvHigh* = 3;

  TYPE
    PadCfg* = RECORD (* see ASSERTs in 'ConfigurePad' for valid values *)
      outputDe*: INTEGER;       (* reset: Disabled, ie. output enabled *)
      inputEn*: INTEGER;        (* reset: Enabled (RP2040), Disabled (RP2350) *)
      driveStrength*: INTEGER;  (* reset: Drive4mA *)
      pullupEn*: INTEGER;       (* reset: Disabled *)
      pulldownEn*: INTEGER;     (* reset: Enabled *)
      schmittTrigEn*: INTEGER;  (* reset: Enabled *)
      slewRate*: INTEGER        (* reset: SlewSlow *)
    END;

  (* --- GPIO devices --- *)

  PROCEDURE* SetFunction*(pinNo, functionNo: INTEGER);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(functionNo IN MCU.IO_BANK0_Functions, Errors. PreCond);
    addr := MCU.IO_BANK0_GPIO0_CTRL + (pinNo * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, functionNo);
    SYSTEM.PUT(addr, x)
  END SetFunction;


  PROCEDURE* SetInverters*(pinNo: INTEGER; irqInv, inInv, oeInv, outInv: INTEGER);
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_GPIO0_CTRL + (pinNo * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 29, 28, irqInv);
    BFI(x, 17, 16, inInv);
    BFI(x, 13, 12, oeInv);
    BFI(x, 9, 8, outInv);
    SYSTEM.PUT(addr, x)
  END SetInverters;

  (* --- pads --- *)

  PROCEDURE* ConfigurePad*(pinNo: INTEGER; cfg: PadCfg);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(cfg.outputDe IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.inputEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.driveStrength IN DriveRange, Errors.PreCond);
    ASSERT(cfg.pullupEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.pulldownEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.schmittTrigEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.slewRate IN SlewRange, Errors.PreCond);

    addr := MCU.PADS_BANK0_GPIO0 + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    x := x + cfg.slewRate;
    x := x + LSL(cfg.schmittTrigEn, BANK0_GPIO_SCHMITT);
    x := x + LSL(cfg.pulldownEn, BANK0_GPIO_PDE);
    x := x + LSL(cfg.pullupEn, BANK0_GPIO_PUE);
    x := x + LSL(cfg.driveStrength, BANK0_GPIO_DRIVE0);
    x := x + LSL(cfg.inputEn, BANK0_GPIO_IE);
    x := x + LSL(cfg.outputDe, BANK0_GPIO_OD);
    SYSTEM.PUT(addr, x)
  END ConfigurePad;


  PROCEDURE* GetPadBaseCfg*(VAR cfg: PadCfg);
  (**
    outputDe        = Disabled,           hardware reset value, ie. output is enabled = connected
    inputEn         = Disabled,           hardware reset value changed in 'init'
    driveStrength   = DRIVE_val_4mA,      hardware reset value
    pullupEn        = Disabled,           hardware reset value
    pulldownEn      = Enabled,            hardware reset value
    schmittTrigEn   = Enabled,            hardware reset value
    slewRate        = SLEWFAST_val_slow,  hardware reset value
    --
    See ASSERTs in 'ConfigurePad' for valid values.
  **)
  BEGIN
    CLEAR(cfg);
    cfg.driveStrength := DRIVE_val_4mA;
    cfg.pulldownEn := Enabled;
    cfg.schmittTrigEn := Enabled
  END GetPadBaseCfg;


  PROCEDURE* ConnectOutput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END ConnectOutput;


  PROCEDURE* DisconnectOutput*(pinNo: INTEGER);
  (** set hi-z **)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END DisconnectOutput;


  PROCEDURE* EnableOutput*(pinNo: INTEGER); (* deprecated *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END EnableOutput;


  PROCEDURE* DisableOutput*(pinNo: INTEGER); (* deprecated *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END DisableOutput;


  PROCEDURE* EnableInput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END EnableInput;


  PROCEDURE* DisableInput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END DisableInput;


  PROCEDURE ResetPad*(pinNo: INTEGER);
    VAR padCfg: PadCfg;
  BEGIN
    SetFunction(pinNo, MCU.IO_BANK0_Fnull);
    GetPadBaseCfg(padCfg);
    ConfigurePad(pinNo, padCfg)
  END ResetPad;


  (* GPIO control via SIO *)
  (* GPIO function 'Fsio' *)

  PROCEDURE* Set*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, mask)
  END Set;

  PROCEDURE* Clear*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, mask)
  END Clear;

  PROCEDURE* Toggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, mask)
  END Toggle;

  PROCEDURE* Get*(VAR value: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value)
  END Get;

  PROCEDURE* Put*(value: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT, value)
  END Put;

  PROCEDURE* GetBack*(VAR value: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OUT, value)
  END GetBack;

  PROCEDURE* Check*(mask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value);
    RETURN value * mask # {}
  END Check;

  PROCEDURE* OutputEnable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, mask)
  END OutputEnable;

  PROCEDURE* OutputDisable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_CLR, mask)
  END OutputDisable;

  PROCEDURE* OutputEnToggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_XOR, mask)
  END OutputEnToggle;

  PROCEDURE* GetOutputEnable*(VAR value: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OE, value)
  END GetOutputEnable;


  PROCEDURE init;
    VAR i: INTEGER;
  BEGIN
    StartUp.ReleaseResets({MCU.RESETS_IO_BANK0, MCU.RESETS_PADS_BANK0});
    (* for RP2350 compatibility *)
    i := 0;
    WHILE i < MCU.NumGPIO DO
      DisableInput(i);
      INC(i)
    END
  END init;

BEGIN
  init
END GPIO.
