MODULE Main;
(**
  Oberon RTK Framework
  Main module
  --
  Default: WITH Kernel
  See IMPORT list below of the simple code changes to use without.
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
    RuntimeErrorsOut, Terminal, Out, In, UART := UARTkstr; (* set UART := UARTstr for use WITHOUT kernel *)

  CONST
    Baudrate0 = 38400; (* terminal 0 *)
    Baudrate1 = 38400;
    Core0 = 0;
    Core1 = 1;
    UART0 = Terminal.UART0;
    UART1 = Terminal.UART1;
    UART0_TxPinNo = 0;
    UART0_RxPinNo = 1;
    UART1_TxPinNo = 4;
    UART1_RxPinNo = 5;


  PROCEDURE init;
  BEGIN
    (* open text IO to/from two serial terminals *)
    Terminal.Open(UART0, UART0_TxPinNo, UART0_RxPinNo, Baudrate0, UART.PutString, UART.GetString);
    Terminal.Open(UART1, UART1_TxPinNo, UART1_RxPinNo, Baudrate1, UART.PutString, UART.GetString);

    (* init Out and In to use the terminals *)
    Out.Open(Terminal.W[0], Terminal.W[1]);
    In.Open(Terminal.R[0], Terminal.R[1]);

    (* init run-time error printing *)
    (* error output on core 0 to terminal 0 *)
    RuntimeErrorsOut.SetWriter(Core0, Terminal.W[0]);
    RuntimeErrors.SetHandler(Core0, RuntimeErrorsOut.HandleException);

    (* error output on core 1 to terminal 1 *)
    RuntimeErrorsOut.SetWriter(Core1, Terminal.W[1]);
    RuntimeErrors.SetHandler(Core1, RuntimeErrorsOut.HandleException);
  END init;

BEGIN
  init
END Main.
