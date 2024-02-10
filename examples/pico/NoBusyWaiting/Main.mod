MODULE Main;
(**
  Oberon RTK Framework
  Main module
  --
  For example 'NoBusyWaiting'.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2023-2024, Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    (* the first row of modules "auto-init", keep their order in the list *)
    (* ignore the "is not used" warnings... :) *)
    (* LinkOptions is the first import of Config *)
    Config, Clocks, Memory, RuntimeErrors,
    RuntimeErrorsOut, UARTstr, UARTkstr, Terminals, Out;

  CONST
    Baudrate = 9600;
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
    (* open text output to two serial terminals *)
    Terminals.Open(UART0, UART0_TxPinNo, UART0_RxPinNo, Baudrate, UARTstr.PutString, UARTstr.GetString);

    (* busy waiting *)

    Terminals.Open(UART1, UART1_TxPinNo, UART1_RxPinNo, Baudrate, UARTstr.PutString, UARTstr.GetString);
    (* no busy waiting *)
    (*
    Terminals.Open(UART1, UART1_TxPinNo, UART1_RxPinNo, Baudrate, UARTkstr.PutString, UARTkstr.GetString);
    *)

    (* init Out to use the terminals, from thread 0 => terminal 0 etc. *)
    (* (custom Out module) *)
    Out.Open(Terminals.W[0], Terminals.W[1]);

    (* init run-time error printing *)
    (* error output on core 0 to terminal 0 *)
    Terminals.OpenErr(UART0, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core0, Terminals.Werr[0]);
    RuntimeErrors.SetHandler(Core0, RuntimeErrorsOut.HandleException);
    (* error output on core 1 to terminal 1 *)
    Terminals.OpenErr(UART1, UARTstr.PutString);
    RuntimeErrorsOut.SetWriter(Core1, Terminals.Werr[1]);
    RuntimeErrors.SetHandler(Core1, RuntimeErrorsOut.HandleException);
  END init;

BEGIN
  init
END Main.
