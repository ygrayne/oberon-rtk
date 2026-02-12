MODULE Secure;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Basic Secure
  --
  Type: MCU
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Bootrom, QMI, Errors;

  CONST
    MaxSecProcs = 16;

    OK* = Bootrom.OK;
    Err_InvalidArg* = Bootrom.Err_InvalidArg;
    Err_BufferTooSmall* = Bootrom.Err_BufferTooSmall;

    FlashSectorSize = Bootrom.FlashSectorSize;

    UserProcKey = 0C0000000H;

    LED1 = 28;
    LED2 = 26;
    LED3 = 22;

  TYPE
    SecProc* = PROCEDURE(p0, p1, p2, p3: INTEGER): INTEGER;

    SecProcEntry = RECORD
      key: INTEGER;
      proc: SecProc
    END;

  VAR
    secProcs: ARRAY MaxSecProcs OF SecProcEntry;


  PROCEDURE* StartNonSecure*(imageAddr: INTEGER);
    CONST R11 = 11; SPoffset = 0100H; PCoffset = 0104H;
    VAR val: INTEGER;
  BEGIN
    (* VTOR *)
    SYSTEM.PUT(MCU.PPB_VTOR + MCU.PPB_NS_Offset, imageAddr);
    (* stack pointer *)
    SYSTEM.GET(imageAddr + SPoffset, val);
    SYSTEM.LDREG(R11, val);
    SYSTEM.EMIT(MCU.MSR_MSPns_R11);
    (* branch to NS entry *)
    SYSTEM.GET(imageAddr + PCoffset, val);
    EXCL(SYSTEM.VAL(SET, val), 0);
    SYSTEM.LDREG(R11, val);
    SYSTEM.EMITH(MCU.BLXNS_R11)
  END StartNonSecure;


  PROCEDURE InstallNonSecImage*(addr: INTEGER);
  (* Install the NS image in the partition owned by the Secure program *)
    VAR bi: Bootrom.BootInfo; res, nsPart, firstSect, lastSect, numSec: INTEGER;
  BEGIN
    Bootrom.GetBootInfo(bi, res);
    (*ASSERT(res >= 0, Errors.BootromError);*)
    Bootrom.GetOwnedPartition(bi.bootPart, nsPart, res);
    (*ASSERT(res >= 0, Errors.BootromError);*)
    Bootrom.GetPartitionSectors(nsPart, firstSect, lastSect, numSec, res);
    (*ASSERT(res >= 0, Errors.BootromError);*)
    QMI.SetAddrTranslation(addr, firstSect * FlashSectorSize, numSec * FlashSectorSize)
  END InstallNonSecImage;


  PROCEDURE AddSecProc*(proc: SecProc; procKey: INTEGER; VAR res: INTEGER);
    VAR i: INTEGER; slotFound: BOOLEAN;
  BEGIN
    res := OK;
    i := 0; slotFound := FALSE;
    WHILE ~slotFound & (i < MaxSecProcs) DO
      slotFound := secProcs[i].proc = NIL;
      IF slotFound THEN
        secProcs[i].key := UserProcKey + procKey;
        secProcs[i].proc := proc
      END;
      INC(i)
    END;
    IF ~slotFound THEN
      res := Err_BufferTooSmall
    END
  END AddSecProc;


  PROCEDURE* RemoveSecProc*(proc: SecProc);
    VAR i: INTEGER; procFound: BOOLEAN;
  BEGIN
    i := 0; procFound := FALSE;
    WHILE ~procFound & (i < MaxSecProcs) DO
      procFound := secProcs[i].proc = proc;
      IF procFound THEN
        secProcs[i].proc := NIL;
        secProcs[i].key := 0
      END
    END
  END RemoveSecProc;


  PROCEDURE Dispatch*(p0, p1, p2, p3: INTEGER; procKey: INTEGER): INTEGER;
  (* installed via Bootrom.SetCallback from S *)
  (* called via Bootrom.SecureCall from NS *)
    VAR isUserProc: BOOLEAN; i, res: INTEGER; proc: SecProc;
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {LED1});
    isUserProc := LSR(procKey, 30) = 3;
    IF isUserProc THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {LED2});
      proc := NIL;
      i := 0;
      WHILE (proc = NIL) & (i < MaxSecProcs) DO
        IF secProcs[i].key = procKey THEN
          proc := secProcs[i].proc
        END;
        INC(i)
      END;
    ELSE
      res := Err_InvalidArg (* error as per the ref manual *)
    END;
    IF proc # NIL THEN
      SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, {LED3});
      res := proc(p0, p1, p2, p3)
      (* if proc is not actually a function procedure, this will leave r0 with Secure data *)
    ELSE
      res := Err_InvalidArg (* error as per the ref manual *)
    END
    RETURN res
  END Dispatch;


  PROCEDURE InstallHandler*(handler: Bootrom.SecDispatchProc);
    CONST SecureCallbackKey = 0;
    VAR res: INTEGER;
  BEGIN
    Bootrom.SetCallback(SecureCallbackKey, handler, res);
    ASSERT(res >= 0, Errors.BootromError);
    Bootrom.SetNonsecAPIperm(Bootrom.NS_SecureCall, 1, res);
    ASSERT(res >= 0, Errors.BootromError)
  END InstallHandler;


  PROCEDURE init;
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < MaxSecProcs DO
      secProcs[i].proc := NIL;
      secProcs[i].key := 0;
      INC(i)
    END;
  END init;

BEGIN
  init
END Secure.
