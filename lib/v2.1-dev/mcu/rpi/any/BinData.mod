MODULE BinData;
(**
  Oberon RTK Framework v2
  --
  Access binary resource data.
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
  --
  Structure:
  resource header -- at Config.ResourceStart
  entry
  entry
  ...
  resource header
  entry
  ...

  Resource header:
  offset    value         meaning                           CONST
   0        05237424FH    id = "OB7R" as int
   4        000000001H    version                           ResVersionOffset
   8        06665722EH    ".ref" as int, resource name      ResNameOffset
  20                      resource size in bytes            ResSizeOffset
  24                      first entry: module LinkOptions   ResDataOffset

  Notes:
  * Resource name is not null-terminated.
**)

  IMPORT SYSTEM, Config;

  CONST
    ResId = 05237424FH; (* "OB7R" little endian *)
    ResVersion = 1;

    ResVersionOffset = 4;
    ResNameOffset = 8;
    ResSizeOffset = 20;
    ResDataOffset = 24;

  TYPE
    ResName* = ARRAY 12 OF CHAR;

    BinDataRes* = RECORD
      resAddr*: INTEGER;
      dataBeginAddr*: INTEGER;
      dataEndAddr*: INTEGER;
      size*: INTEGER;
      curAddr*, cnt*: INTEGER
    END;

  (* -- init -- *)

  PROCEDURE* getResName(resAddr: INTEGER; VAR name: ResName);
    VAR i, nameAddr: INTEGER; s: ARRAY 4 OF CHAR;
  BEGIN
    nameAddr := resAddr + ResNameOffset;
    SYSTEM.GET(nameAddr, s);
    FOR i := 0 TO 3 DO name[i] := s[i] END;
    INC(nameAddr, 4);
    SYSTEM.GET(nameAddr, s);
    FOR i := 0 TO 3 DO name[i + 4] := s[i] END;
    name[8] := 0X
  END getResName;


  PROCEDURE GetBinDataRes*(resName: ARRAY OF CHAR; VAR res: BinDataRes);
    VAR resAddr, resSize, resId, resVersion: INTEGER; found: BOOLEAN; resName0: ResName;
  BEGIN
    CLEAR(res);
    resAddr := Config.ResourceStart;
    SYSTEM.GET(resAddr, resId);
    SYSTEM.GET(resAddr + ResVersionOffset, resVersion);
    IF (resId = ResId) & (resVersion = ResVersion) THEN
      found := FALSE;
      WHILE (resId = ResId) & ~found DO
        getResName(resAddr, resName0);
        SYSTEM.GET(resAddr + ResSizeOffset, resSize);
        found := resName0 = resName;
        IF found THEN
          res.resAddr := resAddr;
          res.size := resSize;
          res.dataBeginAddr := resAddr + ResDataOffset;
          res.dataEndAddr := res.dataBeginAddr + resSize;
          res.curAddr := res.dataBeginAddr
        ELSE
          resAddr := resAddr + ResDataOffset + resSize;
          SYSTEM.GET(resAddr, resId)
        END
      END
    END
  END GetBinDataRes;


  PROCEDURE NextByte*(VAR res: BinDataRes; VAR done: BOOLEAN): BYTE;
    VAR val: BYTE;
  BEGIN
    SYSTEM.GET(res.curAddr, val);
    INC(res.curAddr); INC(res.cnt);
    done := res.curAddr = res.dataEndAddr;
    RETURN val
  END NextByte;

END BinData.
