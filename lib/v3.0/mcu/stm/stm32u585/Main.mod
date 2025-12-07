MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Main module
  --
  MCU: STM32U585AI
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    Config, Memory, RuntimeErrors, MCU := MCU2, Clocks,
    CLK, RuntimeErrorsOut, Terminals, Out, In, GPIO, UART, UARTstr, FPUctrl;

  CONST
    Baudrate0 = 115200; (* terminal 0 *)
    UARTt0 = UART.USART1;
    UARTt0_TxPinNo = 9; (* GPIOA *)
    UARTt0_RxPinNo = 10;
    TERM0 = Terminals.TERM0;


  PROCEDURE cfgPins(port, txPin, rxPin: INTEGER);
    CONST AF = 7;
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    CLK.EnableClock(MCU.DEV_GPIOA);
    padCfg.mode := GPIO.ModeAlt;
    padCfg.type := GPIO.TypePushPull;
    padCfg.speed := GPIO.SpeedHigh;
    padCfg.pulls := GPIO.PullUp;
    GPIO.ConfigurePad(port, txPin, padCfg);
    GPIO.ConfigurePad(port, rxPin, padCfg);
    GPIO.SetFunction(port, txPin, AF);
    GPIO.SetFunction(port, rxPin, AF)
  END cfgPins;


  PROCEDURE init;
    CONST Core0 = 0;
    VAR
      uartDev: UART.Device;
      uartCfg: UART.DeviceCfg;
      val: SET;
  BEGIN
    Clocks.Configure;

    (* init vector table *)
    RuntimeErrors.Init;

    (* config pins and pads *)
    cfgPins(MCU.PORTA, UARTt0_TxPinNo, UARTt0_RxPinNo);

    (* define UART cfg *)
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;
    uartCfg.over8En := UART.Disabled;

    (* open text IO to/from serial terminal *)
    Terminals.InitUART(UARTt0, uartCfg, Baudrate0, uartDev);
    Terminals.Open(TERM0, uartDev, UARTstr.PutString, UARTstr.GetString);

    (* init Out and In to use terminal *)
    Out.Open(Terminals.W[0], NIL);
    In.Open(Terminals.R[0], NIL);

    (* init run-time error printing to serial terminal *)
    (* use error output writer *)
    Terminals.OpenErr(TERM0, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core0, Terminals.Werr[0]);
    RuntimeErrors.InstallErrorHandler(Core0, RuntimeErrorsOut.ErrorHandler);

    (* core init *)
    RuntimeErrors.EnableFaults;
    FPUctrl.Init;
    (*
    REPEAT UNTIL SYSTEM.BIT(MCU.ICACHE_BASE + 4, 1);
    SYSTEM.GET(MCU.ICACHE_BASE, val);
    SYSTEM.PUT(MCU.ICACHE_BASE, val + {0, 16, 17})
    *)
    Out.Int(Clocks.SYSCLK_FRQ, 10); Out.Ln;
    Out.Int(Clocks.HCLK_FRQ, 10); Out.Ln;
    Out.Int(Clocks.PCLK1_FRQ, 10); Out.Ln;
    Out.Int(Clocks.PCLK2_FRQ, 10); Out.Ln;
    Out.Int(Clocks.PCLK3_FRQ, 10); Out.Ln;
  END init;

BEGIN
  init
END Main.
