MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  General Purpose IO (GPIO)
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors;


  CONST
    Enabled* = 1;
    Disabled* = 0;

    ModeIn*  = 0;
    ModeOut* = 1;
    ModeAlt* = 2;
    ModeAn*  = 3; (* reset *)
    Modes = {0 .. 3};

    TypePushPull*   = 0; (* reset *)
    TypeOpenDrain*  = 1;
    Types* = {0, 1};

    SpeedLow* = 0;
    SpeedMed* = 1;
    SpeedHigh* = 2;
    SpeedVeryHigh* = 3;
    Speeds = {0 .. 3};

    PullNone* = 0; (* reset *)
    PullUp* = 1;
    PullDown* = 2;
    Pulls = {0 .. 2};

    ValidBits = {0 .. 15};


  TYPE
    PadCfg* = RECORD
      mode*: INTEGER;
      type*: INTEGER;
      speed*: INTEGER;
      pulls*: INTEGER
    END;



  PROCEDURE* ConfigurePad*(port, pin: INTEGER; cfg: PadCfg);
  (* parameter 'port': MCU.PORTx *)
    VAR addr: INTEGER; val, mask: SET;
  BEGIN
    ASSERT(cfg.mode IN Modes, Errors.PreCond);
    ASSERT(cfg.type IN Types, Errors.PreCond);
    ASSERT(cfg.speed IN Speeds, Errors.PreCond);
    ASSERT(cfg.pulls IN Pulls, Errors.PreCond);

    mask := BITS(pin);

    addr := port + MCU.GPIO_OTYPER_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.type, pin));
    SYSTEM.PUT(addr, val);

    pin := pin * 2;
    mask := BITS(LSL(03H, pin));

    addr := port + MCU.GPIO_MODER_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.mode, pin));
    SYSTEM.PUT(addr, val);

    addr := port + MCU.GPIO_OSPEEDR_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.speed, pin));
    SYSTEM.PUT(addr, val);

    addr := port + MCU.GPIO_PUPDR_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.pulls, pin));
    SYSTEM.PUT(addr, val)
  END ConfigurePad;


  PROCEDURE* SetFunction*(port, pin, function: INTEGER);
    VAR addr: INTEGER; val, mask: SET;
  BEGIN
    addr := port + MCU.GPIO_AFRL_Offset + ((pin DIV 8) * 4);
    pin := (pin MOD 8) * 4;
    mask := BITS(LSL(0FH, pin));
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(function, pin));
    SYSTEM.PUT(addr, val)
  END SetFunction;


  (* GPIO control *)
  (* parameter 'gpio': MCU.GPIOx *)

  PROCEDURE* Set*(gpio: INTEGER; pinMask: SET);
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.PUT(gpio + MCU.GPIO_BSRR_Offset, pinMask)
  END Set;


  PROCEDURE* Clear*(gpio: INTEGER; pinMask: SET);
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.PUT(gpio + MCU.GPIO_BRR_Offset, pinMask)
  END Clear;


  PROCEDURE* Toggle*(gpio: INTEGER; pinMask: SET);
    VAR val, rst, set: SET;
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.GET(gpio + MCU.GPIO_ODR_Offset, val);
    val := val * pinMask;
    rst := BITS(LSL(ORD(val), 16));
    set := val / pinMask;
    val := set + rst;
    SYSTEM.PUT(gpio + MCU.GPIO_BSRR_Offset, val)
  END Toggle;


END GPIO.
