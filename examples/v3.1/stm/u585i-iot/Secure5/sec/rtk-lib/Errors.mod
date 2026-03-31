MODULE Errors;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Definition of fault and error codes and corresponding message strings.
  --
  Copyright (c) 2019-2025 Gray, gray@grayraven.org
**)

  IMPORT Error;

  CONST
    MaxMsgLength = 64;
    OK* = 0;
    NoError* = 0;
    NotOK* = 1;
    MaxErrNo* = 63;

    (* MCU fault codes *)
    (* all *)
    NMI*          = 2;
    HardFault*    = 3;
    (* M33 only *)
    MemMgmtFault* = 4;
    BusFault*     = 5;
    UsageFault*   = 6;
    SecureFault*  = 7;
    DebugMon*     = 12;

    (* error types *)
    ErrTypeErrorHandler* = 0;
    ErrTypeErrorThread* = 1;
    ErrTypeFaultHandler* = 2;
    ErrTypeFaultThread* = 3;

    (* Astrobe error codes, see Error.mod *)
    FirstAstrobeCode = 1;
    AstrobeUnused = {13..19};
    LastAstrobeCode  = 25;

    (* RTK error/assert codes *)
    FirstRTKcode = 33;
    Trace* = 33;
    PreCond* = 34;
    PostCond* = 35;
    ConsCheck* = 36;
    ProgError* = 37;
    BufferOverflow* = 38;
    BufferEmpty* = 39;
    TimingError* = 40;
    HeapOverflow* = 41;
    StackOverflow* = 42;
    StorageOverflow* = 43;
    StorageError* = 44;
    UsageError* = 45;
    DeviceError* = 46;
    BadResourceData* = 47;
    NotSupported* = 48;
    NotImplemented* = 49;
    NumThreads* = 50;
    SecureError* = 51;
    AlignmentError* = 52;
    BootromError* = 53;
    LastRTKcode = 53;

    Config* = ProgError; (* legacy *)

  TYPE
    String* = ARRAY MaxMsgLength OF CHAR;


  PROCEDURE* faultMessage(code: INTEGER; VAR msg: String);
  BEGIN
    IF code = NMI THEN
      msg := "NMI"
    ELSIF code = HardFault THEN
      msg := "HardFault"
    ELSIF code = MemMgmtFault THEN
      msg := "MemManageFault"
    ELSIF code = BusFault THEN
      msg := "BusFault"
    ELSIF code = UsageFault THEN
      msg := "UsageFault"
    ELSIF code = SecureFault THEN
      msg := "SecureFault"
    ELSIF code = DebugMon THEN
      msg := "DebugFault"
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
      | ProgError:
          msg := "program design error"
      | BufferOverflow:
          msg := "buffer overflow"
      | BufferEmpty:
          msg := "buffer empty"
      | TimingError:
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
      | BadResourceData:
          msg := "program resource data inconsistent"
      | NotSupported:
          msg := "functionality not supported"
      | NotImplemented:
          msg := "functionality not (yet) implemented"
      | NumThreads:
          msg := "too many threads"
      | SecureError:
          msg := "secure violation"
      | AlignmentError:
          msg := "memory alignment error"
      | BootromError:
          msg := "bootrom error"
      END
    ELSIF (code >= FirstAstrobeCode) & (code <= LastAstrobeCode) & ~(code IN AstrobeUnused) THEN
      Error.Msg(code, msg)
    ELSE
      msg := "unknown error"
    END
  END errorMessage;


  PROCEDURE GetErrorMsg*(errType, errCode: INTEGER; VAR msg: String);
  BEGIN
    IF errType >= 2 THEN
      faultMessage(errCode, msg)
    ELSE
      errorMessage(errCode, msg)
    END
  END GetErrorMsg;


  PROCEDURE GetErrorType*(excType: INTEGER; VAR msg: String);
  BEGIN
    IF excType = ErrTypeErrorHandler THEN
      msg := "run-time error in handler mode"
    ELSIF excType = ErrTypeErrorThread THEN
      msg := "run-time error in thread mode"
    ELSIF excType = ErrTypeFaultHandler THEN
      msg := "MCU fault in handler mode"
    ELSIF excType = ErrTypeFaultThread THEN
      msg := "MCU fault in thread mode"
    ELSE
      msg := "unknown exception"
    END
  END GetErrorType;

END Errors.
