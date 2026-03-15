MODULE Main;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Main module
  --
  Type: MCU + board
  --
  Always runs on core 0, hence cannot set any registers on the PPB of core 1.
  See module InitCoreOne.
  --
  MCU: RP2350A
  Board: Pico2
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    (* LinkOptions is the first import of Config *)
    Config, Clocks, Memory, RuntimeErrors,
    RST, RuntimeErrorsOut, Terminals, Out, In, GPIO, UART, UARTstr, MCU := MCU2, FPUctrl;

  CONST
    Baudrate0 = 38400; (* terminal 0 *)
    Baudrate1 = 38400;
    Core0 = 0;
    Core1 = 1;
    TERM0 = Terminals.TERM0;
    TERM1 = Terminals.TERM1;
    UART0 = UART.UART0;
    UART1 = UART.UART1;
    UART0_TxPinNo = 0;
    UART0_RxPinNo = 1;
    UART1_TxPinNo = 4;
    UART1_RxPinNo = 5;

    FPUnonSecAccess = FALSE; (* enable for secure access only for now *)
    FPUtreatAsSec = FALSE;


  PROCEDURE cfgPins(txPinNo, rxPinNo: INTEGER);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pullupEn := GPIO.Enabled;
    padCfg.pulldownEn := GPIO.Disabled;
    GPIO.ConfigurePad(txPinNo, padCfg);
    GPIO.ConfigurePad(rxPinNo, padCfg);
    GPIO.ConnectInput(rxPinNo);
    GPIO.SetFunction(txPinNo, GPIO.Fuart);
    GPIO.SetFunction(rxPinNo, GPIO.Fuart)
  END cfgPins;


  PROCEDURE init;
    VAR
      uartDev0, uartDev1: UART.Device;
      uartCfg: UART.DeviceCfg;
  BEGIN
    Clocks.Configure;
    RuntimeErrors.Install(Core0);
    RuntimeErrors.Install(Core1);

    (* define UART cfg *)
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;

    (* configure the pins and pads *)
    cfgPins(UART0_TxPinNo, UART0_RxPinNo);
    cfgPins(UART1_TxPinNo, UART1_RxPinNo);

    (* open text IO to/from two serial terminals *)
    Terminals.InitUART(UART0, uartCfg, Baudrate0, uartDev0);
    Terminals.Open(TERM0, uartDev0, UARTstr.PutString, UARTstr.GetString);
    Terminals.InitUART(UART1, uartCfg, Baudrate1, uartDev1);
    Terminals.Open(TERM1, uartDev1, UARTstr.PutString, UARTstr.GetString);

    (* init Out and In to use the string buffers or terminals *)
    Out.Open(Terminals.W[0], Terminals.W[1]);
    In.Open(Terminals.R[0], Terminals.R[1]);

    (* init run-time error printing *)
    (* use error output writer *)
    (* error output on core 0 to terminal 0 *)
    Terminals.OpenErr(TERM0, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core0, Terminals.Werr[0]);
    RuntimeErrors.InstallErrorHandler(Core0, RuntimeErrorsOut.ErrorHandler);

    (* error output on core 1 to terminal 1 *)
    Terminals.OpenErr(TERM1, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core1, Terminals.Werr[1]);
    RuntimeErrors.InstallErrorHandler(Core1, RuntimeErrorsOut.ErrorHandler);

    (* core 0 init *)
    (* see module InitCoreOne for core 1 *)
    RuntimeErrors.EnableFaults;
    FPUctrl.Init(FPUnonSecAccess, FPUtreatAsSec);

    (* let's get the timers symmetrical *)
    (* TIMER0 is released by boot procedure *)
    RST.ReleaseResets({MCU.RESETS_TIMER1})
  END init;

BEGIN
  init
END Main.
