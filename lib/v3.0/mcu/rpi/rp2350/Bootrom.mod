MODULE Bootrom;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Access to the functions ond data in bootrom.
  Additional derived functionality using the raw bootrom API.
  --
  Type: MCU
  --
  MCU: RP2350
  --
  NOTE: API locking is not enabled and implemented
  --
  Calling bootrom functions from Oberon:
  * Cf. Procedure Call Standard for the Arm Architecture, 2023Q3.
    * define corresponding procedure types
    * check assembly code to make sure the parameters and results are passed correctly,
      in particular when Astrobe uses two registers for one parameter
  * Bootrom functions have bit 0 set for thumb code, but Astrobe's
    proc variables contain the actual proc address
    => adjust bootrom function addresses by -1
  --
  Copyright (c) 2024-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  CONST
    MagicAddr = 010H;
    TableAddr = 014H; (* [31:16]: lookup_val function address *)

    LookupFuncArmSec = 004H;
    LookupFuncArmNonSec = 010H;
    LookupData = 040H;

    Magic = 020000H + LSL(ORD("u"), 8) + ORD("M");

    MaxPartitions = 16;

    (* GetSysInfo flags *)
    SI_Chip*       = BITS(001H); (* 3 words: package_id, device_id_lo, device_id_hi *)
    SI_Critical*   = BITS(002H); (* 1 word *)
    SI_CPU*        = BITS(004H); (* 1 word, bytes:  cpu_type, supported_cpu_type_bitfield *)
    SI_FlashDev*   = BITS(008H); (* 1 word: same as FLASH_DEVINFO row in OTP *)
    SI_BootRandom* = BITS(010H); (* 4 words: random 128 bits *)
    SI_BootInfo*   = BITS(040H); (* 4 words: boot_info, boot_diagnostic, boot_param0, boot_param1 *)

    (* GetPartitionInfo flags *)
    (* whole PT *)
    PI_PartitionInfo*   = BITS(00001H);
    (* single partition *)
    PI_SinglePartition* = BITS(08000H);
    PI_PartLocAndFlags* = BITS(00010H);
    PI_PartID*          = BITS(00020H);
    PI_PartFamIDs*      = BITS(00040H);
    PI_PartName*        = BITS(00080H);

    (* error codes *)
    OK* = 0;
    Err_OK* = OK;
    Err* = -1;
    Err_NotPermitted* = -4;
    Err_InvalidArg* = -5;
    Err_InvalidAddr* = -10;
    Err_BadAlignment* = -11;
    Err_InvalidState* = -12;
    Err_BufferTooSmall* = -13;
    Err_Precond* = -14;
    Err_ModifiedData* = -15;
    Err_InvalidData* = -16;
    Err_NotFound* = -17;
    Err_UnsupportedMod* = -18;
    Err_LockRequired* = -19;

    (* boot types *)
    BT_Normal* = 0;
    BT_Bootsel* = 1;
    BT_RAMimage* = 2;
    BT_FlashUpdate* = 3;

    (* flag masks and values *)
    (* partition flags *)
    PF_LinkTypeBits*    = BITS(006H);
    PF_LinkTypeShift*   = 1;
    PF_LinkValueBits*   = BITS(078H);
    PF_LinkValueShift*  = 3;

    PF_LinkTypeOwner*   = 2;
    PF_LinkTypeA*       = 1;
    PF_LinkTypeNone*    = 0;

    PF_LocFirstSectorBits* = BITS(01FFFH);
    PF_LocLastSectorBits* = BITS(003FFE000H);
    PF_LocLastSectorShift* = 13;

    (* Non-secure functions *)
    NS_SecureCall* = 4;

    (* flash *)
    FlashSectorShift* = 12;
    FlashSectorSize* = LSL(1, FlashSectorShift);

    (* locks *)
    Lock_SHA256* = 0;
    Lock_FlashOp* = 1;
    Lock_OTP* = 2;
    Lock_Max* = Lock_OTP;

    Lock_Enable* = 7;

  TYPE
    LookupFunc = PROCEDURE(code, lookupFlag: INTEGER): INTEGER;
    SecDispatchProc* = PROCEDURE(p0, p1, p2, p3: INTEGER; procKey: INTEGER): INTEGER;

    BootInfo* = RECORD
      diagPartIndex*: INTEGER;
      bootType*: INTEGER;
      bootPart*: INTEGER;
      tbybUpdate*: INTEGER;
      bootDiag*: INTEGER;
      rebootPar0*: INTEGER;
      rebootPar1*: INTEGER
    END;

  (* basic info *)

  PROCEDURE* CheckMagic*(): BOOLEAN;
    VAR value: INTEGER;
  BEGIN
    SYSTEM.GET(MagicAddr, value);
    RETURN BFX(value, 23, 0) = Magic
  END CheckMagic;


  PROCEDURE* GetRevision*(VAR revision: INTEGER);
    VAR value: INTEGER;
  BEGIN
    SYSTEM.GET(MagicAddr, value);
    revision := BFX(value, 31, 24)
  END GetRevision;

  (* utility *)

  PROCEDURE* getLookupFunc(VAR func: LookupFunc);
    VAR lookupFuncAddr: INTEGER;
  BEGIN
    SYSTEM.GET(TableAddr, lookupFuncAddr);
    lookupFuncAddr := BFX(lookupFuncAddr, 31, 16);
    func := SYSTEM.VAL(LookupFunc, lookupFuncAddr - 1)
  END getLookupFunc;


  PROCEDURE* tableCode(c1, c2: CHAR): INTEGER;
    RETURN LSL(ORD(c2), 8) + ORD(c1)
  END tableCode;


  PROCEDURE* isNonSec(): BOOLEAN;
    CONST CPUID_NS = MCU.PPB_CPUID + MCU.PPB_NS_Offset;
    VAR val: INTEGER;
  BEGIN
    SYSTEM.GET(CPUID_NS, val)
    RETURN val = 0
  END isNonSec;

  (* raw API *)

  PROCEDURE GetFuncAddr*(c1, c2: CHAR; VAR addr: INTEGER);
    VAR lookupFunc: LookupFunc; flags: INTEGER;
  BEGIN
    getLookupFunc(lookupFunc);
    IF isNonSec() THEN
      flags := LookupFuncArmNonSec
    ELSE
      flags := LookupFuncArmSec
    END;
    addr := lookupFunc(tableCode(c1, c2), flags) - 1
  END GetFuncAddr;


  (* bootrom API *)

  PROCEDURE GetSysInfo*(VAR resBuf: ARRAY OF INTEGER; flags: SET; VAR res: INTEGER);
  (* S, NS *)
  (* res: numWords > 0, error < 0 *)
    TYPE GetSysInfoFunc = PROCEDURE(VAR ob: ARRAY OF INTEGER; f: SET): INTEGER;
    VAR getSysInfo: GetSysInfoFunc; funcAddr: INTEGER;
  BEGIN
    GetFuncAddr("G", "S", funcAddr);
    getSysInfo := SYSTEM.VAL(GetSysInfoFunc, funcAddr);
    res := getSysInfo(resBuf, flags)
  END GetSysInfo;


  PROCEDURE GetBpartition*(partNo: INTEGER; VAR b: INTEGER);
  (* b: partition nunber >=0, error < 0 *)
    TYPE GetBpartitionFunc = PROCEDURE(a: INTEGER): INTEGER;
    VAR getBpartition: GetBpartitionFunc; funcAddr: INTEGER;
  BEGIN
    GetFuncAddr("G", "B", funcAddr);
    getBpartition := SYSTEM.VAL(GetBpartitionFunc, funcAddr);
    b := getBpartition(partNo)
  END GetBpartition;


  PROCEDURE GetPartitionTableInfo*(VAR resBuf: ARRAY OF INTEGER; flags: SET; VAR res: INTEGER);
  (* res: numWords >= 0, error < 0 *)
    TYPE GetPartitionTableInfoFunc = PROCEDURE(VAR ob: ARRAY OF INTEGER; flags: SET) : INTEGER;
    VAR getPartitionTableInfo: GetPartitionTableInfoFunc; funcAddr: INTEGER;
  BEGIN
    GetFuncAddr("G", "P", funcAddr);
    getPartitionTableInfo := SYSTEM.VAL(GetPartitionTableInfoFunc, funcAddr);
    (* locking omitted here for now *)
    res := getPartitionTableInfo(resBuf, flags)
  END GetPartitionTableInfo;


  PROCEDURE SecureCall*(p0, p1, p2, p3: INTEGER; key: INTEGER): INTEGER;
  (* NS *)
    TYPE SecureCallFunc = PROCEDURE(p0, p1, p2, p3: INTEGER; key: INTEGER): INTEGER;
    VAR secureCall: SecureCallFunc; funcAddr: INTEGER;
  BEGIN
    GetFuncAddr("S", "C", funcAddr);
    secureCall := SYSTEM.VAL(SecureCallFunc, funcAddr);
    RETURN secureCall(p0, p1, p2, p3, key)
  END SecureCall;


  PROCEDURE SetCallback*(callbackKey: INTEGER; proc: SecDispatchProc; VAR res: INTEGER);
  (* S *)
  (* only callbackKey = 0 is supported *)
    TYPE SetCallbackFunc = PROCEDURE(key: INTEGER; proc: SecDispatchProc): INTEGER;
    VAR setCallback: SetCallbackFunc; funcAddr: INTEGER;
  BEGIN
    GetFuncAddr("R", "C", funcAddr);
    setCallback := SYSTEM.VAL(SetCallbackFunc, funcAddr);
    INCL(SYSTEM.VAL(SET, proc), 0);
    res := setCallback(callbackKey, proc)
  END SetCallback;


  PROCEDURE SetNonsecAPIperm*(apiNum, allowed: INTEGER; VAR res: INTEGER);
  (* S *)
    TYPE SetNonsecAPIpermFunc = PROCEDURE(apiNum: INTEGER; allowed: INTEGER): INTEGER;
    VAR setNonsecAPIperm: SetNonsecAPIpermFunc; funcAddr: INTEGER;
  BEGIN
    GetFuncAddr("S", "P", funcAddr);
    setNonsecAPIperm := SYSTEM.VAL(SetNonsecAPIpermFunc, funcAddr);
    res := setNonsecAPIperm(apiNum, allowed)
  END SetNonsecAPIperm;


  (* API derived *)

  PROCEDURE GetBootInfo*(VAR bootInfo: BootInfo; VAR res: INTEGER);
  (* S, NS *)
  (* res = OK or Err *)
    CONST BufSize = 5; (* 4 words of info *)
    VAR resBuf: ARRAY BufSize OF INTEGER; wordCnt: INTEGER;
  BEGIN
    res := Err;
    GetSysInfo(resBuf, SI_BootInfo, wordCnt);
    IF (wordCnt = BufSize) & (resBuf[0] = ORD(SI_BootInfo)) THEN
      bootInfo.diagPartIndex := ASR(LSL(BFX(resBuf[1], 7, 0), 24), 24); (* signed 8 bits *)
      bootInfo.bootType := BFX(resBuf[1], 15, 8);
      bootInfo.bootPart := ASR(LSL(BFX(resBuf[1], 23, 16), 24), 24); (* signed 8 bits *)
      bootInfo.tbybUpdate := BFX(resBuf[1], 31, 24);
      bootInfo.bootDiag := resBuf[2];
      bootInfo.rebootPar0 := resBuf[3];
      bootInfo.rebootPar1 := resBuf[4];
      res := OK
    END
  END GetBootInfo;

