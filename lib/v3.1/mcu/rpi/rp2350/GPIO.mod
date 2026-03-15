MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  General Purpose IO (GPIO)
  --
  Type: MCU
  --
  MCU:
    RP2350A (30 GPIO: 0 .. 29)
    RP2350B (48 GPIO: 0 .. 47)
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, RST, Errors;

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
    GPIO_OVER_OE_1  = 15;  (* [15:14] *)
    GPIO_OVER_OE_0  = 14;
    GPIO_OVER_OUT_1 = 13;  (* [13:12] *)
    GPIO_OVER_OUT_0 = 12;

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

    (* GPIO IRQ trigger event bits *)
    IRQ_LVL_LOW*   = 0;
    IRQ_LVL_HIGH*  = 1;
    IRQ_EDGE_FALL* = 2;
    IRQ_EDGE_RISE* = 3;

    (* int event control and status *)
    PinsPerReg = 8;   (* pins per control register for int events *)
    RegOffset = 4;    (* control register offset *)
    EventBits = 4;    (* width of event field *)
    EventMask = 0FH;  (* mask corresponding to event field width *)

    (* --- pads --- *)

    (* PADS config bits and values, both banks *)
    PADS_ISO*         = 8;
    PADS_OD*          = 7;
    PADS_IE*          = 6;
    PADS_DRIVE_1*     = 5;  (* [5:4], drive strength *)
    PADS_DRIVE_0*     = 4;
      DRIVE_val_2mA*  = 0;
      DRIVE_val_4mA*  = 1;
      DRIVE_val_8mA*  = 2;
      DRIVE_val_12mA* = 3;
    PADS_PUE*         = 3;
    PADS_PDE*         = 2;
    PADS_SCHMITT*     = 1;
    PADS_SLEWFAST*    = 0;
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
    Fhstx*    = MCU.IO_BANK0_Fhstx;
    Fspi*     = MCU.IO_BANK0_Fspi;
    Fuart*    = MCU.IO_BANK0_Fuart;
    Fi2c*     = MCU.IO_BANK0_Fi2c;
    Fpwm*     = MCU.IO_BANK0_Fpwm;
    Fsio*     = MCU.IO_BANK0_Fsio;
    Fpio0*    = MCU.IO_BANK0_Fpio0;
    Fpio1*    = MCU.IO_BANK0_Fpio1;
    Fpio2*    = MCU.IO_BANK0_Fpio2;
    Fqmi*     = MCU.IO_BANK0_Fqmi;
    Ftrc*     = MCU.IO_BANK0_Ftrc;
    Fclk*     = MCU.IO_BANK0_Fclk;
    Fusb*     = MCU.IO_BANK0_Fusb;
    FuartAlt* = MCU.IO_BANK0_FuartAlt;
    Fnull*    = MCU.IO_BANK0_Fnull;     (* reset state *)

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

  PROCEDURE* SetFunction*(pin, functionNo: INTEGER);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(functionNo IN Functions, Errors. PreCond);
    addr := MCU.IO_BANK0_GPIO0_CTRL + (pin * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, functionNo);
    SYSTEM.PUT(addr, x);
    (* remove pad isolation *)
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_ISO})
  END SetFunction;


  PROCEDURE* ClearPadIso*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_ISO})
  END ClearPadIso;


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

  PROCEDURE* ConfigurePad*(pin: INTEGER; cfg: PadCfg);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(cfg.outputDe IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.inputEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.driveStrength IN DriveRange, Errors.PreCond);
    ASSERT(cfg.pullupEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.pulldownEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.schmittTrigEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.slewRate IN SlewRange, Errors.PreCond);

    addr := MCU.PADS_BANK0_GPIO0 + (pin * MCU.PADS_BANK0_GPIO_Offset);
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
    inputEn         = Disabled,           hardware reset value
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

  PROCEDURE* ConnectOutput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END ConnectOutput;


  PROCEDURE* DisconnectOutput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END DisconnectOutput;


  PROCEDURE* ConnectInput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END ConnectInput;


  PROCEDURE* DisconnectInput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END DisconnectInput;


  (* --- GPIO devices and pads --- *)

  PROCEDURE ResetPin*(pin: INTEGER);
    VAR padCfg: PadCfg;
  BEGIN
    SetFunction(pin, MCU.IO_BANK0_Fnull);
    GetPadBaseCfg(padCfg);
    ConfigurePad(pin, padCfg)
  END ResetPin;


  (* --- GPIO interrupts --- *)

  PROCEDURE* GetIntSummary*(VAR statusL, statusH: SET);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    IF cid = 0 THEN
      SYSTEM.GET(MCU.IO_BANK0_IRQSUM_PROC0_SEC0, statusL);
      SYSTEM.GET(MCU.IO_BANK0_IRQSUM_PROC0_SEC1, statusH)
    ELSE
      SYSTEM.GET(MCU.IO_BANK0_IRQSUM_PROC1_SEC0, statusL);
      SYSTEM.GET(MCU.IO_BANK0_IRQSUM_PROC1_SEC1, statusH)
    END
  END GetIntSummary;


  PROCEDURE* SetIntEvents*(pin: INTEGER; events: SET);
    VAR cid, addr, shift: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    events := events * BITS(EventMask);
    IF cid = 0 THEN
      addr := MCU.IO_BANK0_PROC0_INTE0
    ELSE
      addr := MCU.IO_BANK0_PROC1_INTE0
    END;
    addr := addr + ((pin DIV PinsPerReg) * RegOffset);
    shift := (pin MOD PinsPerReg) * EventBits;
    SYSTEM.PUT(addr + MCU.ACLR, LSL(EventMask, shift));
    SYSTEM.PUT(addr + MCU.ASET, LSL(ORD(events), shift))
  END SetIntEvents;


  PROCEDURE* GetIntEvents*(pin: INTEGER; VAR events: SET);
    VAR cid, addr, val, shift: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    IF cid = 0 THEN
      addr := MCU.IO_BANK0_PROC0_INTS0
    ELSE
      addr := MCU.IO_BANK0_PROC1_INTS0
    END;
    addr := addr + ((pin DIV PinsPerReg) * RegOffset);
    shift := (pin MOD PinsPerReg) * EventBits;
    SYSTEM.GET(addr, val);
    val := LSR(val, shift);
    events := BITS(val) * BITS(EventMask)
  END GetIntEvents;


  PROCEDURE* ClearAllIntEvents*(pin: INTEGER);
  (* can only clear the edge detection events, obviously *)
    CONST ClearMask = 0CH;
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_INTR0 + ((pin DIV PinsPerReg) * RegOffset);
    SYSTEM.PUT(addr, LSL(ClearMask, (pin MOD PinsPerReg) * EventBits))
  END ClearAllIntEvents;


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

  PROCEDURE* SetH*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_SET, pinMask)
  END SetH;


  PROCEDURE* Clear*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OUT_CLR_Offset, pinMask)
  END Clear;

  PROCEDURE* ClearL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, pinMask)
  END ClearL;

  PROCEDURE* ClearH*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_CLR, pinMask)
  END ClearH;


  PROCEDURE* Toggle*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OUT_XOR_Offset, pinMask)
  END Toggle;

  PROCEDURE* ToggleL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, pinMask)
  END ToggleL;

  PROCEDURE* ToggleH*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_XOR, pinMask)
  END ToggleH;


  PROCEDURE* Get*(gpio: INTEGER; VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(gpio, pinVal)
  END Get;

  PROCEDURE* GetL*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, pinVal)
  END GetL;

  PROCEDURE* GetH*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_IN, pinVal)
  END GetH;


  PROCEDURE* Put*(gpio: INTEGER; pinVal: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OUT_Offset, pinVal)
  END Put;

  PROCEDURE* PutL*(pinVal: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT, pinVal)
  END PutL;

  PROCEDURE* PutH*(pinValH: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT, pinValH)
  END PutH;

  PROCEDURE* PutPin*(pin: INTEGER; setPin: BOOLEAN);
    VAR addr: INTEGER;
  BEGIN
    IF pin < 32 THEN
      IF setPin THEN
        addr := MCU.SIO_GPIO_OUT_SET
      ELSE
        addr := MCU.SIO_GPIO_OUT_CLR
      END
    ELSE
      pin := pin - 32;
      IF setPin THEN
        addr := MCU.SIO_GPIO_HI_OUT_SET
      ELSE
        addr := MCU.SIO_GPIO_HI_OUT_CLR
      END
    END;
    SYSTEM.PUT(addr, {pin})
  END PutPin;


  PROCEDURE* Check*(gpio: INTEGER; pinMask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(gpio, value);
    RETURN value * pinMask # {}
  END Check;

  PROCEDURE* CheckL*(pinMask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value);
    RETURN value * pinMask # {}
  END CheckL;

  PROCEDURE* CheckH*(pinMask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_IN, value);
    RETURN value * pinMask # {}
  END CheckH;


  PROCEDURE* EnableOutput*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OE_SET_Offset, pinMask)
  END EnableOutput;

  PROCEDURE* EnableOutputL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, pinMask)
  END EnableOutputL;

  PROCEDURE* EnableOutputH*(pinMaskH: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_SET, pinMaskH)
  END EnableOutputH;

  (* disabling output sets pin to hi-z (tri-state) *)

  PROCEDURE* DisableOutput*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.SIO_GPIO_OE_CLR_Offset, pinMask)
  END DisableOutput;

  PROCEDURE* DisableOutputL*(pinMask: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_CLR, pinMask)
  END DisableOutputL;

  PROCEDURE* DisableOutputH*(pinMaskH: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_CLR, pinMaskH)
  END DisableOutputH;


  PROCEDURE* GetEnabledOutput*(gpio: INTEGER; VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(gpio + MCU.SIO_GPIO_OE_Offset, pinVal)
  END GetEnabledOutput;

  PROCEDURE* GetEnabledOutputL*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OE, pinVal)
  END GetEnabledOutputL;

  PROCEDURE* GetEnabledOutputH*(VAR pinValH: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_OE, pinValH)
  END GetEnabledOutputH;


  PROCEDURE init;
  BEGIN
    RST.ReleaseResets({MCU.RESETS_IO_BANK0, MCU.RESETS_PADS_BANK0})
  END init;

BEGIN
  init
END GPIO.
