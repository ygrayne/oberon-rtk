MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Device driver for General Purpose IO (GPIO)
  --
  MCU: STM32H573II, STM32U585AI
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, DEV := GPIO_DEV, RST, Errors;

  CONST
    (* handles *)
    (* do  not assume any specific values for these handles *)
    PORTA* = DEV.GPIO_PORTA;
    PORTB* = DEV.GPIO_PORTB;
    PORTC* = DEV.GPIO_PORTC;
    PORTD* = DEV.GPIO_PORTD;
    PORTE* = DEV.GPIO_PORTE;
    PORTF* = DEV.GPIO_PORTF;
    PORTG* = DEV.GPIO_PORTG;
    PORTH* = DEV.GPIO_PORTH;
    PORTI* = DEV.GPIO_PORTI;

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

    (* internal *)
    Modes = {0 .. 3};
    Types = {0, 1};
    Speeds = {0 .. 3};
    Pulls = {0 .. 2};
    ValidBits = {0 .. 15};


  TYPE
    PinCfg* = RECORD
      mode*: INTEGER;
      type*: INTEGER;
      speed*: INTEGER;
      pulls*: INTEGER
    END;


  PROCEDURE ConfigurePin*(port, pin: INTEGER; cfg: PinCfg);
    VAR addr, rstPos: INTEGER; val, mask: SET;
  BEGIN
    ASSERT(cfg.mode IN Modes, Errors.PreCond);
    ASSERT(cfg.type IN Types, Errors.PreCond);
    ASSERT(cfg.speed IN Speeds, Errors.PreCond);
    ASSERT(cfg.pulls IN Pulls, Errors.PreCond);

    rstPos := (port - DEV.GPIOA_BASE) DIV DEV.GPIO_Offset;
    RST.EnableBusClock(DEV.GPIO_BC_reg, rstPos);

    mask := BITS(pin);

    addr := port + DEV.GPIO_OTYPER_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.type, pin));
    SYSTEM.PUT(addr, val);

    pin := pin * 2;
    mask := BITS(LSL(03H, pin));

    addr := port + DEV.GPIO_MODER_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.mode, pin));
    SYSTEM.PUT(addr, val);

    addr := port + DEV.GPIO_OSPEEDR_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.speed, pin));
    SYSTEM.PUT(addr, val);

    addr := port + DEV.GPIO_PUPDR_Offset;
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(cfg.pulls, pin));
    SYSTEM.PUT(addr, val)
  END ConfigurePin;


  PROCEDURE* SetFunction*(port, pin, function: INTEGER);
  (* must be called after ConfigPin *)
  (* or maybe add enabling BC also here *)
    VAR addr: INTEGER; val, mask: SET;
  BEGIN
    addr := port + DEV.GPIO_AFRL_Offset + ((pin DIV 8) * 4);
    pin := (pin MOD 8) * 4;
    mask := BITS(LSL(0FH, pin));
    SYSTEM.GET(addr, val);
    val := val - mask + BITS(LSL(function, pin));
    SYSTEM.PUT(addr, val)
  END SetFunction;


  PROCEDURE* GetPinBaseCfg*(VAR cfg: PinCfg);
  BEGIN
    CLEAR(cfg);
    cfg.mode := ModeAn
  END GetPinBaseCfg;


  PROCEDURE* SetNonSecPins*(port: INTEGER; nonSecPins: SET);
  (* all pins of all ports are Secure on reset *)
    VAR reg: INTEGER;
  BEGIN
    reg := port + DEV.GPIO_SECCFGR_Offset;
    SYSTEM.PUT(reg, (-nonSecPins * ValidBits))
  END SetNonSecPins;


  (* GPIO direct pin control *)

  PROCEDURE* Set*(port: INTEGER; pinMask: SET);
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.PUT(port + DEV.GPIO_BSRR_Offset, pinMask)
  END Set;


  PROCEDURE* Clear*(port: INTEGER; pinMask: SET);
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.PUT(port + DEV.GPIO_BRR_Offset, pinMask)
  END Clear;


  PROCEDURE* Toggle*(port: INTEGER; pinMask: SET);
    VAR val, rst, set: SET;
  BEGIN
    pinMask := pinMask * ValidBits;
    SYSTEM.GET(port + DEV.GPIO_ODR_Offset, val);
    val := val * pinMask;
    rst := BITS(LSL(ORD(val), 16));
    set := val / pinMask;
    val := set + rst;
    SYSTEM.PUT(port + DEV.GPIO_BSRR_Offset, val)
  END Toggle;

END GPIO.
