MODULE Error;
(* =========================================================================
   Error - General library module assertion error codes

   (c) 2019-2024 CFB Software
   https://www.astrobe.com

  ========================================================================= *)

CONST

  maxMsgLen   = 64;
  first       = 1;

  (* Runtime codes *)
  rtIndex     = 1;
  typeTest    = 2;
  arrayLen    = 3;
  case        = 4;
  nilProc     = 5;
  strLen      = 6;
  intDiv      = 7;
  fpuExp      = 8;
  fpuOverflow = 9;
  fpuNull     = 10;
  heap        = 11;
  nilPtr      = 12;
  unused      = {13..19};

  (* Library codes *)
  input*    = 20; (* Input parameter has an unexpected value *)
  data*     = 21; (* Data has an unexpected value *)
  index*    = 22; (* Index out of bounds *)
  version*  = 23; (* Version check failed *)
  timeout*  = 24; (* Timeout value exceeded *)
  undefinedProc* = 25; (* Procedure variable not yet defined *)
  last           = 25;

TYPE
  String* = ARRAY maxMsgLen OF CHAR;
  ErrorMsgProc* = PROCEDURE (error: INTEGER; VAR msg: String);

VAR
  Msg*: ErrorMsgProc;

PROCEDURE* StdMsg(error: INTEGER; VAR msg: String);
BEGIN
  IF (error < first) OR (error > last) OR (error IN unused) THEN
    msg := ""
  ELSE
    CASE error OF
    | typeTest:
        msg := "type test failure"
    | arrayLen:
        msg := "arrays are not the same length"
    | strLen:
        msg := "strings are not the same length"
    | intDiv:
        msg := "integer divided by zero or negative divisor"
    | fpuExp, fpuOverflow, fpuNull:
        msg := "FPU error"
    | heap:
        msg := "heap overflow"
    | nilPtr:
        msg := "attempt to dispose a NIL pointer"
    | case:
        msg := "invalid value in case statement"
    | input:
        msg := "input parameter has an unexpected value"
    | data:
        msg := "data has an unexpected value"
    | rtIndex, index:
        msg := "index out of bounds"
    | version:
        msg := "version check failed"
    | timeout:
        msg := "timeout value exceeded"
    | nilProc, undefinedProc:
        msg := "undefined procedure variable"
    END
  END
END StdMsg;

BEGIN
  Msg := StdMsg
END Error.
