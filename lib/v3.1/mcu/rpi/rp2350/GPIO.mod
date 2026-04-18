MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  General Purpose IO (GPIO)
  --
  MCU:
    RP2350A (30 GPIO: 0 .. 29)
    RP2350B (48 GPIO: 0 .. 47)
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, BASE, DEV := GPIO_DEV, RST, Errors;

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
    Fhstx*    = DEV.IO_BANK0_Fhstx;
    Fspi*     = DEV.IO_BANK0_Fspi;
    Fuart*    = DEV.IO_BANK0_Fuart;
    Fi2c*     = DEV.IO_BANK0_Fi2c;
    Fpwm*     = DEV.IO_BANK0_Fpwm;
    Fsio*     = DEV.IO_BANK0_Fsio;
    Fpio0*    = DEV.IO_BANK0_Fpio0;
    Fpio1*    = DEV.IO_BANK0_Fpio1;
    Fpio2*    = DEV.IO_BANK0_Fpio2;
    Fqmi*     = DEV.IO_BANK0_Fqmi;
    Ftrc*     = DEV.IO_BANK0_Ftrc;
    Fclk*     = DEV.IO_BANK0_Fclk;
    Fusb*     = DEV.IO_BANK0_Fusb;
    FuartAlt* = DEV.IO_BANK0_FuartAlt;
    Fnull*    = DEV.IO_BANK0_Fnull;     (* reset state *)

    Functions* = DEV.IO_BANK0_Functions;

    (* GPIO_CTRL overrides *)
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


    (* value ranges *)
    DriveRange = {DRIVE_val_2mA .. DRIVE_val_12mA};
    SlewRange = {SLEWFAST_val_slow, SLEWFAST_val_fast};

    (* GPIO_CTRL overrides *)
    GPIO_OVER_IRQ_1 = 29;  (* [29:28] *)
    GPIO_OVER_IRQ_0 = 28;
    GPIO_OVER_IN_1  = 17;  (* [17:16] *)
    GPIO_OVER_IN_0  = 16;
    GPIO_OVER_OE_1  = 15;  (* [15:14] *)
    GPIO_OVER_OE_0  = 14;
    GPIO_OVER_OUT_1 = 13;  (* [13:12] *)
    GPIO_OVER_OUT_0 = 12;

    PADS_ISO*         = 8;
    PADS_OD*          = 7;
    PADS_IE*          = 6;
    PADS_DRIVE_1*     = 5;  (* [5:4], drive strength *)
    PADS_DRIVE_0*     = 4;
    PADS_PUE*         = 3;
    PADS_PDE*         = 2;
    PADS_SCHMITT*     = 1;
    PADS_SLEWFAST*    = 0;


  TYPE
    PinCfg* = RECORD (* see ASSERTs in 'ConfigurePad' for valid values *)
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
    addr := DEV.IO_BANK0_GPIO0_CTRL + (pin * DEV.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, functionNo);
    SYSTEM.PUT(addr, x);
    (* remove pad isolation *)
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ACLR + (pin * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_ISO})
  END SetFunction;


  PROCEDURE* ClearPadIso*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ACLR + (pin * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_ISO})
  END ClearPadIso;


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


  (* --- pads --- *)

  PROCEDURE ConfigurePin*(pin: INTEGER; cfg: PinCfg);
    VAR addr, x: INTEGER;
  BEGIN
    ASSERT(cfg.outputDe IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.inputEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.driveStrength IN DriveRange, Errors.PreCond);
    ASSERT(cfg.pullupEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.pulldownEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.schmittTrigEn IN {Disabled, Enabled}, Errors.PreCond);
    ASSERT(cfg.slewRate IN SlewRange, Errors.PreCond);

    RST.ReleaseReset(DEV.PADS_BANK0_RST_reg, DEV.PADS_BANK0_RST_pos);
    RST.ReleaseReset(DEV.IO_BANK0_RST_reg, DEV.IO_BANK0_RST_pos);

    addr := DEV.PADS_BANK0_GPIO0 + (pin * DEV.PADS_BANK0_GPIO_Offset);
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
  END GetPinBaseCfg;


  (* the connect/disconnect procedures operate on the pad *)

  PROCEDURE* ConnectOutput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ACLR + (pin * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END ConnectOutput;


  PROCEDURE* DisconnectOutput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ASET + (pin * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_OD})
  END DisconnectOutput;


  PROCEDURE* ConnectInput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ASET + (pin * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END ConnectInput;


  PROCEDURE* DisconnectInput*(pin: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    addr := DEV.PADS_BANK0_GPIO0 + BASE.ACLR + (pin * DEV.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_IE})
  END DisconnectInput;


  (* --- GPIO devices and pads --- *)

  PROCEDURE ResetPin*(pin: INTEGER);
    VAR padCfg: PinCfg;
  BEGIN
    SetFunction(pin, DEV.IO_BANK0_Fnull);
    GetPinBaseCfg(padCfg);
    ConfigurePin(pin, padCfg)
  END ResetPin;


  (* --- GPIO interrupts --- *)

  PROCEDURE* GetIntSummary*(VAR statusL, statusH: SET);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(DEV.GPIO_SIO_CPUID, cid);
    IF cid = 0 THEN
      SYSTEM.GET(DEV.IO_BANK0_IRQSUM_PROC0_SEC0, statusL);
      SYSTEM.GET(DEV.IO_BANK0_IRQSUM_PROC0_SEC1, statusH)
    ELSE
      SYSTEM.GET(DEV.IO_BANK0_IRQSUM_PROC1_SEC0, statusL);
      SYSTEM.GET(DEV.IO_BANK0_IRQSUM_PROC1_SEC1, statusH)
    END
  END GetIntSummary;


  PROCEDURE* SetIntEvents*(pin: INTEGER; events: SET);
    VAR cid, addr, shift: INTEGER;
  BEGIN
    SYSTEM.GET(DEV.GPIO_SIO_CPUID, cid);
    events := events * BITS(EventMask);
    IF cid = 0 THEN
      addr := DEV.IO_BANK0_PROC0_INTE0
    ELSE
      addr := DEV.IO_BANK0_PROC1_INTE0
    END;
    addr := addr + ((pin DIV PinsPerReg) * RegOffset);
    shift := (pin MOD PinsPerReg) * EventBits;
    SYSTEM.PUT(addr + BASE.ACLR, LSL(EventMask, shift));
    SYSTEM.PUT(addr + BASE.ASET, LSL(ORD(events), shift))
  END SetIntEvents;


  PROCEDURE* GetIntEvents*(pin: INTEGER; VAR events: SET);
    VAR cid, addr, val, shift: INTEGER;
  BEGIN
    SYSTEM.GET(DEV.GPIO_SIO_CPUID, cid);
    IF cid = 0 THEN
      addr := DEV.IO_BANK0_PROC0_INTS0
    ELSE
      addr := DEV.IO_BANK0_PROC1_INTS0
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
    addr := DEV.IO_BANK0_INTR0 + ((pin DIV PinsPerReg) * RegOffset);
    SYSTEM.PUT(addr, LSL(ClearMask, (pin MOD PinsPerReg) * EventBits))
  END ClearAllIntEvents;


  (* Secure/Non-secure, RP2350 only *)

  PROCEDURE GetDevSec*(VAR pads, ioBank: INTEGER);
  BEGIN
    pads := DEV.PADS_BANK0_SEC_reg;
    ioBank := DEV.IO_BANK0_SEC_reg
  END GetDevSec;


END GPIO.
