MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.0
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
    SYSTEM, Config, Memory, MCU := MCU2, RuntimeErrors, RuntimeErrorsOut, StartUp, Clocks, Terminals,
    UARTdev, UARTstr, FPUctrl, GPIO, Out, In;

  CONST
    Baudrate0 = 38400; (* terminal 0 *)
    UARTt0 = UARTdev.UART2;
    UARTt0_TxPinNo = MCU.PORT2 + 2;
    UARTt0_RxPinNo = MCU.PORT2 + 3;
    TERM0 = Terminals.TERM0;


  PROCEDURE cfgPins(txPin, rxPin: INTEGER);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    StartUp.ReleaseReset(MCU.DEV_PORT2);
    StartUp.EnableClock(MCU.DEV_PORT2);
    GPIO.GetPadBaseCfg(padCfg);
    GPIO.ConfigurePad(txPin, padCfg);
    GPIO.ConfigurePad(rxPin, padCfg);
    GPIO.SetFunction(txPin, GPIO.Fuart1);
    GPIO.SetFunction(rxPin, GPIO.Fuart1)
  END cfgPins;


  PROCEDURE* enableFlashCache;
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SYSCON_LPCAC_CTRL, val);
    BFI(val, 8, 1); (* set RAMX1 as cache memory *)
    BFI(val, 0, 0); (* remove disable cache *)
    SYSTEM.PUT(MCU.SYSCON_LPCAC_CTRL, val)
  END enableFlashCache;


  PROCEDURE init;
    CONST Core0 = 0;
    VAR
      uartDev: UARTdev.Device;
      uartCfg: UARTdev.DeviceCfg;
  BEGIN
    (* init vector table *)
    RuntimeErrors.Init;

    (* config the clocks *)
    (*Clocks.InitFIRC(Clocks.FIRC_180);*)
    Clocks.InitSPLL;

    (* flash cache *)
    enableFlashCache;

    (* config pins and pads *)
    cfgPins(UARTt0_TxPinNo, UARTt0_RxPinNo);

    (* define UART cfg *)
    UARTdev.GetBaseCfg(uartCfg);
    uartCfg.osr := 11;
    uartCfg.txfe := UARTdev.Enabled;
    uartCfg.rxfe := UARTdev.Enabled;
    uartCfg.txwater := UARTdev.FifoSize - 1;
    uartCfg.rxwater := UARTdev.FifoSize - 1;

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
    FPUctrl.Init
  END init;

BEGIN
  init
END Main.
