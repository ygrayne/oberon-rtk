MODULE GPIO;
(**
  Oberon RTK Framework
  --
  General Purpose IO (GPIO)
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  Datasheet:
  * 2.19.6.1, p243 (GPIO)
  * 2.19.6.3, p298 (banks and pads)
  * 2.3.1.17, p42 (SIO)
  --
  Pin mumbers 0 .. 29, on "lo bank" (IO_BANK0)
  The "hi bank" for QPSI is not handled here.
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, StartUp, Errors;

  CONST
    (* generic values *)
    Enabled* = 1;
    Disabled* = 0;



    (* BANK0_GPIO bits and values *)
    BANK0_GPIO_OD*          = 7;
    BANK0_GPIO_IE*          = 6;
    BANK0_GPIO_DRIVE1*      = 5; (* [5:4], drive stringth *)
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

    (* value aliases *)
    Drive2mA*  = DRIVE_val_2mA;
    Drive4mA*  = DRIVE_val_4mA;  (* reset *)
    Drive8mA*  = DRIVE_val_8mA;
    Drive12mA* = DRIVE_val_12mA;
    SlewSlow*  = SLEWFAST_val_slow;  (* reset *)
    SlewFast*  = SLEWFAST_val_fast;

    OD = 7; (* output disable *)
    IE = 6; (* input enable *)

    (* GPIO functions *)
    F1* = 1;   F2* = 2;   F3* = 3;   F4* = 4;
    F5* = 5;   F6* = 6;   F7* = 7;   F8* = 8;   F9* = 9;

    Fspi* = F1;
    Fuart* = F2;
    Fi2c* = F3;
    Fpwm* = F4;
    Fsio* = F5;
    Fpio0* = F6;
    Fpio1* = F7;
    Fclk* = F8;
    Fusb* = F9;


  TYPE
    PadCfg* = RECORD (* see ASSERTs in 'ConfigurePad' for valid values *)
      outputDe*: INTEGER;       (* reset: Disabled *)
      inputEn*: INTEGER;        (* reset: Enabled *)
      driveStrength*: INTEGER;  (* reset: Drive4mA *)
      pullupEn*: INTEGER;       (* reset: Disabled *)
      pulldownEn*: INTEGER;     (* reset: Enabled *)
      schmittTrigEn*: INTEGER;  (* reset: Enabled *)
      slewRate*: INTEGER        (* reset: SlewSlow *)
    END;

  (* --- GPIO device --- *)

  PROCEDURE SetFunction*(pinNo, functionNo: INTEGER);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(functionNo IN {F1 .. F9}, Errors. PreCond);
    addr := MCU.IO_BANK0_GPIO_CTRL + (pinNo * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, functionNo);
    SYSTEM.PUT(addr, x)
  END SetFunction;

  PROCEDURE SetInverters*(pinNo: INTEGER; mask: SET);
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_GPIO_CTRL + (pinNo * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 31, 5, ORD(mask));
    SYSTEM.PUT(addr, x)
  END SetInverters;

  (* define interrupts functions here *)
  (* ... *)

  (* --- pads --- *)

  PROCEDURE ConfigurePad*(pinNo: INTEGER; cfg: PadCfg);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(cfg.outputDe IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.inputEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.driveStrength IN {DRIVE_val_2mA .. DRIVE_val_12mA}, Errors.PreCond);
    ASSERT(cfg.pullupEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.pulldownEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.schmittTrigEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.slewRate IN {SLEWFAST_val_slow, SLEWFAST_val_fast}, Errors.PreCond);

    addr := MCU.PADS_BANK0_GPIO + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    x := cfg.slewRate;
    x := x + LSL(cfg.schmittTrigEn, BANK0_GPIO_SCHMITT);
    x := x + LSL(cfg.pulldownEn, BANK0_GPIO_PDE);
    x := x + LSL(cfg.pullupEn, BANK0_GPIO_PUE);
    x := x + LSL(cfg.driveStrength, BANK0_GPIO_DRIVE0);
    x := x + LSL(cfg.inputEn, BANK0_GPIO_IE);
    x := x + LSL(cfg.outputDe, BANK0_GPIO_OD);
    SYSTEM.PUT(addr, x)
  END ConfigurePad;


  PROCEDURE GetPadBaseCfg*(VAR cfg: PadCfg);
  (**
    outputDe        = Disabled,           hardware reset value, ie. output is enabled
    inputEn         = Enabled,            hardware reset value
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
    cfg.inputEn := Enabled;
    cfg.driveStrength := DRIVE_val_4mA;
    cfg.pulldownEn := Enabled;
    cfg.schmittTrigEn := Enabled
  END GetPadBaseCfg;


  PROCEDURE DisableOutput*(pinNo: INTEGER);
  (* reset: output enabled *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO + MCU.ASET + (pinNo * MCU.PADS_BANK0_GPIO_Offset); (* set DISABLE bit *)
    SYSTEM.PUT(addr, {OD})
  END DisableOutput;


  PROCEDURE DisableInput*(pinNo: INTEGER);
  (* reset: enabled *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO + MCU.ACLR + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {IE})
  END DisableInput;


  (* GPIO control via SIO *)
  (* Need to select function 'Fsio' *)

  PROCEDURE Set*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, mask)
  END Set;

  PROCEDURE Clear*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, mask)
  END Clear;

  PROCEDURE Toggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, mask)
  END Toggle;

  PROCEDURE Get*(VAR value: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value)
  END Get;

  PROCEDURE Put*(value: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT, value)
  END Put;

  PROCEDURE GetBack*(VAR value: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OUT, value)
  END GetBack;

  PROCEDURE Check*(mask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value);
    RETURN value * mask # {}
  END Check;

  PROCEDURE OutputEnable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, mask)
  END OutputEnable;

  PROCEDURE OutputDisable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_CLR, mask)
  END OutputDisable;

  PROCEDURE OutputEnToggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_XOR, mask)
  END OutputEnToggle;

  PROCEDURE GetOutputEnable*(VAR value: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OE, value)
  END GetOutputEnable;

  PROCEDURE init;
  BEGIN
    StartUp.ReleaseReset(MCU.RESETS_IO_BANK0);
    StartUp.AwaitReleaseDone(MCU.RESETS_IO_BANK0);
    StartUp.ReleaseReset(MCU.RESETS_PADS_BANK0);
    StartUp.AwaitReleaseDone(MCU.RESETS_PADS_BANK0)
  END init;

BEGIN
  init
END GPIO.
