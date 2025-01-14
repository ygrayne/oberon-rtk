MODULE Texts;
(**
  Oberon RTK Framework v2
  --
  Formatted output to a "channel", using a 'TextIO.Writer'
  Formatted input from a "channel", using a 'TextIO.Reader'
  --
  The behaviour of the procedures depends on the write string and read
  procedures allocated to 'W' and 'R' parameters:
  * blocking
  * non-blocking (using the kernel)
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT TextIO, Errors;

  CONST
    CR = 0DX;
    LF = 0AX;
    Blanks = "                                "; (* 32 blanks *)
    MaxBlanks = 32;

    (* conversion constants *)
    MaxInt* = 07FFFFFFFH; (*  2,147,483,647 *)
    MinInt* = 080000000H; (* -2,147,483,648 *)
    MaxIntDigits* = 10;   (* sans sign, sans leading zeros *)

    (* read results *)
    NoError* = TextIO.NoError;
    BufferOverflow* = TextIO.BufferOverflow; (* a tool small buffer was provided or used *)
    SyntaxError* = TextIO.SyntaxError;      (* zero length or non-numerical chars *)
    OutOfLimits* = TextIO.OutOfLimits;    (* bigger than MaxInt, smaller than MinInt *)
    NoInput* = TextIO.NoInput;
    FifoOverrun* = TextIO.FifoOverrun;

  VAR eol: ARRAY 2 OF CHAR;

  (* write conversions *)

  PROCEDURE IntToString*(int: INTEGER; VAR str: ARRAY OF CHAR; VAR slen: INTEGER);
    VAR spos, dpos: INTEGER; digits: ARRAY 10 OF CHAR;
  BEGIN
    ASSERT(LEN(str) >= 12, Errors.PreCond); (* 10 digits, minus sign, 0X *)
    IF int = 080000000H THEN
      str := "-2147483648";
      str[11] := 0X;
      slen := 11
    ELSE
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
    END
  END IntToString;


  PROCEDURE IntToHexString*(int: INTEGER; VAR str: ARRAY OF CHAR; VAR slen: INTEGER);
    VAR dpos, spos, d: INTEGER; digits: ARRAY 10 OF CHAR;
  BEGIN
    ASSERT(LEN(str) >= 10, Errors.PreCond);
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
    str[9] := 0X;
    slen := 9
  END IntToHexString;


  PROCEDURE IntToBinString*(int: INTEGER; VAR str: ARRAY OF CHAR; VAR slen: INTEGER);
    VAR
      i, j, k: INTEGER;
      bits: SET;
  BEGIN
    ASSERT(LEN(str) >= 36, Errors.PreCond);
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

  (* write *)

  PROCEDURE Write*(W: TextIO.Writer; ch: CHAR);
    VAR s: ARRAY 1 OF CHAR;
  BEGIN
    s[0] := ch;
    W.putString(W.dev, s, 1)
  END Write;


  PROCEDURE WriteString*(W: TextIO.Writer; str: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE (i < LEN(str)) & (str[i] # 0X) DO INC(i) END;
    W.putString(W.dev, str, i)
  END WriteString;


  PROCEDURE WriteLn*(W: TextIO.Writer);
  BEGIN
    W.putString(W.dev, eol, 2)
  END WriteLn;


  PROCEDURE writeNumString(W: TextIO.Writer; str: ARRAY OF CHAR; numChars, leftPadding: INTEGER);
  BEGIN
    IF leftPadding > MaxBlanks THEN leftPadding := MaxBlanks END;
    IF leftPadding > 0 THEN
      W.putString(W.dev, Blanks, leftPadding)
    END;
    W.putString(W.dev, str, numChars)
  END writeNumString;


  PROCEDURE WriteInt*(W: TextIO.Writer; int, width: INTEGER);
  (**
    Write an integer value in decimal form via 'W'.
  **)
    VAR buffer: ARRAY 12 OF CHAR; strLen: INTEGER;
  BEGIN
    IntToString(int, buffer, strLen);
    writeNumString(W, buffer, strLen, width - strLen)
  END WriteInt;


  PROCEDURE WriteHex*(W: TextIO.Writer; int, width: INTEGER);
    VAR buffer: ARRAY 12 OF CHAR; strLen: INTEGER;
  BEGIN
    IntToHexString(int, buffer, strLen);
    writeNumString(W, buffer, strLen, width - strLen)
  END WriteHex;


  PROCEDURE WriteBin*(W: TextIO.Writer; int, width: INTEGER);
    VAR buffer: ARRAY 36 OF CHAR; strLen: INTEGER;
  BEGIN
    IntToBinString(int, buffer, strLen);
    writeNumString(W, buffer, strLen, width - strLen)
  END WriteBin;

  (* read conversions *)

  PROCEDURE cleanLeft(str: ARRAY OF CHAR; VAR first: INTEGER; VAR neg: BOOLEAN);
    VAR ch: CHAR;
  BEGIN
    first := 0;
    WHILE str[first] = " " DO INC(first) END;
    ch := str[first];
    neg := ch = "-";
    IF (ch = "-") OR (ch = "+") THEN INC(first) END;
    WHILE str[first] = " " DO INC(first) END;
    WHILE str[first] = "0" DO INC(first) END;
  END cleanLeft;

  PROCEDURE cleanRight(str: ARRAY OF CHAR; numCh: INTEGER; VAR last: INTEGER);
  BEGIN
    last := numCh - 1;
    WHILE str[last] = " " DO
      DEC(last)
    END
  END cleanRight;


  PROCEDURE StrToInt*(str: ARRAY OF CHAR; numCh: INTEGER; VAR int: INTEGER; VAR res: INTEGER);
  (* rolls over at 0100000000H = 2^32 *)
    VAR first, last, digit: INTEGER; neg: BOOLEAN; ch: CHAR;
  BEGIN
    res := NoError;
    cleanLeft(str, first, neg);
    IF numCh - first > MaxIntDigits THEN
      res := OutOfLimits;
    END;
    IF res = NoError THEN
      cleanRight(str, numCh, last);
      int := 0;
      WHILE (first <= last) & (res = NoError) DO
        ch := str[first];
        IF (ch < "0") OR (ch > "9") THEN
          res := SyntaxError;
        ELSE
          digit := ORD(ch) - ORD("0");
          int := (int * 10) + digit;
          IF MaxInt - int < 0 THEN  (* works across overflow *)
            IF neg & (int = MinInt) THEN
              neg := FALSE
            ELSE
              res := OutOfLimits
            END
          END;
          INC(first)
        END
      END
    END;
    IF res = NoError THEN
      IF neg THEN int := -int END
    END
  END StrToInt;

  (* read *)

  PROCEDURE ReadString*(R: TextIO.Reader; VAR s: ARRAY OF CHAR; VAR res: INTEGER);
  (**
    Read a string via 'R', terminated by 'TextIO.EOL'.
    Flush the rest of the input in case of buffer overflow.
    The string is truncated to the buffer length, terminated by 0X.
  **)
    VAR numCh: INTEGER;
  BEGIN
    R.getString(R.dev, s, numCh, res);
    IF res = NoError THEN
      IF numCh = 0 THEN
        res := NoInput
      END
    END
  END ReadString;


  PROCEDURE ReadInt*(R: TextIO.Reader; VAR int, res: INTEGER);
  (**
    Read an integer in decimal form via 'R', terminated by 'TextIO.EOL'.
    Flush the rest of the input in case of buffer overflow.
    The number is not valid in case of any error.
    As long as there's no buffer overflow or fifo overrrun, any number of leading
    blanks, blanks after the sign, leading zeros, and trailing blanks are permitted.
  **)
    VAR numCh: INTEGER; buf: ARRAY 32 OF CHAR;
  BEGIN
    R.getString(R.dev, buf, numCh, res);
    IF res = NoError THEN
      IF numCh > 0 THEN
        StrToInt(buf, numCh, int, res)
      ELSE
        res := NoInput
      END
    END
  END ReadInt;


  PROCEDURE FlushOut*(W: TextIO.Writer);
  (**
    Allow flushing on writers that don't need it to keep
    program code independent of output channel if needed.
  **)
  BEGIN
    IF W.flush # NIL THEN
      W.flush(W.dev)
    END
  END FlushOut;

BEGIN
  eol[0] := CR; eol[1] := LF
END Texts.
