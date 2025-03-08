MODULE PIOsquarePio;
(**
  Oberon RTK Framework
  Generated module from PIO assembly code.
  Assembly programs:
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
**)

  PROCEDURE GetCode*(progName: ARRAY OF CHAR; VAR code: ARRAY OF INTEGER; VAR numInstr, wrapTarget, wrap, pioVersion: INTEGER);
  BEGIN
    IF progName = "square_wave" THEN
      code[0] := 0E081H;
      code[1] := 0E101H;
      code[2] := 0E000H;
      code[3] := 00001H;
      numInstr := 4;
      wrapTarget := 0;
      wrap := 3;
      pioVersion := 0
    ELSIF progName = "square_wave_asym" THEN
      code[0] := 0E081H;
      code[1] := 0E101H;
      code[2] := 0E000H;
      numInstr := 3;
      wrapTarget := 1;
      wrap := 2;
      pioVersion := 0
    END;
  END GetCode;
END PIOsquarePio.
