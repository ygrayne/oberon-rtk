MODULE PIOsquare;
(**
  Oberon RTK Framework v2
  --
  Example program, without kernel, one core
  Description: https://oberon-rtk.org/examples/v2/piosquare/
  --
  MCU: RP2040, RP2350
  Board: Pico, Pico2
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, MCU := MCU2, PIOsquarePio, PIO, GPIO, Out, Errors;

(*
  PIOBEGIN
    .program square_wave
      set pindirs 1
    loop:
      set pins 1 [1]
      set pins 0
      jmp loop

    .program square_wave_asym
      set pindirs 1
      .wrap_target
      set pins 1 [1]
      set pins 0
      .wrap
  PIOEND
*)

  CONST
    WavePinNo0 = 16;
    WavePinNo1 = 17;
    WaveNumPins = 1;
    PIOprog0 = "square_wave";
    PIOprog1 = "square_wave_asym";
    SM0 = PIO.SM0;
    SM1 = PIO.SM1;


  PROCEDURE run;
    VAR
      pioDev: PIO.Device;
      code: ARRAY PIO.MaxNumInstr OF INTEGER;
      numInstr, wrap, wrapTarget, pioVersion, offset: INTEGER;
  BEGIN
    Out.String("init"); Out.Ln;

    (* PIO device *)
    NEW(pioDev); ASSERT(pioDev # NIL, Errors.HeapOverflow);
    PIO.Init(pioDev, PIO.PIO0);
    PIO.Configure(pioDev);

    (* GPIO pins *)
    GPIO.SetFunction(WavePinNo0, MCU.IO_BANK0_Fpio0);
    GPIO.SetFunction(WavePinNo1, MCU.IO_BANK0_Fpio0);

    (* get and load PIO code *)
    offset := 0;
    PIOsquarePio.GetCode(PIOprog0, code, numInstr, wrapTarget, wrap, pioVersion);
    PIO.PutCode(pioDev, code, offset, numInstr);
    PIO.ConfigWrap(pioDev, SM0, wrapTarget, wrap);
    PIO.SetStartAddr(pioDev, SM0, offset);

    offset := offset + numInstr;
    PIOsquarePio.GetCode(PIOprog1, code, numInstr, wrapTarget, wrap, pioVersion);
    PIO.PutCode(pioDev, code, offset, numInstr);
    PIO.ConfigWrap(pioDev, SM1, wrapTarget + offset, wrap + offset);
    PIO.SetStartAddr(pioDev, SM1, offset);

    (* configure state machines *)
    PIO.ConfigPinsSet(pioDev, SM0, WavePinNo0, WaveNumPins);
    PIO.ConfigPinsSet(pioDev, SM1, WavePinNo1, WaveNumPins);
    PIO.ConfigClockDiv(pioDev, SM0, 0, 0);
    PIO.ConfigClockDiv(pioDev, SM1, 0, 0);
    PIO.EnableStateMachines(pioDev, {SM0, SM1});

    Out.String("waving..."); Out.Ln;
  END run;

BEGIN
  run
END PIOsquare.
