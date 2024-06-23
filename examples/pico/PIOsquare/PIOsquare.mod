MODULE PIOsquare;
(**
  Oberon RTK Framework
  --
  Example program, without kernel, one core
  Description: https://oberon-rtk.org/examples/piosquare/
  --
  MCU: Cortex-M0+ RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, PIOsquarePio, PIO, GPIO, Out, Errors;

(*
  PIO; (* PIO assembly code *)
    .program squarewave
      set pindirs 1
    loop:
      set pins 1 [1]
      set pins 0
      jmp loop
  PIO.
*)

  CONST
    WavePinNo = 22;
    WaveNumPins = 1;
    SM = PIO.SM0;

  PROCEDURE run;
    VAR
      pioDev: PIO.Device;
      code: ARRAY PIO.MaxNumInstr OF INTEGER;
      numInstr: INTEGER;
  BEGIN
    Out.String("init"); Out.Ln;

    (* PIO device *)
    NEW(pioDev); ASSERT(pioDev # NIL, Errors.HeapOverflow);
    PIO.Init(pioDev, PIO.PIO0);
    PIO.Configure(pioDev);

    (* GPIO pin *)
    GPIO.SetFunction(WavePinNo, GPIO.Fpio0);
    GPIO.OutputEnable({WavePinNo});
    GPIO.Clear({WavePinNo});

    (* get and load PIO code *)
    PIOsquarePio.GetCode(code, numInstr);
    PIO.LoadCode(pioDev, code, 0, numInstr);

    (* configure state machine *)
    PIO.ConfigPinsSet(pioDev, SM, WavePinNo, WaveNumPins);
    PIO.ConfigClockDiv(pioDev, SM, 0, 0);
    PIO.EnableStateMachines(pioDev, {SM});

    Out.String("waving..."); Out.Ln;
  END run;

BEGIN
  run
END PIOsquare.

