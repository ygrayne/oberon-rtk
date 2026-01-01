MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Main module
  --
  Type: MCU + board
  --
  MCU: MCXA346
  Board: FRDM-MCXA346
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, Config, Memory, MCU := MCU2, RuntimeErrors, RuntimeErrorsOut, CLK, RST, Clocks,
    Terminals, UART, UARTstr, FPUctrl, GPIO, Out, In;

  CONST
    Baudrate0 = 38400; (* terminal 0 *)
    UARTt0 = UART.UART2;
    UARTt0_TxPinNo = 2; (* PORT2 *)
    UARTt0_RxPinNo = 3; (* PORT2 *)
    TERM0 = Terminals.TERM0;


  PROCEDURE cfgPins(txPin, rxPin: INTEGER);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    RST.ReleaseReset(MCU.DEV_PORT2);
    CLK.EnableBusClock(MCU.DEV_PORT2);
    GPIO.GetPadBaseCfg(padCfg);
    GPIO.ConfigurePad(MCU.PORT2, txPin, padCfg);
    GPIO.ConfigurePad(MCU.PORT2, rxPin, padCfg);
    GPIO.SetFunction(MCU.PORT2, txPin, GPIO.Fuart1);
    GPIO.SetFunction(MCU.PORT2, rxPin, GPIO.Fuart1)
  END cfgPins;


  PROCEDURE* enableFlashCache;
    CONST LPCAC_CTRL_DIS_LPCAC = 0; LPCAC_CTRL_MEM_REQ = 8;
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SYSCON_LPCAC_CTRL, val);
    BFI(val, LPCAC_CTRL_MEM_REQ, 1); (* set RAMX1 as cache memory *)
    BFI(val, LPCAC_CTRL_DIS_LPCAC, 0); (* remove disable cache *)
    SYSTEM.PUT(MCU.SYSCON_LPCAC_CTRL, val)
  END enableFlashCache;


  PROCEDURE init;
    CONST Core0 = 0;
    VAR
      uartDev: UART.Device;
      uartCfg: UART.DeviceCfg;
  BEGIN
    Clocks.Configure;
    RuntimeErrors.Install(Core0);

    (* flash cache *)
    enableFlashCache;

    (* config pins and pads *)
    cfgPins(UARTt0_TxPinNo, UARTt0_RxPinNo);

    (* define UART cfg *)
    UART.GetBaseCfg(uartCfg);
    uartCfg.osr := 11;
    uartCfg.txfe := UART.Enabled;
    uartCfg.rxfe := UART.Enabled;
    uartCfg.txwater := UART.FifoSize - 1;
    uartCfg.rxwater := UART.FifoSize - 1;
    uartCfg.clkSel := UART.CLK_CLKLF_DIV;
    uartCfg.clkDiv := 0;
    uartCfg.clkFreq := Clocks.CLKLF_DIV_FRQ;

    (* open text IO to/from serial terminal *)
    Terminals.InitUART(UARTt0, uartCfg, Baudrate0, uartDev);
    Terminals.Open(TERM0, uartDev, UARTstr.PutString, UARTstr.GetString);

    (* init Out and In to use terminal *)
    Out.Open(Terminals.W[0]);
    In.Open(Terminals.R[0]);

    (* init run-time error printing to serial terminal *)
    (* use error output writer *)
    Terminals.OpenErr(TERM0, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core0, Terminals.Werr[0]);
    RuntimeErrors.InstallErrorHandler(Core0, RuntimeErrorsOut.ErrorHandler);

    (* core init *)
    RuntimeErrors.EnableFaults;
    FPUctrl.Init
  END init;

BEGIN
  init
END Main.