(*
  GetOwnedPartition works for this simple partition table
  without A/B partitions.
    +-------------+             +-------------+
    | partition 0 | is_owned_by | partition 1 |
    | A           |<------------|             |
    +-------------+             +-------------+
*)

  PROCEDURE* linkType(permAndFlags: INTEGER): INTEGER;
    RETURN LSR(ORD(BITS(permAndFlags) * PF_LinkTypeBits), PF_LinkTypeShift)
  END linkType;

  PROCEDURE* linkValue(permAndFlags: INTEGER): INTEGER;
    RETURN LSR(ORD(BITS(permAndFlags) * PF_LinkValueBits), PF_LinkValueShift)
  END linkValue;

  PROCEDURE GetOwnedPartition*(partNo: INTEGER; VAR ownedPartNum, res: INTEGER);
    CONST BufSize = (MaxPartitions * 2) + 1; (* max 16 partitions, plus 1 for the returned flags in resBuf[0] *)
    VAR
      resBuf: ARRAY BufSize OF INTEGER;
      permAndFlags, numPartitions, partitionIndex: INTEGER;
      ownerFound: BOOLEAN;
  BEGIN
    GetPartitionTableInfo(resBuf, PI_PartLocAndFlags, res);
    IF res > 0 THEN
      numPartitions := (res - 1) DIV 2;
      partitionIndex := 0; ownerFound := FALSE;
      WHILE ~ownerFound & (partitionIndex < numPartitions) DO
        permAndFlags := resBuf[(partitionIndex * 2) + 2];
        ownerFound := (linkType(permAndFlags) = PF_LinkTypeOwner) & (linkValue(permAndFlags) = partNo);
        INC(partitionIndex)
      END;
      IF ~ownerFound THEN
        res := Err_NotFound
      END
    END;
    IF res > 0 THEN
      ownedPartNum := partitionIndex - 1
    END
  END GetOwnedPartition;


  PROCEDURE firstSector(permAndLoc: INTEGER): INTEGER;
  (* don't LSR, since the shift value is 0 => interpreted as 32 by instruction *)
  (* arch man E2.1.97 *)
    RETURN ORD(BITS(permAndLoc) * PF_LocFirstSectorBits)
  END firstSector;

  PROCEDURE* lastSector(permAndLoc: INTEGER): INTEGER;
    RETURN LSR(ORD(BITS(permAndLoc) * PF_LocLastSectorBits), PF_LocLastSectorShift)
  END lastSector;

  PROCEDURE GetPartitionSectors*(partNo: INTEGER; VAR firstSect, lastSect, numSect, res: INTEGER);
    CONST BufSize = 2 + 1; (* 2 result words, plus 1 for the returned flags in resBuf[0] *)
    VAR
      resBuf: ARRAY BufSize OF INTEGER;
      permAndLoc: INTEGER;
      flags: SET;
  BEGIN
    flags := PI_SinglePartition + PI_PartLocAndFlags + BITS(LSL(partNo, 24));
    GetPartitionTableInfo(resBuf, flags, res);
    IF res = 3 THEN
      permAndLoc := resBuf[1];
      firstSect := firstSector(permAndLoc);
      lastSect := lastSector(permAndLoc);
      numSect := lastSect - firstSect + 1
    END
  END GetPartitionSectors;


  PROCEDURE init;
    VAR val: SET;
  BEGIN
    (* enable RCP *)
    SYSTEM.GET(MCU.PPB_CPACR, val);
    SYSTEM.PUT(MCU.PPB_CPACR, val + {14, 15})
  END init;

BEGIN
  init
END Bootrom.
