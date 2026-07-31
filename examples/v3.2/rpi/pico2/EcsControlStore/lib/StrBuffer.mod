MODULE StrBuffer;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Linear string buffer.
  --
  The pure algorithmic part: the buffer itself and the state are provided
  by the client module.
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  TYPE
    State* = RECORD
      writeIx: INTEGER
    END;

  PROCEDURE* Init*(VAR state: State);
  BEGIN
    state.writeIx := 0
  END Init;


  PROCEDURE* Reset*(VAR state: State);
  BEGIN
    state.writeIx := 0
  END Reset;


  PROCEDURE* Put*(VAR state: State; VAR buf: ARRAY OF CHAR; str: ARRAY OF CHAR; numChar: INTEGER);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE (i < numChar) & (state.writeIx < LEN(buf)) DO
      buf[state.writeIx] := str[i];
      INC(i); INC(state.writeIx)
    END
  END Put;


  PROCEDURE* Get*(VAR state: State; VAR buf: ARRAY OF CHAR; VAR str: ARRAY OF CHAR; VAR numChar: INTEGER);
  BEGIN
    numChar := 0;
    WHILE (numChar < state.writeIx) & (numChar < LEN(str)) DO
      str[numChar] := buf[numChar];
      INC(numChar)
    END;
  END Get;

END StrBuffer.
