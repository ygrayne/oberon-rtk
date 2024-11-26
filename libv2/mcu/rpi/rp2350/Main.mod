MODULE Main;
(**
  Oberon RTK Framework v2
  --
  Main module
  --
  MCU: RP2350
  --
  Copyright (c) 2023 - 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    (* the first row of modules "auto-init", keep their order in the list *)
    (* ignore the "is not used" warnings... :) *)
    (* LinkOptions is the first import of Config *)
    Config, Clocks, Memory, RuntimeErrors,
    StartUp, RuntimeErrorsOut, Terminals, Out, In, GPIO, UARTdev, UARTstr, MCU := MCU2, SYSTEM;

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

    FPUenable = TRUE;
    FPUnonSecAccess = FALSE; (* enable for secure access only for now *)
    FPUtreatAsSec = FALSE;

    (* PPB_CPACR bits & values *)
    CPACR_FPU_1 = 23;
    CPACR_FPU_0 = 20;
      FPU_NoAccess   = 00H; (* 0000, disabled *)
      FPU_PrivAccess = 05H; (* 0101, priviledged code access *)
      FPU_AllAccess  = 0FH; (* 1111, all code access *)

    (* PPB_NSACR bits and values *)
    NSACR_FPU_1 = 23;
    NSACR_FPU_0 = 20;
      (* values as for PPB_CPACR *)

    (* PPB_FPCCR bits *)
    FPCCR_TS = 26;

  PROCEDURE configPins(txPinNo, rxPinNo: INTEGER);
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pullupEn := GPIO.Enabled;
    padCfg.pulldownEn := GPIO.Disabled;
    GPIO.ConfigurePad(txPinNo, padCfg);
    GPIO.ConfigurePad(rxPinNo, padCfg);
    GPIO.EnableInput(rxPinNo);
    GPIO.SetFunction(txPinNo, MCU.IO_BANK0_Fuart);
    GPIO.SetFunction(rxPinNo, MCU.IO_BANK0_Fuart)
  END configPins;


  PROCEDURE* initFPU(nonSecAccess, treatAsSec: BOOLEAN);
    VAR x: INTEGER;
  BEGIN
    x := 0;
    BFI(x, CPACR_FPU_1, CPACR_FPU_0, FPU_AllAccess);
    SYSTEM.PUT(MCU.PPB_CPACR, x);
    IF nonSecAccess THEN
      SYSTEM.PUT(MCU.PPB_NSACR, x)
      (* not sure if NS alias of CPACR needs to be set too *)
    END;
    IF treatAsSec THEN
      SYSTEM.GET(MCU.PPB_FPCCR, x);
      BFI(x, FPCCR_TS, 1);
      SYSTEM.PUT(MCU.PPB_FPCCR, x)
    END
  END initFPU;


  PROCEDURE init;
    VAR
      uartDev0, uartDev1: UARTdev.Device;
      uartCfg: UARTdev.DeviceCfg;
  BEGIN
    (* define UART cfg *)
    UARTdev.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UARTdev.Enabled;

    (* configure the pins and pads *)
    configPins(UART0_TxPinNo, UART0_RxPinNo);
    configPins(UART1_TxPinNo, UART1_RxPinNo);

    (* open text IO to/from two serial terminals *)
    Terminals.InitUART(UART0, uartCfg, Baudrate0, uartDev0);
    Terminals.Open(TERM0, uartDev0, UARTstr.PutString, UARTstr.GetString);
    Terminals.InitUART(UART1, uartCfg, Baudrate1, uartDev1);
    Terminals.Open(TERM1, uartDev1, UARTstr.PutString, UARTstr.GetString);

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

    (* FPU *)
    IF FPUenable THEN
      initFPU(FPUnonSecAccess, FPUtreatAsSec)
    END;

    (* let's get the timers symmetrical *)
    StartUp.ReleaseReset(MCU.RESETS_TIMER1) (* TIMER0 is released by boot procedure *)
  END init;

BEGIN
  init
END Main.
