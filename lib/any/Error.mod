MODULE Error;
(**
  Oberon RTK Framework
  Definition of fault and error codes and corresponding message strings.
  --
  Based on (and compatible with) Astrobe's module 'Error.mod'
  See copyright notice at the bottom.
  --
  Copyright (c) 2019-2021 CFB Software, https://www.astrobe.com
  Copyright (c) 2019-2023 Gray, gray@grayraven.org
**)

  CONST
    MaxMsgLength = 64;
    OK* = 0;
    NotOK* = 1;

    (* MCU fault codes *)
    (* all *)
    NMI* = -2;
    HardFault* = -3;
    (* M3 only *)
    MemMgmtFault* = -4;
    BusFault* = -5;
    UsageFault* = -6;

    (* Astrobe compiler run-time error codes *)
    FirstAstrobeCode = 1;
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
    AstrobeUnused = {13..19};

    (* Astrobe library run-time error codes *)
    input*    = 20;       (* Input parameter has an unexpected value *)
    data*     = 21;       (* Data has an unexpected value *)
    index*    = 22;       (* Index out of bounds *)
    version*  = 23;       (* Version check failed *)
    timeout*  = 24;       (* Timeout value exceeded *)
    undefinedProc* = 25;  (* Procedure variable not yet defined *)
    LastAstrobeCode  = 25;

    (* RTK error/assert codes *)
    FirstRTKcode = 100;
    Trace* = 100;
    PreCond* = 101;
    PostCond* = 102;
    ConsCheck* = 103;
    Config* = 104;
    BufferOverflow* = 105;
    BufferEmpty* = 106;
    Timing* = 107;
    HeapOverflow* = 108;
    StackOverflow* = 109;
    StorageOverflow* = 110;
    StorageError* = 111;
    UsageError* = 112;
    DeviceError* = 113;
    ResourceMissing* = 114;
    NotSupported* = 115;
    NotImplemented* = 116;
    NumThreads* = 117;
    LastRTKcode = 117;

  TYPE
    String* = ARRAY MaxMsgLength OF CHAR;


  PROCEDURE faultMessage(code: INTEGER; VAR msg: String);
  BEGIN
    IF code = NMI THEN
      msg := "NMI"
    ELSIF code = HardFault THEN
      msg := "hard fault"
    ELSIF code = MemMgmtFault THEN
      msg := "memory management fault"
    ELSIF code = BusFault THEN
      msg := "bus fault"
    ELSIF code = UsageFault THEN
      msg := "usage fault"
    ELSE
      msg := "missing exception handler"
    END
  END faultMessage;


  PROCEDURE errorMessage(code: INTEGER; VAR msg: String);
  BEGIN
    IF (code >= FirstRTKcode) & (code <= LastRTKcode) THEN
      CASE code OF
        Trace:
          msg := "stack trace"
      | PreCond:
          msg := "precondition violation"
      | PostCond:
          msg := "postcondition violation"
      | ConsCheck:
          msg := "consistency check violation"
      | Config:
          msg := "configuration error"
      | BufferOverflow:
          msg := "buffer overflow"
      | BufferEmpty:
          msg := "buffer empty"
      | Timing:
          msg := "timing error"
      | HeapOverflow:
          msg := "heap overflow"
      | StackOverflow:
          msg := "stack overflow"
      | StorageOverflow:
          msg := "storage overflow"
      | StorageError:
          msg := "storage error"
      | UsageError:
          msg := "usage error"
      | ResourceMissing:
          msg := "resource missing or faulty"
      | NotSupported:
          msg := "functionality not supported"
      | NotImplemented:
          msg := "functionality not (yet) implemented"
      | NumThreads:
          msg := "too many threads"
      END
    ELSIF (code >= FirstAstrobeCode) & (code <= LastAstrobeCode) & ~(code IN AstrobeUnused) THEN
      CASE code OF
        rtIndex, index:
          msg := "index out of bounds"
      | typeTest:
          msg := "type test failure"
      | arrayLen:
          msg := "arrays are not the same length"
      | case:
          msg := "invalid value in case statement"
      | nilProc, undefinedProc:
          msg := "undefined procedure variable"
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
      | input:
          msg := "input parameter has an unexpected value"
      | data:
          msg := "data has an unexpected value"
      | version:
          msg := "version check failed"
      | timeout:
          msg := "timeout value exceeded"
      END
    ELSE
      msg := "unknown error"
    END
  END errorMessage;


  PROCEDURE Msg*(code: INTEGER; VAR msg: String);
  BEGIN
    IF code < 0 THEN
      faultMessage(code, msg)
    ELSE
      errorMessage(code, msg)
    END
  END Msg;

  PROCEDURE GetExceptionType*(code: INTEGER; VAR msg: String);
  BEGIN
    IF code < 0 THEN
      msg := "mcu fault"
    ELSE
      msg := "run-time error"
    END
  END GetExceptionType;

END Error.

(* =========================================================================
   Error - General library module assertion error codes

   (c) 2019-2021 CFB Software
   https://www.astrobe.com

  Permission to use, copy, modify, and/or distribute this software and its
  accompanying documentation (the "Software") for any purpose with or
  without fee is hereby granted, provided that the above copyright notice
  and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
  WITH REGARD TO THE SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY, FITNESS AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS BE LIABLE FOR ANY CLAIM, SPECIAL, DIRECT, INDIRECT, OR
  CONSEQUENTIAL DAMAGES OR ANY DAMAGES OR LIABILITY WHATSOEVER, WHETHER IN
  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE DEALINGS IN OR USE OR PERFORMANCE OF THE SOFTWARE.
  ========================================================================= *)
