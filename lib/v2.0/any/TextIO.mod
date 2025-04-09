MODULE TextIO;
(**
  Oberon RTK Framework v2
  --
  Text IO channels using writers and readers
  --
  * Device as abstraction for hardware IO peripheral devices.
  * Writer to use in output modules, eg. Texts
  * Reader to use in input modules, eg. Texts
  --
  Copyright (c) 2020-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Errors;

  CONST
    (* status/error codes *)
    NoError* = 0;
    BufferOverflow* = 1;
    SyntaxError* = 2;
    OutOfLimits* = 3;
    NoInput* = 4;
    FifoOverrun* = 5;

    EOL* = 0AX; (* LF *)

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD END;

    PutStringProc* = PROCEDURE(dev: Device; string: ARRAY OF CHAR; numChar: INTEGER);
    GetStringProc* = PROCEDURE(dev: Device; VAR string: ARRAY OF CHAR; VAR numChar, res: INTEGER);
    FlushOutProc* = PROCEDURE(dev: Device);

    Writer* = POINTER TO WriterDesc;
    WriterDesc* = RECORD
      dev*: Device;
      putString*: PutStringProc;
      flush*: FlushOutProc
    END;

    Reader* = POINTER TO ReaderDesc;
    ReaderDesc* = RECORD
      dev*: Device;
      getString*: GetStringProc
    END;


  PROCEDURE OpenWriter*(w: Writer; dev: Device; psp: PutStringProc);
  BEGIN
    ASSERT(w # NIL, Errors.PreCond);
    w.dev := dev;
    w.putString := psp;
    w.flush := NIL
  END OpenWriter;


  PROCEDURE* InstallFlushOutProc*(w: Writer; fp: FlushOutProc);
  BEGIN
    ASSERT(w # NIL, Errors.PreCond);
    w.flush := fp
  END InstallFlushOutProc;


  PROCEDURE OpenReader*(r: Reader; dev: Device; gsp: GetStringProc);
  BEGIN
    ASSERT(r # NIL, Errors.PreCond);
    r.dev := dev;
    r.getString := gsp
  END OpenReader;

END TextIO.
