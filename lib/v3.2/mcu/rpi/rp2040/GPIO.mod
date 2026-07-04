MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  General Purpose IO (GPIO)
  --
  MCU: RP2040
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, DEV := GPIO_DEV, RST, Errors;

  CONST
    (* generic values *)
    Enabled* = 1;
    Disabled* = 0;

    (* PADS drive and slew rate *)
    DRIVE_val_2mA*  = 0;
    DRIVE_val_4mA*  = 1;
    DRIVE_val_8mA*  = 2;
    DRIVE_val_12mA* = 3;
    SLEWFAST_val_slow* = 0;
    SLEWFAST_val_fast* = 1;

    (* value aliases *)
    Drive2mA*  = DRIVE_val_2mA;
    Drive4mA*  = DRIVE_val_4mA;  (* reset *)
    Drive8mA*  = DRIVE_val_8mA;
    Drive12mA* = DRIVE_val_12mA;
    SlewSlow*  = SLEWFAST_val_slow;  (* reset *)
    SlewFast*  = SLEWFAST_val_fast;

    (* IO functions *)
    Fspi*   = DEV.IO_BANK0_Fspi;
    Fuart*  = DEV.IO_BANK0_Fuart;
    Fi2c*   = DEV.IO_BANK0_Fi2c;
    Fpwn*   = DEV.IO_BANK0_Fpwm;
    Fsio*   = DEV.IO_BANK0_Fsio;
    Fpio0*  = DEV.IO_BANK0_Fpio0;
    Fpio1*  = DEV.IO_BANK0_Fpio1;
    Fclk*   = DEV.IO_BANK0_Fclk;
    Fusb*   = DEV.IO_BANK0_Fusb;
    Fnull*  = DEV.IO_BANK0_Fnull;

    Functions* = DEV.IO_BANK0_Functions;

    (* --- GPIO devices --- *)

    (* GPIO_CTRL overrides *)
    GPIO_OVER_IRQ_1 = 29;  (* [29:28] *)
    GPIO_OVER_IRQ_0 = 28;
    GPIO_OVER_IN_1  = 17;  (* [17:16] *)
    GPIO_OVER_IN_0  = 16;
    GPIO_OVER_OE_1  = 13;  (* [13:12] *)
    GPIO_OVER_OE_0  = 12;
    GPIO_OVER_OUT_1 = 9;   (* [9:8] *)
    GPIO_OVER_OUT_0 = 8;

    (* values for all overrides *)
    GPIO_OVER_val_direct* = 0;  (* direct, don't invert *)
    GPIO_OVER_val_inv*    = 1;  (* invert *)
    GPIO_OVER_val_low*    = 2;  (* drive low *)
    GPIO_OVER_val_high*   = 3;  (* drive high *)

    (* value aliases *)
    OverOff*  = GPIO_OVER_val_direct;
    OverInv*  = GPIO_OVER_val_inv;
    OverLow*  = GPIO_OVER_val_low;
    OverHigh* = GPIO_OVER_val_high;

    (* BANK0_GPIO bits and values *)
    PADS_OD*            = 7;
    PADS_IE*            = 6;
    PADS_DRIVE_1*       = 5;  (* [5:4], drive strength *)
    PADS_DRIVE_0*       = 4;
    PADS_PUE*           = 3;
    PADS_PDE*           = 2;
    PADS_SCHMITT*       = 1;
    PADS_SLEWFAST*      = 0;

    (* value ranges *)
    DriveRange = {DRIVE_val_2mA .. DRIVE_val_12mA};
    SlewRange = {SLEWFAST_val_slow, SLEWFAST_val_fast};


  TYPE
    PinCfg* = RECORD (* see ASSERTs in 'ConfigurePin' for valid values *)
      outputDe*: INTEGER;       (* reset: Disabled, ie. output enabled *)
      inputEn*: INTEGER;        (* reset: Enabled (RP2040), Disabled (RP2350) *)
      driveStrength*: INTEGER;  (* reset: Drive4mA *)
      pullupEn*: INTEGER;       (* reset: Disabled *)
      pulldownEn*: INTEGER;     (* reset: Enabled *)
      schmittTrigEn*: INTEGER;  (* reset: Enabled *)
      slewRate*: INTEGER        (* reset: SlewSlow *)
    END;


  PROCEDURE Attach*;
  BEGIN
    RST.ReleaseReset(DEV.PADS_BANK0_RST_reg, DEV.PADS_BANK0_RST_pos);
    RST.ReleaseReset(DEV.IO_BANK0_RST_reg, DEV.IO_BANK0_RST_pos)
  END Attach;


  PROCEDURE* SetFunction*(pinNo, functionNo: INTEGER);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(functionNo IN Functions, Errors. PreCond);
    addr := DEV.IO_BANK0_GPIO0_CTRL + (pinNo * DEV.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, functionNo);
    SYSTEM.PUT(addr, x)
  END SetFunction;


  PROCEDURE* SetOverrides*(pin, irqOver, inOver, oeOver, outOver: INTEGER);
    VAR addr, val: INTEGER;
  BEGIN
    addr := DEV.IO_BANK0_GPIO0_CTRL + (pin * DEV.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, val);
    BFI(val, GPIO_OVER_IRQ_1, GPIO_OVER_IRQ_0, irqOver);
    BFI(val, GPIO_OVER_IN_1, GPIO_OVER_IN_0, inOver);
    BFI(val, GPIO_OVER_OE_1, GPIO_OVER_OE_0, oeOver);
    BFI(val, GPIO_OVER_OUT_1, GPIO_OVER_OUT_0, outOver);
    SYSTEM.PUT(addr, val)
  END SetOverrides;


  PROCEDURE ConfigurePin*(pinNo: INTEGER; cfg: PinCfg);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(cfg.outputDe IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.inputEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.driveStrength IN DriveRange, Errors.PreCond);
    ASSERT(cfg.pullupEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.pulldownEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.schmittTrigEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.slewRate IN SlewRange, Errors.PreCond);

    addr := DEV.PADS_BANK0_GPIO0 + (pinNo * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, PADS_SLEWFAST, cfg.slewRate);
    BFI(x, PADS_SCHMITT, cfg.schmittTrigEn);
    BFI(x, PADS_PDE, cfg.pulldownEn);
    BFI(x, PADS_PUE, cfg.pullupEn);
    BFI(x, PADS_DRIVE_1, PADS_DRIVE_0, cfg.driveStrength);
    BFI(x, PADS_IE, cfg.inputEn);
    BFI(x, PADS_OD, cfg.outputDe);
    SYSTEM.PUT(addr, x)
  END ConfigurePin;


  PROCEDURE* GetPinBaseCfg*(VAR cfg: PinCfg);
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
  END GetPinBaseCfg;


  (* the connect/disconnect procedures operate on the pad *)

  PROCEDURE* ConnectOutput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ACLR + (pinNo * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END ConnectOutput;


  PROCEDURE* DisconnectOutput*(pinNo: INTEGER);
  (** set hi-z **)
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ASET + (pinNo * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END DisconnectOutput;


  PROCEDURE* ConnectInput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ASET + (pinNo * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END ConnectInput;


  PROCEDURE* DisconnectInput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ACLR + (pinNo * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END DisconnectInput;

  (* GPIO devices and pads --- *)

  PROCEDURE ResetPin*(pinNo: INTEGER);
    VAR pinCfg: PinCfg;
  BEGIN
    SetFunction(pinNo, Fnull);
    GetPinBaseCfg(pinCfg);
    ConfigurePin(pinNo, pinCfg)
  END ResetPin;

END GPIO.
