MODULE Secure;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Secure/Non-secure support
  --
  MCU: RP2350
  --
  Important: for NS GPIO pins and their pads, refer to error RP2350-E3.
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, PPB, Bootrom, QMI, Errors;

  CONST
    NS* = 0;
    PRIV* = 1;
    R* = 2;
    RW* = 3;

    (*TT_MRVALID = 16;*)
    TT_SRVALID = 17;
    TT_R       = 18;
    TT_RW      = 19;
    (*TT_NSR     = 20;*)
    (*TT_NSRW    = 21;*)
    TT_S       = 22;
    TT_IRVALID = 23;

    TT_SREGION = {8 .. 15};
    TT_IREGION = {24 .. 31};

    ASM_TTA_R07_R06 =  0E847F680H;
    ASM_TTAT_R07_R06 = 0E847F6C0H;

    FlashSectorSize = Bootrom.FlashSectorSize;


  PROCEDURE* StartNonSecProg*(imageAddr, vtorOffset: INTEGER);
    VAR val: INTEGER;
  BEGIN
    (* NS VTOR *)
    SYSTEM.PUT(PPB.VTOR + PPB.PPB_NS_Offset, imageAddr + vtorOffset);
    (* NS stack pointer *)
    SYSTEM.GET(imageAddr + vtorOffset, val);
    (* asm
      val -> msr msp_ns, r11
    end asm *)
    (* +asm *)
    SYSTEM.LDREG(11, val);  (* val -> r11 *)
    SYSTEM.EMIT(0F38B8888H);  (* msr MSP_NS, r11 *)
    (* -asm *)
    (* branch to NS entry *)
    SYSTEM.GET(imageAddr  + vtorOffset + 04H, val);
    EXCL(SYSTEM.VAL(SET, val), 0);
    (* asm
      val -> blxns r11
    end asm *)
    (* +asm *)
    SYSTEM.LDREG(11, val);  (* val -> r11 *)
    SYSTEM.EMITH(047DCH);  (* blxns r11 *)
    (* -asm *)
  END StartNonSecProg;


  PROCEDURE InstallNonSecImage*(codeBaseAddr: INTEGER);
  (* install the NS image located in the first partition owned by the Secure program *)
  (* using QMI address translation *)
  (* codeBaseAddr: linker base address *)
    CONST FirstOwnedPart = 0;
    VAR
      bi: Bootrom.BootInfo; res, firstSect, lastSect, numSec: INTEGER;
      ownedParts: ARRAY 2 OF INTEGER;
  BEGIN
    Bootrom.GetBootInfo(bi, res);
    ASSERT(res >= 0, Errors.BootromError);
    Bootrom.GetOwnedPartitions(bi.bootPart, ownedParts, res);
    ASSERT(res >= 0, Errors.BootromError);
    Bootrom.GetPartitionSectors(ownedParts[FirstOwnedPart], firstSect, lastSect, numSec, res);
    ASSERT(res >= 0, Errors.BootromError);
    QMI.SetAddrTranslation(codeBaseAddr, firstSect * FlashSectorSize, numSec * FlashSectorSize)
  END InstallNonSecImage;


  PROCEDURE* NSisPrivileged*(): BOOLEAN;
    CONST Npriv = 0;
    VAR ctrl: INTEGER;
  BEGIN
    (* asm
      mrs r7, control_ns -> ctrl
    end asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8794H);  (* mrs r7, CONTROL_NS *)
    ctrl := SYSTEM.REG(7);  (* r7 -> ctrl *)
    (* -asm *)
    RETURN ~(Npriv IN BITS(ctrl))
  END NSisPrivileged;


  PROCEDURE* getTTresp(addr: INTEGER; priv: BOOLEAN; VAR ttresp: SET);
  BEGIN
    SYSTEM.LDREG(10, addr);
    IF priv THEN
      SYSTEM.EMIT(ASM_TTA_R07_R06); (* tta r7, r6 *)
    ELSE
      SYSTEM.EMIT(ASM_TTAT_R07_R06); (* ttat r7, r6 *)
    END;
    ttresp := BITS(SYSTEM.REG(11))
  END getTTresp;


  PROCEDURE CheckMem*(addr, size: INTEGER; checks: SET): BOOLEAN;
    CONST
      Mask0 = {TT_SRVALID, TT_S, TT_IRVALID}; Mask0r = {TT_SRVALID, TT_IRVALID};
      Mask1 = TT_SREGION + TT_IREGION;
    VAR ttr0, ttr1: SET; priv, res0, res1, res2: BOOLEAN;
  BEGIN
    priv := PRIV IN checks;
    getTTresp(addr, priv, ttr0);
    getTTresp(addr + size - 1, priv, ttr1);
    res0 := TRUE; res1 := TRUE; res2 := TRUE;
    IF NS IN checks THEN
      res0 := (ttr0 * Mask0 = Mask0r) & (ttr1 * Mask0 = Mask0r);
      res0 := res0 & ((ttr0 * Mask1) = (ttr1 * Mask1))
    END;
    IF RW IN checks THEN
      res1 := (TT_RW IN ttr0) & (TT_RW IN ttr1)
    END;
    IF R IN checks THEN
      res2 := (TT_R IN ttr0) & (TT_R IN ttr1)
    END
    RETURN res0 & res1 & res2
  END CheckMem;


  PROCEDURE CheckProc*(addr: INTEGER; checks: SET): BOOLEAN;
    VAR ttr: SET; priv, res0, res1: BOOLEAN;
  BEGIN
    priv := PRIV IN checks;
    getTTresp(addr, priv, ttr);
    res0 := TRUE; res1 := TRUE;
    IF NS IN checks THEN
      res0 := ~(TT_S IN ttr)
    END;
    IF R IN checks THEN
      res1 := TT_R IN ttr
    END
    RETURN res0 & res1
  END CheckProc;

END Secure.
