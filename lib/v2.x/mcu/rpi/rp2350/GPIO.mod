MODULE GPIO;
(**
  Oberon RTK Framework v2.1
  --
  General Purpose IO (GPIO)
  --
  MCU: RP2350A (30 GPIO: 0 .. 29), RP2350B (48 GPIO: 0 .. 47)
  --
  Note the deprecated procedures and definitions.
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
    GPIO_OVER_IRQ1 = 29;  (* [29:28] *)
    GPIO_OVER_IRQ0 = 28;
    GPIO_OVER_IN1  = 17;  (* [17:16] *)
    GPIO_OVER_IN0  = 16;
    GPIO_OVER_OE1  = 15;  (* [15:14] *)
    GPIO_OVER_OE0  = 14;
    GPIO_OVER_OUT1 = 13;  (* [13:12] *)
    GPIO_OVER_OUT0 = 12;

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

    (* deprecated *)
    InvOff*  = GPIO_OVER_val_direct;
    InvOn*   = GPIO_OVER_val_inv;
    InvLow*  = GPIO_OVER_val_low;
    InvHigh* = GPIO_OVER_val_high;
    (* --- *)

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

    (* pad output *)
    OutputHiZ* = 1; (* pad output = disabled *)
    OutputConn* = 0;

    (* PADS config bits and values, both banks *)
    PADS_ISO*         = 8;
    PADS_OD*          = 7;
    PADS_IE*          = 6;
    PADS_DRIVE1*      = 5;  (* [5:4], drive strength *)
    PADS_DRIVE0*      = 4;
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

    (* deprecated *)
    BANK0_GPIO_OD*          = 7;
    BANK0_GPIO_IE*          = 6;
    BANK0_GPIO_DRIVE1*      = 5;
    BANK0_GPIO_DRIVE0*      = 4;
    BANK0_GPIO_PUE*         = 3;
    BANK0_GPIO_PDE*         = 2;
    BANK0_GPIO_SCHMITT*     = 1;
    BANK0_GPIO_SLEWFAST*    = 0;
    (* --- *)

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
    ASSERT(functionNo IN MCU.IO_BANK0_Functions, Errors. PreCond);
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
    BFI(val, GPIO_OVER_IRQ1, GPIO_OVER_IRQ0, irqOver);
    BFI(val, GPIO_OVER_IN1, GPIO_OVER_IN0, inOver);
    BFI(val, GPIO_OVER_OE1, GPIO_OVER_OE0, oeOver);
    BFI(val, GPIO_OVER_OUT1, GPIO_OVER_OUT0, outOver);
    SYSTEM.PUT(addr, val)
  END SetOverrides;


  PROCEDURE SetInverters*(pin: INTEGER; irqInv, inInv, oeInv, outInv: INTEGER);
  (* deprecated *)
  BEGIN
    SetOverrides(pin, irqInv, inInv, oeInv, outInv)
  END SetInverters;


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
    BFI(x, PADS_DRIVE1, BANK0_GPIO_DRIVE0, cfg.driveStrength);
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


  PROCEDURE* ConnectOutput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END ConnectOutput;


  PROCEDURE* DisconnectOutput*(pin: INTEGER);
  (** set hi-z **)
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


  PROCEDURE* EnableOutput*(pin: INTEGER);
  (* deprecated *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END EnableOutput;

  PROCEDURE* DisableOutput*(pin: INTEGER);
  (* deprecated *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END DisableOutput;

  PROCEDURE* EnableInput*(pin: INTEGER);
  (* deprecated *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ASET + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END EnableInput;

  PROCEDURE* DisableInput*(pin: INTEGER);
  (* deprecated *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pin * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END DisableInput;


  (* --- GPIO devices and pads --- *)

  PROCEDURE ResetPin*(pin: INTEGER);
    VAR padCfg: PadCfg;
  BEGIN
    SetFunction(pin, MCU.IO_BANK0_Fnull);
    GetPadBaseCfg(padCfg);
    ConfigurePad(pin, padCfg)
  END ResetPin;


  (* --- GPIO interrupts --- *)

  PROCEDURE GetIntSummary*(VAR statusL, statusH: SET);
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


  PROCEDURE SetIntEvents*(pin: INTEGER; events: SET);
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


  PROCEDURE GetIntEvents*(pin: INTEGER; VAR events: SET);
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


  PROCEDURE ClearAllIntEvents*(pin: INTEGER);
  (* can only clear the edge detection events, obviously *)
    CONST ClearMask = 0CH;
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_INTR0 + ((pin DIV PinsPerReg) * RegOffset);
    SYSTEM.PUT(addr, LSL(ClearMask, (pin MOD PinsPerReg) * EventBits))
  END ClearAllIntEvents;


  (* GPIO control via SIO *)
  (* GPIO function 'Fsio' *)

  PROCEDURE* Set*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, mask)
  END Set;

  PROCEDURE* SetH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_SET, maskH)
  END SetH;

  PROCEDURE* Set2*(maskL, maskH: SET);
  (* deprecated, use Set and SetH *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, maskL);
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_SET, maskH)
  END Set2;

  PROCEDURE* SetPin*(pin: INTEGER);
  (* deprecated, use PutPin *)
  BEGIN
    IF pin < 32 THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {pin})
    ELSE
      SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_SET, {pin-32})
    END
  END SetPin;


  PROCEDURE* Clear*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, mask)
  END Clear;

  PROCEDURE* ClearH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_CLR, maskH)
  END ClearH;

  PROCEDURE* Clear2*(maskL, maskH: SET);
  (* depreacted, use Clear and Clear H *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, maskL);
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_CLR, maskH);
  END Clear2;

  PROCEDURE* ClearPin*(pin: INTEGER);
  (* deprecated, use PutPin *)
  BEGIN
    IF pin < 32 THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, {pin})
    ELSE
      SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_CLR, {pin-32})
    END
  END ClearPin;


  PROCEDURE* Toggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, mask)
  END Toggle;

  PROCEDURE* ToggleH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_XOR, maskH)
  END ToggleH;


  PROCEDURE* Get*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, pinVal)
  END Get;

  PROCEDURE* GetH*(VAR pinValH: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_IN, pinValH)
  END GetH;

  PROCEDURE* Get2*(VAR valueL, valueH: SET);
  (* deprecated, use Get and GetH *)
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, valueL);
    SYSTEM.GET(MCU.SIO_GPIO_HI_IN, valueH)
  END Get2;


  PROCEDURE* Put*(pinVal: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT, pinVal)
  END Put;

  PROCEDURE* PutH*(pinValH: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT, pinValH)
  END PutH;

  PROCEDURE* PutPin*(pin: INTEGER; setPin: BOOLEAN);
  (* atomic *)
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


  PROCEDURE* GetOut*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OUT, pinVal)
  END GetOut;

  PROCEDURE* GetOutH*(VAR pinValH: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_OUT, pinValH)
  END GetOutH;


  PROCEDURE* Check*(mask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value);
    RETURN value * mask # {}
  END Check;

  PROCEDURE* CheckH*(maskH: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_IN, value);
    RETURN value * maskH # {}
  END CheckH;


  PROCEDURE* OutputEnable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, mask)
  END OutputEnable;

  PROCEDURE* OutputEnableH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_SET, maskH)
  END OutputEnableH;

  PROCEDURE* OutputEnable2*(maskL, maskH: SET);
  (* deprecated, use OutputEnable and OutputEnableH *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, maskL);
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_SET, maskH)
  END OutputEnable2;


  PROCEDURE* OutputDisable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_CLR, mask)
  END OutputDisable;

  PROCEDURE* OutputDisableH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_CLR, maskH)
  END OutputDisableH;


  PROCEDURE* OutputEnToggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_XOR, mask)
  END OutputEnToggle;

  PROCEDURE* OutputEnToggleH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_XOR, maskH)
  END OutputEnToggleH;


  PROCEDURE* GetOutputEnable*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OE, pinVal)
  END GetOutputEnable;

  PROCEDURE* GetOutputEnableH*(VAR pinValH: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_OE, pinValH)
  END GetOutputEnableH;


  PROCEDURE init;
  BEGIN
    StartUp.ReleaseResets({MCU.RESETS_IO_BANK0, MCU.RESETS_PADS_BANK0})
  END init;

BEGIN
  init
END GPIO.
