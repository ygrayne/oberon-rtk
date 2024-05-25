MODULE Main;
(**
  Oberon RTK Framework
  Main module
  For example program NoBusyWaiting
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2023 - 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    (* the first row of modules "auto-init", keep their order in the list *)
    (* ignore the "is not used" warnings... :) *)
    (* LinkOptions is the first import of Config *)
    Config, Clocks, Memory, RuntimeErrors,
    RuntimeErrorsOut, Terminals, Out, In, UARTdev, UARTstr, UARTkstr;

  CONST
    Baudrate0 = 9600; (* terminal 0 *)
    Baudrate1 = 9600;
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


  PROCEDURE init;
    VAR
      uartDev0, uartDev1: UARTdev.Device;
      uartCfg: UARTdev.DeviceCfg;
  BEGIN
    (* open text IO to/from two serial terminals *)
    uartCfg.baudrate := Baudrate0;
    uartCfg.dataBits := UARTdev.DataBits8;
    uartCfg.stopBits := UARTdev.StopBits1;
    uartCfg.parity := UARTdev.ParityOff;
    uartCfg.fifo := UARTdev.FifoOn;

    Terminals.InitUART(UART0, uartCfg, UART0_TxPinNo, UART0_RxPinNo, uartDev0);
    Terminals.Open(TERM0, uartDev0, UARTstr.PutString, UARTstr.GetString);

    uartCfg.baudrate := Baudrate1;
    Terminals.InitUART(UART1, uartCfg, UART1_TxPinNo, UART1_RxPinNo, uartDev1);

    Terminals.Open(TERM1, uartDev1, UARTstr.PutString, UARTstr.GetString);
    (*
    Terminals.Open(TERM1, uartDev1, UARTkstr.PutString, UARTkstr.GetString);
    *)
    (* init Out and In to use the string buffers or terminals *)
    Out.Open(Terminals.W[0], Terminals.W[1]);
    In.Open(Terminals.R[0], Terminals.R[1]);

    (* init run-time error printing *)
    (* error output on core 0 to terminal 0 *)
    (* use error output writer *)
    Terminals.OpenErr(TERM0, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core0, Terminals.Werr[0]);
    RuntimeErrors.SetHandler(Core0, RuntimeErrorsOut.HandleException);

    (* error output on core 1 to terminal 1 *)
    (* use error output writer *)
    Terminals.OpenErr(TERM1, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core1, Terminals.Werr[1]);
    RuntimeErrors.SetHandler(Core1, RuntimeErrorsOut.HandleException);
  END init;

BEGIN
  init
END Main.
