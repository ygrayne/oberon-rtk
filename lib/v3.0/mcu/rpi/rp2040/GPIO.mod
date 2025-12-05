MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.0
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

    (* -- pads -- *)

    (* BANK0_GPIO bits and values *)
    PADS_OD*            = 7;
    PADS_IE*            = 6;
    PADS_DRIVE_1*       = 5;  (* [5:4], drive strength *)
    PADS_DRIVE_0*       = 4;
      DRIVE_val_2mA*  = 0;
      DRIVE_val_4mA*  = 1;
      DRIVE_val_8mA*  = 2;
      DRIVE_val_12mA* = 3;
    PADS_PUE*           = 3;
    PADS_PDE*           = 2;
    PADS_SCHMITT*       = 1;
    PADS_SLEWFAST*      = 0;
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


    (* IO functions *)
    Fspi*   = MCU.IO_BANK0_Fspi;
    Fuart*  = MCU.IO_BANK0_Fuart;
    Fi2c*   = MCU.IO_BANK0_Fi2c;
    Fpwn*   = MCU.IO_BANK0_Fpwm;
    Fsio*   = MCU.IO_BANK0_Fsio;
    Fpio0*  = MCU.IO_BANK0_Fpio0;
    Fpio1*  = MCU.IO_BANK0_Fpio1;
    Fclk*   = MCU.IO_BANK0_Fclk;
    Fusb*   = MCU.IO_BANK0_Fusb;
    Fnull*  = MCU.IO_BANK0_Fnull;

    Functions* = MCU.IO_BANK0_Functions;


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


  PROCEDURE* SetOverrides*(pin, irqOver, inOver, oeOver, outOver: INTEGER);
    VAR addr, val: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_GPIO0_CTRL + (pin * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, val);
    BFI(val, GPIO_OVER_IRQ_1, GPIO_OVER_IRQ_0, irqOver);
    BFI(val, GPIO_OVER_IN_1, GPIO_OVER_IN_0, inOver);
    BFI(val, GPIO_OVER_OE_1, GPIO_OVER_OE_0, oeOver);
    BFI(val, GPIO_OVER_OUT_1, GPIO_OVER_OUT_0, outOver);
    SYSTEM.PUT(addr, val)
  END SetOverrides;


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
    BFI(x, PADS_SLEWFAST, cfg.slewRate);
    BFI(x, PADS_SCHMITT, cfg.schmittTrigEn);
    BFI(x, PADS_PDE, cfg.pulldownEn);
    BFI(x, PADS_PUE, cfg.pullupEn);
    BFI(x, PADS_DRIVE_1, PADS_DRIVE_0, cfg.driveStrength);
    BFI(x, PADS_IE, cfg.inputEn);
    BFI(x, PADS_OD, cfg.outputDe);
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


  (* the connect/disconnect procedures operate on the pad *)

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


  PROCEDURE* ConnectInput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END ConnectInput;


  PROCEDURE* DisconnectInput*(pinNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END DisconnectInput;

  (* GPIO devices and pads --- *)

  PROCEDURE ResetPin*(pinNo: INTEGER);
    VAR padCfg: PadCfg;
  BEGIN
    SetFunction(pinNo, MCU.IO_BANK0_Fnull);
    GetPadBaseCfg(padCfg);
    ConfigurePad(pinNo, padCfg)
  END ResetPin;


  (* GPIO control via SIO *)
  (* GPIO function 'Fsio' *)
  (* parameter 'gpio': MCU.GPIOx *)

  PROCEDURE* Set*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OUT_SET_Offset, pinMask)
  END Set;

  PROCEDURE* SetL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, pinMask)
  END SetL;


  PROCEDURE* Clear*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OUT_CLR_Offset, pinMask)
  END Clear;

  PROCEDURE* ClearL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, pinMask)
  END ClearL;


  PROCEDURE* Toggle*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OUT_XOR_Offset, pinMask)
  END Toggle;

  PROCEDURE* ToggleL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, pinMask)
  END ToggleL;


  PROCEDURE* Get*(gpio: INTEGER; VAR pinVal: SET);
  BEGIN
    IF gpio = MCU.GPIO0 THEN
      SYSTEM.GET(MCU.SIO_GPIO_IN, pinVal)
    ELSIF gpio = MCU.GPIO1 THEN
      SYSTEM.GET(MCU.SIO_GPIO_HI_IN, pinVal)
    END
  END Get;

  PROCEDURE* GetL*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, pinVal)
  END GetL;


  PROCEDURE* Put*(gpio: INTEGER; pinVal: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OUT_Offset, pinVal)
  END Put;

  PROCEDURE* PutL*(value: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT, value)
  END PutL;


  PROCEDURE* Check*(gpio: INTEGER; pinMask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    IF gpio = MCU.GPIO0 THEN
      SYSTEM.GET(MCU.SIO_GPIO_IN, value)
    ELSIF gpio = MCU.GPIO1 THEN
      SYSTEM.GET(MCU.SIO_GPIO_HI_IN, value)
    END;
    RETURN value * pinMask # {}
  END Check;

  PROCEDURE* CheckL*(pinMask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value);
    RETURN value * pinMask # {}
  END CheckL;


  PROCEDURE* EnableOutput*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OE_SET_Offset, pinMask)
  END EnableOutput;

  PROCEDURE* EnableOutputL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, pinMask)
  END EnableOutputL;


  (* disabling output sets pin to hi-z (tri-state) *)

  PROCEDURE* DisableOutput*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OE_CLR_Offset, pinMask)
  END DisableOutput;

  PROCEDURE* DisableOutputL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_CLR, pinMask)
  END DisableOutputL;


  PROCEDURE* GetEnabledOutput*(gpio: INTEGER; VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(gpio + MCU.SIO_GPIO_OE_Offset, pinVal)
  END GetEnabledOutput;

  PROCEDURE* GetEnabledOutputL*(VAR value: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OE, value)
  END GetEnabledOutputL;


  PROCEDURE init;
    VAR i: INTEGER;
  BEGIN
    StartUp.ReleaseResets({MCU.RESETS_IO_BANK0, MCU.RESETS_PADS_BANK0});
    (* for RP2350 compatibility *)
    i := 0;
    WHILE i < MCU.NumGPIO DO
      DisconnectInput(i);
      INC(i)
    END
  END init;

BEGIN
  init
END GPIO.
