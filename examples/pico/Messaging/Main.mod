MODULE Main;
(**
  Oberon RTK Framework
  Main module for example 'Messaging'.
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
    RuntimeErrorsOut, Terminals, Out, In, UARTstr, UARTkstr;

  CONST
    Baudrate0 = 38400; (* terminal 0 *)
    Baudrate1 = 38400;
    Core0 = 0;
    Core1 = 1;
    UART0 = Terminals.UART0;
    UART1 = Terminals.UART1;
    UART0_TxPinNo = 0;
    UART0_RxPinNo = 1;
    UART1_TxPinNo = 4;
    UART1_RxPinNo = 5;


  PROCEDURE init;
  BEGIN
    (* open text IO to/from two serial terminals *)
    Terminals.Open(UART0, UART0_TxPinNo, UART0_RxPinNo, Baudrate0, UARTstr.PutString, UARTstr.GetString);
    Terminals.Open(UART1, UART1_TxPinNo, UART1_RxPinNo, Baudrate1, UARTstr.PutString, UARTstr.GetString);

    (* init Out and In to use the terminals *)
    Out.Open(Terminals.W[0], Terminals.W[1]);
    In.Open(Terminals.R[0], Terminals.R[1]);

    (* init run-time error printing *)
    (* error output on core 0 to terminal 0 *)
    (* use error output writer *)
    Terminals.OpenErr(UART0, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core0, Terminals.Werr[0]);
    RuntimeErrors.SetHandler(Core0, RuntimeErrorsOut.HandleException);

    (* error output on core 1 to terminal 1 *)
    (* use error output writer *)
    Terminals.OpenErr(UART1, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core1, Terminals.Werr[1]);
    RuntimeErrors.SetHandler(Core1, RuntimeErrorsOut.HandleException);
  END init;

BEGIN
  init
END Main.
