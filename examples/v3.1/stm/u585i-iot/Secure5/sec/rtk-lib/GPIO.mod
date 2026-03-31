MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Device driver for General Purpose IO (GPIO)
  --
  Definition module: GPIOdef.mod
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, CFG := DEV2, RST, Errors;


  CONST
    (* API definitions *)
    (* values for PadCfg *)
    Enabled* = 1;
    Disabled* = 0;

    ModeIn*  = 0;
    ModeOut* = 1;
    ModeAlt* = 2;
    ModeAn*  = 3; (* reset *)


    TypePushPull*   = 0; (* reset *)
    TypeOpenDrain*  = 1;

    SpeedLow* = 0;
    SpeedMed* = 1;
    SpeedHigh* = 2;
    SpeedVeryHigh* = 3;

    PullNone* = 0; (* reset *)
    PullUp* = 1;
    PullDown* = 2;


    (* internal definitions *)
    PORT = {0 .. 8};
    Modes = {0 .. 3};
    Types = {0, 1};
    Speeds = {0 .. 3};
    Pulls = {0 .. 2};
    ValidBits = {0 .. 15};


  TYPE
    Port* = POINTER TO PortDesc;
    PortDesc* = RECORD
      portId*: INTEGER;
      bcEnReg, bcEnPos: INTEGER;
      bcEn: BOOLEAN;
      MODER, OTYPER, OSPEEDR, PUPDR: INTEGER;
      IDR, ODR, BSRR, LCKR: INTEGER;
      AFRL, AFRH: INTEGER;
      BRR, HSLVR, SECCFGR: INTEGER
    END;

    PadCfg* = RECORD
      mode*: INTEGER;
      type*: INTEGER;
      speed*: INTEGER;
      pulls*: INTEGER
    END;


  PROCEDURE* Init*(port: Port; portId: INTEGER);
    VAR base: INTEGER;
  BEGIN
    ASSERT(port # NIL, Errors.PreCond);
    ASSERT(portId IN PORT, Errors.PreCond);
    port.portId := portId;
    port.bcEnReg := CFG.GPIO_BC_EN;
    port.bcEnPos := portId;
    port.bcEn := FALSE;
    base := CFG.GPIOA_BASE + (portId * CFG.GPIO_Offset);
    port.MODER := base + CFG.GPIO_MODER_Offset;
    port.OTYPER := base + CFG.GPIO_OTYPER_Offset;
    port.OSPEEDR := base + CFG.GPIO_OSPEEDR_Offset;
    port.PUPDR := base + CFG.GPIO_PUPDR_Offset;
    port.IDR := base + CFG.GPIO_IDR_Offset;
    port.ODR := base + CFG.GPIO_ODR_Offset;
    port.BSRR := base + CFG.GPIO_BSRR_Offset;
    port.LCKR := base + CFG.GPIO_LCKR_Offset;
    port.AFRL := base + CFG.GPIO_AFRL_Offset;
    port.AFRH := base + CFG.GPIO_AFRH_Offset;
    port.BRR := base + CFG.GPIO_BRR_Offset;
    port.HSLVR := base + CFG.GPIO_HSLVR_Offset
  END Init;


  PROCEDURE ConfigurePin*(port: Port; pin: INTEGER; cfg: PadCfg);
    VAR addr: INTEGER; val, mask: SET;
  BEGIN
    ASSERT(cfg.mode IN Modes, Errors.PreCond);
    ASSERT(cfg.type IN Types, Errors.PreCond);
    ASSERT(cfg.speed IN Speeds, Errors.PreCond);
    ASSERT(cfg.pulls IN Pulls, Errors.PreCond);

    IF ~port.bcEn THEN
      RST.EnableBusClock(port.bcEnReg, port.bcEnPos);
      port.bcEn := TRUE
    END;

    mask := BITS(pin);

    addr := port.OTYPER;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.type, pin));
    SYSTEM.PUT(addr, val);

    pin := pin * 2;
    mask := BITS(LSL(03H, pin));

    addr := port.MODER;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.mode, pin));
    SYSTEM.PUT(addr, val);

    addr := port.OSPEEDR;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.speed, pin));
    SYSTEM.PUT(addr, val);

    addr := port.PUPDR;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.pulls, pin));
    SYSTEM.PUT(addr, val)
  END ConfigurePin;


  PROCEDURE* SetFunction*(port: Port; pin, function: INTEGER);
  (* must be called after ConfigPad *)
    VAR addr: INTEGER; val, mask: SET;
  BEGIN
    addr := port.AFRL + ((pin DIV 8) * 4);
    pin := (pin MOD 8) * 4;
    mask := BITS(LSL(0FH, pin));
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(function, pin));
    SYSTEM.PUT(addr, val)
  END SetFunction;


  PROCEDURE SetNonSecPins*(portNo: INTEGER; nonSecPins: SET);
  (* all pins of all ports are Secure on reset *)
    VAR reg: INTEGER;
  BEGIN
    reg := CFG.GPIOA_BASE + CFG.GPIO_SECCFGR_Offset + (portNo * CFG.GPIO_Offset);
    SYSTEM.PUT(reg, (-nonSecPins * ValidBits))
  END SetNonSecPins;


  (* GPIO control *)

  PROCEDURE* Set*(port: Port; pinMask: SET);
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.PUT(port.BSRR, pinMask)
  END Set;


  PROCEDURE* Clear*(port: Port; pinMask: SET);
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.PUT(port.BRR, pinMask)
  END Clear;


  PROCEDURE* Toggle*(port: Port; pinMask: SET);
    VAR val, rst, set: SET;
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.GET(port.ODR, val);
    val := val * pinMask;
    rst := BITS(LSL(ORD(val), 16));
    set := val / pinMask;
    val := set + rst;
    SYSTEM.PUT(port.BSRR, val)
  END Toggle;

END GPIO.
