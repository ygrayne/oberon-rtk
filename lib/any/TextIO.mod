MODULE TextIO;
(**
  Oberon RTK Framework
  Text IO channels using writers and readers
  --
  * writer to use in output modules, eg. Texts
  * reader to use in input modules, eg. Texts (coming soon)
  --
  Copyright (c) 2023 Gray gray@grayraven.org
**)

  IMPORT Error;

  TYPE
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD END;

    PutCharProc* = PROCEDURE(dev: Device; ch: CHAR);
    GetCharProc* = PROCEDURE(dev: Device; VAR ch: CHAR);
    PutStringProc* = PROCEDURE(dev: Device; string: ARRAY OF CHAR; numChar: INTEGER);

    Writer* = POINTER TO WriterDesc;
    WriterDesc* = RECORD
      dev*: Device;
      putChar*: PutCharProc;
      putString*: PutStringProc
    END;

    Reader* = POINTER TO ReaderDesc;
    ReaderDesc* = RECORD
      dev*: Device;
      getChar*: GetCharProc
    END;


  PROCEDURE OpenWriter*(w: Writer; dev: Device; pcp: PutCharProc; psp: PutStringProc);
  BEGIN
    ASSERT(w # NIL, Error.PreCond);
    w.dev := dev;
    w.putChar := pcp;
    w.putString := psp
  END OpenWriter;


  PROCEDURE OpenReader*(r: Reader; dev: Device; gcp: GetCharProc);
  BEGIN
    ASSERT(r # NIL, Error.PreCond);
    r.dev := dev;
    r.getChar := gcp
  END OpenReader;

END TextIO.
