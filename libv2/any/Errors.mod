MODULE Errors;
(**
  Oberon RTK Framework v2
  --
  Definition of fault and error codes and corresponding message strings.
  --
  Copyright (c) 2019-2024 Gray, gray@grayraven.org
**)

  IMPORT Error, MCU := MCU2;

  CONST
    MaxMsgLength = 64;
    OK* = 0;
    NoError* = 0;
    NotOK* = 1;

    (* MCU fault codes *)
    (* all *)
    NMI*          = -MCU.PPB_NMI_Exc;
    HardFault*    = -MCU.PPB_HardFault_Exc;
    (* M33 only *)
    MemMgmtFault* = -MCU.PPB_MemMgmtFault_Exc;
    BusFault*     = -MCU.PPB_BusFault_Exc;
    UsageFault*   = -MCU.PPB_UsageFault_Exc;
    SecureFault*  = -MCU.PPB_SecureFault_Exc;
    DebugMon*     = -MCU.PPB_DebugMon_Exc;

    (* Astrobe error codes, see Error.mod *)
    FirstAstrobeCode = 1;
    AstrobeUnused = {13..19};
    LastAstrobeCode  = 25;

    (* RTK error/assert codes *)
    FirstRTKcode = 100;
    Trace* = 100;
    PreCond* = 101;
    PostCond* = 102;
    ConsCheck* = 103;
    ProgError* = 104;
    BufferOverflow* = 105;
    BufferEmpty* = 106;
    Timing* = 107;
    HeapOverflow* = 108;
    StackOverflow* = 109;
    StorageOverflow* = 110;
    StorageError* = 111;
    UsageError* = 112;
    DeviceError* = 113;
    BadResourceData* = 114;
    NotSupported* = 115;
    NotImplemented* = 116;
    NumThreads* = 117;
    LastRTKcode = 117;

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
      | BadResourceData:
          msg := "program resource data inconsistent"
      | NotSupported:
          msg := "functionality not supported"
      | NotImplemented:
          msg := "functionality not (yet) implemented"
      | NumThreads:
          msg := "too many threads"
      END
    ELSIF (code >= FirstAstrobeCode) & (code <= LastAstrobeCode) & ~(code IN AstrobeUnused) THEN
      Error.Msg(code, msg)
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

END Errors.
