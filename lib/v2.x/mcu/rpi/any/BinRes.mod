MODULE BinRes;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Access binary resource data.
  --
  MCU: RP2040, RP2350A/B
  --
  Copyright (c) 2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
  --
  Structure:
  resource header -- at Config.ResourceStart
  data
  ...
  resource header
  data
  ...

  Resource header:
  offset    value         meaning                           CONST
   0        05237424FH    id = "OB7R" as int
   4        000000001H    version                           ResVersionOffset
   8        06665722EH    resource name as int              ResNameOffset
  12        000000000H    max 8 chars, no null-char
  16
  20                      resource size in bytes            ResSizeOffset
  24                      start of binary resource data     ResDataOffset
                          meta data = actual binary size

  Note:
  * Resource name is not null-terminated.
  * The resource must be multiple of 4 bytes, hence 'makebres' adds
    padding zeros as needed, hence the resource size can differ
    from the actual binary data size. The latter is encoded
    in the first 4 byte resource data.
**)

  IMPORT SYSTEM, Config;

  CONST
    ResId = 05237424FH; (* "OB7R" little endian *)
    ResVersion = 1;

    ResVersionOffset = 4;
    ResNameOffset = 8;
    ResSizeOffset = 20;
    ResDataOffset = 24;

    MetaDataSize = 4; (* resource data size, first word of binary data *)

  TYPE
    ResName* = ARRAY 12 OF CHAR;

    BinDataRes* = RECORD
      resAddr*: INTEGER;      (* address of resource in program *)
      dataBeginAddr: INTEGER; (* begin of binary data *)
      dataEndAddr: INTEGER;   (* end of binary data *)
      dataSize: INTEGER;      (* size of binary data *)
      (* state while reading via 'NextByte' *)
      curAddr*: INTEGER;      (* address of next data byte *)
      cnt*: INTEGER           (* number of data bytes read *)
    END;


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
  (* res.resAddr # 0 if valid resource found *)
    VAR resAddr, resSize, resId, resVersion: INTEGER; found: BOOLEAN; resName0: ResName;
  BEGIN
    CLEAR(res);
    resAddr := Config.ResMem.start;
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
          res.dataBeginAddr := resAddr + ResDataOffset;
          SYSTEM.GET(res.dataBeginAddr, res.dataSize);
          INC(res.dataBeginAddr, MetaDataSize);
          res.dataEndAddr := res.dataBeginAddr + res.dataSize;
          res.curAddr := res.dataBeginAddr;
          res.cnt := 0
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

END BinRes.
