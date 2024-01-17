MODULE TextIO;
(**
  Oberon RTK Framework
  Text IO channels using writers and readers
  --
  * writer to use in output modules, eg. Texts
  * reader to use in input modules, eg. Texts
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Error;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD END;

    PutStringProc* = PROCEDURE(dev: Device; string: ARRAY OF CHAR; numChar: INTEGER);
    GetStringProc* = PROCEDURE(dev: Device; VAR string: ARRAY OF CHAR; del: CHAR);

    Writer* = POINTER TO WriterDesc;
    WriterDesc* = RECORD
      dev*: Device;
      putString*: PutStringProc
    END;

    Reader* = POINTER TO ReaderDesc;
    ReaderDesc* = RECORD
      dev*: Device;
      getString*: GetStringProc
    END;


  PROCEDURE OpenWriter*(w: Writer; dev: Device; psp: PutStringProc);
  BEGIN
    ASSERT(w # NIL, Error.PreCond);
    w.dev := dev;
    w.putString := psp
  END OpenWriter;


  PROCEDURE OpenReader*(r: Reader; dev: Device; gsp: GetStringProc);
  BEGIN
    ASSERT(r # NIL, Error.PreCond);
    r.dev := dev;
    r.getString := gsp
  END OpenReader;

END TextIO.
