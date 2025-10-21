MODULE Main;
(**
  Oberon RTK Framework v3.0
  --
  Main module
  Custom module for text/example program K4print.
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    (* LinkOptions is the first import of Config *)
    Config, Clocks, Memory, RuntimeErrors,
    StartUp, RuntimeErrorsOut, Terminals, Out, In, GPIO, UARTdev, UARTstr, UARTstrKbw, UARTstrKint, MCU := MCU2;

  CONST
    Baudrate0 = 38400; (* terminal 0 *)
    Baudrate1 = 38400;
    Core0 = 0;
    Core1 = 1;
    TERM0 = Terminals.TERM0;
    TERM1 = Terminals.TERM1;
    UART0 = UARTdev.UART0;
    UART1 = UARTdev.UART1;
    UART0_TxPinNo = 0;
    UART0_RxPinNo = 1;
    UART1_TxPinNo = 4;
    UART1_RxPinNo = 5;

    UARTrdyQintNo = MCU.IRQ_SW_0;
    UARTintPrio = MCU.ExcPrio7;

    FPUnonSecAccess = FALSE; (* enable for secure access only for now *)
    FPUtreatAsSec = FALSE;

    NumUARToutputMsg = 16;

    (* select test case/output driver *)
    UseUARTstr = FALSE;
    UseUARTstrKbw = FALSE;
    UseUARTstrKint = TRUE;


  PROCEDURE configPins(txPinNo, rxPinNo: INTEGER);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pullupEn := GPIO.Enabled;
    padCfg.pulldownEn := GPIO.Disabled;
    GPIO.ConfigurePad(txPinNo, padCfg);
    GPIO.ConfigurePad(rxPinNo, padCfg);
    GPIO.ConnectInput(rxPinNo);
    GPIO.SetFunction(txPinNo, MCU.IO_BANK0_Fuart);
    GPIO.SetFunction(rxPinNo, MCU.IO_BANK0_Fuart)
  END configPins;


  PROCEDURE init;
    VAR
      uartDev0, uartDev1: UARTdev.Device;
      uartCfg: UARTdev.DeviceCfg;
  BEGIN
    RuntimeErrors.Init;

    (* configure the pins and pads *)
    configPins(UART0_TxPinNo, UART0_RxPinNo);
    configPins(UART1_TxPinNo, UART1_RxPinNo);

    IF UseUARTstr THEN
      (* define UART cfg *)
      UARTdev.GetBaseCfg(uartCfg);
      uartCfg.fifoEn := UARTdev.Enabled;

      (* open text IO to/from two serial terminals *)
      Terminals.InitUART(UART0, uartCfg, Baudrate0, uartDev0);
      Terminals.Open(TERM0, uartDev0, UARTstr.PutString, UARTstr.GetString);

      Terminals.InitUART(UART1, uartCfg, Baudrate1, uartDev1);
      Terminals.Open(TERM1, uartDev1, UARTstr.PutString, UARTstr.GetString)

    ELSIF UseUARTstrKbw THEN
       (* define UART cfg *)
      UARTdev.GetBaseCfg(uartCfg);
      uartCfg.fifoEn := UARTdev.Enabled;

      (* open text IO to/from two serial terminals *)
      Terminals.InitUART(UART0, uartCfg, Baudrate0, uartDev0);
      Terminals.Open(TERM0, uartDev0, UARTstrKbw.PutString, UARTstr.GetString);

      Terminals.InitUART(UART1, uartCfg, Baudrate1, uartDev1);
      Terminals.Open(TERM1, uartDev1, UARTstr.PutString, UARTstr.GetString);

      UARTstrKbw.Install(uartDev0, UARTrdyQintNo, UARTintPrio, NumUARToutputMsg)

    ELSIF UseUARTstrKint THEN
      (* define UART cfg *)
      UARTdev.GetBaseCfg(uartCfg);
      uartCfg.fifoEn := UARTdev.Disabled;

      (* open text IO to/from two serial terminals *)
      Terminals.InitUART(UART0, uartCfg, Baudrate0, uartDev0);
      Terminals.Open(TERM0, uartDev0, UARTstrKint.PutString, UARTstr.GetString);

      Terminals.InitUART(UART1, uartCfg, Baudrate1, uartDev1);
      Terminals.Open(TERM1, uartDev1, UARTstr.PutString, UARTstr.GetString);

      UARTstrKint.Install(uartDev0, UARTrdyQintNo, UARTintPrio, NumUARToutputMsg)

    ELSE
      ASSERT(FALSE)
    END;

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
    (*
    RuntimeErrors.EnableFaults;
    FPUctrl.Init(FPUnonSecAccess, FPUtreatAsSec);
    *)

    (* let's get the timers symmetrical *)
    (* TIMER0 is released by boot procedure *)
    (*
    StartUp.ReleaseResets({MCU.RESETS_TIMER1})
    *)
  END init;

BEGIN
  init
END Main.
