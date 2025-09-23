MODULE Main;
(**
  Oberon RTK Framework v2.1
  --
  Main module
  --
  MCU: MCX-A346
  Board: FRDM-MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, LinkOptions, MCU := MCU2, StartUp, Clocks, ClockCtrl, UARTdev, UARTstr, TextIO, GPIO;

  CONST
    Baudrate0 = 38400; (* terminal 0 *)
    UART0 = UARTdev.UART2;
    UART0_TxPinNo = (MCU.PORT2 * 32) + 2;
    UART0_RxPinNo = (MCU.PORT2 * 32) + 3;

  VAR
    W*: TextIO.Writer;
    uart*: UARTdev.Device;

  PROCEDURE cfgPins(txPin, rxPin: INTEGER);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    StartUp.ReleaseReset(MCU.DEV_PORT2);
    ClockCtrl.EnableClock(MCU.DEV_PORT2);
    GPIO.GetPadBaseCfg(padCfg);
    GPIO.ConfigurePad(txPin, padCfg);
    GPIO.ConfigurePad(rxPin, padCfg);
    GPIO.SetFunction(txPin, GPIO.Fuart1);
    GPIO.SetFunction(rxPin, GPIO.Fuart1)
  END cfgPins;


  PROCEDURE enableFlashCache;
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SYSCON_LPCAC_CTRL, val);
    BFI(val, 8, 1); (* set RAMX1 as cache memory *)
    BFI(val, 0, 0); (* remove disable cache *)
    SYSTEM.PUT(MCU.SYSCON_LPCAC_CTRL, val)
  END enableFlashCache;


  PROCEDURE init;
    VAR cfg: UARTdev.DeviceCfg;
  BEGIN
    Clocks.InitSPLL;
    enableFlashCache;
    cfgPins(UART0_TxPinNo, UART0_RxPinNo);
    NEW(uart);
    UARTdev.GetBaseCfg(cfg);
    cfg.osr := 11;
    cfg.txfe := UARTdev.Enabled;
    cfg.rxfe := UARTdev.Enabled;
    cfg.txwater := UARTdev.FifoSize - 1;
    cfg.rxwater := UARTdev.FifoSize - 1;
    UARTdev.Init(uart, UART0);
    UARTdev.Configure(uart, cfg, Baudrate0);
    UARTdev.Enable(uart);
    NEW(W);
    TextIO.OpenWriter(W, uart, UARTstr.PutString);
  END init;


BEGIN
  init
END Main.
