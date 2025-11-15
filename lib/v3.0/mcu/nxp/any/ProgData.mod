MODULE ProgData;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Get data about the program from the '.ref' resource data block
  at the end of the program.
  --
  MCU: MCX-A346, MCX-N947
  --
  Copyright (c) 2024-2025 Gray, gray@grayraven.org
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

  Resource entry, example LinkOptions:
  offset    value         meaning
   0        000000000H    entry type: module = 0
   4        06B6E694CH    "Link" as int
   8        06974704FH    "Opti" as int
  12        000736E6FH    "ons" + OX as int
  16        000000000H    0X as int
  20        010000340H    code address

  Resource entry, example LinkOptions.CodeStartAddress:
  offset    value         meaning                         CONST
   0        000000000H    entry type: proc = 1, 2, ...
   4        065646F43H    "Code" as int                   EntryStringOffset
   8        072617453H    "Star" as int
  12        064644174H    "tAdd" as int
  16        000736572H    "res" + OX as int
  20        010000344H    code address                    EntryAddrOffset

  Module block:
  module 0 (type = 0)
    procedure 1 (type = 1)
    procedure 2 (type = 2)
    ...
    procedure .init (type = n)
  module 1 (type = 0)
    procedure 1 (type = 1)
    procedure 2 (type = 2)
    ...
    procedure .init (type = n)

  Notes:
  * Entry  type:
    module = 0
    procedure > 0, ie. 1, 2, 3, ... enumerated within module
  * Entry string is terminated by a null char.
  * Hence max string length is (4 x 4) - 1 = 15 chars
  * Entry string memory addresses can contain garbage, but this is always separated
    by a null char from the entry string, for example:
    0696E692EH  ".ini"
    072610074H  "t"     <= null char here: '0074'
    064644174H  "tAdd"  <= garbage
    000736572H  "res"
  * Resource name is not null-terminated.
  * The last entry is always the program's '.init' procedure. Any 'bl.w' address beyond the
    .inits code address cannot be identified, namely in the start-up sequence.
**)

  IMPORT SYSTEM, Config;

  CONST
    ProgResName = ".ref";
    ResId = 05237424FH; (* "OB7R" little endian *)
    ResVersion = 1;

    ResVersionOffset = 4;
    ResNameOffset = 8;
    ResSizeOffset = 20;
    ResDataOffset = 24;

    EntrySize = 6 * 4;

    EntryStringOffset = 4;
    EntryAddrOffset = 5 * 4;
    NextEntryAddrOffset = EntryAddrOffset + EntrySize;
    EntryStringLen = 16;
    EntryTypeModule = 0;

  TYPE
    ResName = ARRAY 12 OF CHAR;
    EntryString* = ARRAY EntryStringLen OF CHAR;

    ProgDataRes = RECORD
      resAddr: INTEGER;
      dataBeginAddr: INTEGER;
      dataEndAddr: INTEGER;
      size: INTEGER
    END;

    VAR
      progDataRes: ProgDataRes;


  PROCEDURE* FindEntry*(codeAddr: INTEGER; VAR entryAddr: INTEGER);
    VAR ca: INTEGER; found: BOOLEAN;
  BEGIN
    entryAddr := 0;
    IF progDataRes.resAddr # 0 THEN
      found := FALSE;
      entryAddr := progDataRes.dataBeginAddr;
      WHILE (entryAddr < progDataRes.dataEndAddr) & ~found DO
        found := entryAddr + NextEntryAddrOffset > progDataRes.dataEndAddr; (* at last entry *)
        IF ~found THEN
          SYSTEM.GET(entryAddr + NextEntryAddrOffset, ca);
          found := codeAddr < ca
        END;
        IF ~found THEN
          entryAddr := entryAddr + EntrySize
        END
      END
    END
  END FindEntry;


  PROCEDURE* GetNextEntry*(thisEntryAddr: INTEGER; VAR nextEntryAddr: INTEGER);
  BEGIN
    nextEntryAddr := 0;
    IF thisEntryAddr + NextEntryAddrOffset < progDataRes.dataEndAddr THEN
      nextEntryAddr := thisEntryAddr + EntrySize
    END
  END GetNextEntry;


  PROCEDURE* FindProcEntries*(codeAddr: INTEGER; VAR modEntryAddr, procEntryAddr: INTEGER);
  (* will return '.init' of the program for all 'codeAddr' >= .init's code address *)
  (* this is a limitation of the available program meta data *)
    VAR entryAddr, etype, ca: INTEGER; found: BOOLEAN;
  BEGIN
    IF progDataRes.resAddr # 0 THEN
      found := FALSE;
      entryAddr := progDataRes.dataBeginAddr;
      modEntryAddr := 0; procEntryAddr := 0;
      WHILE (entryAddr < progDataRes.dataEndAddr) & ~found DO
        found := entryAddr + NextEntryAddrOffset > progDataRes.dataEndAddr; (* at last entry *)
        IF ~found THEN
          SYSTEM.GET(entryAddr + NextEntryAddrOffset, ca);
          found := codeAddr < ca
        END;
        SYSTEM.GET(entryAddr, etype);
        IF found THEN
          procEntryAddr := entryAddr;
        ELSIF etype = EntryTypeModule THEN
          modEntryAddr := entryAddr
        END;
        entryAddr := entryAddr + EntrySize
      END
    END
  END FindProcEntries;


  PROCEDURE* GetCodeAddr*(entryAddr: INTEGER; VAR codeAddr: INTEGER);
  BEGIN
    SYSTEM.GET(entryAddr + EntryAddrOffset, codeAddr)
  END GetCodeAddr;


  PROCEDURE* GetString*(entryAddr: INTEGER; VAR s: EntryString);
    VAR stringAddr, i: INTEGER; b: BYTE;
  BEGIN
    stringAddr := entryAddr + EntryStringOffset;
    i := 0;
    WHILE i < EntryStringLen DO
      SYSTEM.GET(stringAddr + i, b);
      s[i] := CHR(b);
      INC(i)
    END
  END GetString;


  PROCEDURE GetNames*(modEntryAddr, procEntryAddr: INTEGER; VAR modName, procName: EntryString);
  BEGIN
    IF procEntryAddr # 0 THEN
      GetString(procEntryAddr, procName);
    ELSE
      procName := "Unknown"
    END;
    IF modEntryAddr # 0 THEN
      GetString(modEntryAddr, modName)
    ELSE
      modName := "Unknown"
    END
  END GetNames;

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


  PROCEDURE getProgDataRes(VAR res: ProgDataRes);
    VAR resAddr, resSize, resId, resVersion: INTEGER; found: BOOLEAN; resName: ResName;
  BEGIN
    CLEAR(res);
    resAddr := Config.ResMem.start;
    SYSTEM.GET(resAddr, resId);
    SYSTEM.GET(resAddr + ResVersionOffset, resVersion);
    IF (resId = ResId) & (resVersion = ResVersion) THEN
      found := FALSE;
      WHILE (resId = ResId) & ~found DO
        getResName(resAddr, resName);
        SYSTEM.GET(resAddr + ResSizeOffset, resSize);
        found := resName = ProgResName;
        IF found THEN
          res.resAddr := resAddr;
          res.size := resSize;
          res.dataBeginAddr := resAddr + ResDataOffset;
          res.dataEndAddr := res.dataBeginAddr + resSize;
        ELSE
          resAddr := resAddr + ResDataOffset + resSize;
          SYSTEM.GET(resAddr, resId)
        END
      END
    END
  END getProgDataRes;

BEGIN
  getProgDataRes(progDataRes)
END ProgData.
