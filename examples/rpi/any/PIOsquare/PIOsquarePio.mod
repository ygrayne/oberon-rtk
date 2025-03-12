MODULE PIOsquarePio;
(**
  Oberon RTK Framework
  Generated module from PIO assembly code.
  --
  PIO assembly listing:
    .pio_version 0

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

  IMPORT PIO;

  PROCEDURE GetCode*(progName: ARRAY OF CHAR; VAR prog: PIO.Program);
    VAR i: INTEGER;
  BEGIN
    IF progName = "square_wave" THEN
      prog.name := "square_wave";
      prog.wrapTarget := 0;
      prog.wrap := 3;
      prog.origin := -1;
      prog.sideset.size := 0;
      prog.sideset.optional := FALSE;
      prog.sideset.pindirs := FALSE;
      prog.instr[0] := 0E081H;
      prog.instr[1] := 0E101H;
      prog.instr[2] := 0E000H;
      prog.instr[3] := 00001H;
      prog.numInstr := 4;
      prog.numPubLabels := 0;
      prog.pubSymbols.numGlobals := 0;
      prog.pubSymbols.numLocals := 0;
      i := prog.numPubLabels;
      WHILE i < PIO.NumDefs DO;
        CLEAR(prog.pubLabels[i]); INC(i)
      END;
      i := prog.pubSymbols.numGlobals;
      WHILE i < PIO.NumDefs DO;
        CLEAR(prog.pubSymbols.global[i]); INC(i)
      END;
      i := prog.pubSymbols.numLocals;
      WHILE i < PIO.NumDefs DO;
        CLEAR(prog.pubSymbols.local[i]); INC(i)
      END
    ELSIF progName = "square_wave_asym" THEN
      prog.name := "square_wave_asym";
      prog.wrapTarget := 1;
      prog.wrap := 2;
      prog.origin := -1;
      prog.sideset.size := 0;
      prog.sideset.optional := FALSE;
      prog.sideset.pindirs := FALSE;
      prog.instr[0] := 0E081H;
      prog.instr[1] := 0E101H;
      prog.instr[2] := 0E000H;
      prog.numInstr := 3;
      prog.numPubLabels := 0;
      prog.pubSymbols.numGlobals := 0;
      prog.pubSymbols.numLocals := 0;
      i := prog.numPubLabels;
      WHILE i < PIO.NumDefs DO;
        CLEAR(prog.pubLabels[i]); INC(i)
      END;
      i := prog.pubSymbols.numGlobals;
      WHILE i < PIO.NumDefs DO;
        CLEAR(prog.pubSymbols.global[i]); INC(i)
      END;
      i := prog.pubSymbols.numLocals;
      WHILE i < PIO.NumDefs DO;
        CLEAR(prog.pubSymbols.local[i]); INC(i)
      END
    END
  END GetCode;
END PIOsquarePio.
