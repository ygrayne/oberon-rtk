MODULE Texts;
(**
  Oberon RTK Framework
  Formatted output to a "channel", ie. using a 'TextIO.Writer'
  Input coming soon...
  --
  These procedure are re-entrant, if the TextIO.Writer's procedures are.
  The write string procedures are used as much as possible, to profit of buffering.
  --
  Copyright (c) 2020 - 2023 Gray gray@grayraven.org
**)

  IMPORT TextIO, Error;

  CONST
    CR = 0DX;
    LF = 0AX;
    Blanks = "                                "; (* 32 blanks *)
    MaxBlanks = 32;
    MinIntPlusOne = -2147483647;

  VAR crlf: ARRAY 2 OF CHAR; (* module vars OK, as read only *)


  PROCEDURE IntToString*(int: INTEGER; VAR str: ARRAY OF CHAR; VAR slen: INTEGER);
    VAR spos, dpos: INTEGER; digits: ARRAY 10 OF CHAR;
  BEGIN
    ASSERT(int >= MinIntPlusOne, Error.PreCond);
    ASSERT(LEN(str) >= 12, Error.PreCond); (* 10 digits, minus sign, 0X *)
    spos := 0;
    IF int < 0 THEN
      int := -int;
      str[spos] := "-";
      INC(spos)
    END;
    dpos := 0;
    REPEAT
      digits[dpos] := CHR(int MOD 10 + ORD("0"));
      int := int DIV 10;
      INC(dpos)
    UNTIL int = 0;
    DEC(dpos);
    WHILE dpos >= 0 DO
      str[spos] := digits[dpos];
      DEC(dpos); INC(spos)
    END;
    str[spos] := 0X;
    slen := spos
  END IntToString;


  PROCEDURE IntToHexString*(int: INTEGER; VAR str: ARRAY OF CHAR; VAR slen: INTEGER);
    VAR dpos, spos, d: INTEGER; digits: ARRAY 10 OF CHAR;
  BEGIN
    ASSERT(LEN(str) >= 10, Error.PreCond);
    dpos := 0;
    REPEAT
      d := int MOD 010H;
      IF d < 10 THEN
        digits[dpos] := CHR(d + ORD("0"))
      ELSE
        digits[dpos] := CHR(d - 10 + ORD("A"))
      END;
      int := int DIV 010H;
      INC(dpos)
    UNTIL dpos = 8;
    DEC(dpos); spos := 0;
    WHILE dpos >= 0 DO
      str[spos] := digits[dpos];
      DEC(dpos); INC(spos)
    END;
    str[8] := "H";
    slen := 9
  END IntToHexString;


  PROCEDURE IntToBinString*(int: INTEGER; VAR str: ARRAY OF CHAR; VAR slen: INTEGER);
    VAR
      i, j, k: INTEGER;
      bits: SET;
  BEGIN
    ASSERT(LEN(str) >= 36, Error.PreCond);
    k := 0;
    FOR i := 0 TO 3 DO
      bits := BITS(BFX(int, 31, 24));
      int := LSL(int, 8);
      FOR j := 7 TO 0 BY -1 DO
        IF j IN bits THEN str[k] := "1" ELSE str[k] := "0" END;
        INC(k)
      END;
      str[k] := " ";
      INC(k)
    END;
    str[35] := 0X;
    slen := 35
  END IntToBinString;


  PROCEDURE Write*(W: TextIO.Writer; ch: CHAR);
  BEGIN
    W.putChar(W.dev, ch)
  END Write;


  PROCEDURE WriteString*(W: TextIO.Writer; s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE (s[i] # 0X) & (i < LEN(s)) DO INC(i) END;
    W.putString(W.dev, s, i)
  END WriteString;


  PROCEDURE WriteLn*(W: TextIO.Writer);
  BEGIN
    W.putString(W.dev, crlf, 2)
  END WriteLn;


  PROCEDURE writeNumString(W: TextIO.Writer; s: ARRAY OF CHAR; numChars, leftPadding: INTEGER);
  BEGIN
    IF leftPadding > MaxBlanks THEN leftPadding := MaxBlanks END;
    IF leftPadding > 0 THEN
      W.putString(W.dev, Blanks, leftPadding)
    END;
    W.putString(W.dev, s, numChars)
  END writeNumString;


  PROCEDURE WriteInt*(W: TextIO.Writer; n, width: INTEGER);
    VAR buffer: ARRAY 12 OF CHAR; strLen: INTEGER;
  BEGIN
    IntToString(n, buffer, strLen);
    writeNumString(W, buffer, strLen, width - strLen)
  END WriteInt;


  PROCEDURE WriteHex*(W: TextIO.Writer; n, width: INTEGER);
    VAR buffer: ARRAY 12 OF CHAR; strLen: INTEGER;
  BEGIN
    IntToHexString(n, buffer, strLen);
    writeNumString(W, buffer, strLen, width - strLen)
  END WriteHex;


  PROCEDURE WriteBin*(W: TextIO.Writer; n, width: INTEGER);
    VAR buffer: ARRAY 36 OF CHAR; strLen: INTEGER;
  BEGIN
    IntToBinString(n, buffer, strLen);
    writeNumString(W, buffer, strLen, width - strLen)
  END WriteBin;

BEGIN
  crlf[0] := CR; crlf[1] := LF
END Texts.
