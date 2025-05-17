MODULE Recovery;
(**
  Oberon RTK Framework v2.1
  --
  Recovery from runtime errors.
  --
  MCU: RP2040, RP2350
  --
  Notes:
  * Uses register r12 to hold current's thread id, set in Coroutines.
  * Uses watchdog scratch register 0 to hold restart data across resets.
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, RuntimeErrors, Watchdog, LEDext;

  CONST
    (* restart scratch register *)
    RestartScratchRegAddr = MCU.WATCHDOG_SCRATCH0;
    SpinLock = MCU.SIO_SPINLOCK0 + (31 * MCU.SIO_SPINLOCK_Offset);

    (* restart codes *)
    RstCold* = 0;
    RstWatchdogTimer* = 2;
    RstRuntimeError* = 3;

    (* bit ranges in restart scratch register *)
    WdReload1 = 31; (* watchdog reload flags from core 1 *)
    WdReload0 = 30;
    RstCnt1 = 22;   (* restart counter *)
    RstCnt0 = 19;
    RstCode1 = 18;  (* restart code *)
    RstCode0 = 16;
    RstCid0 = 15;   (* id of core where error occurred *)
    (* below: only valid if RstCode = RstRuntimeError *)
    ErrCode1 = 14;  (* error code as per RuntimeErrors *)
    ErrCode0 = 7;
    ErrType1 = 6;   (* error type as per RuntimeErrors *)
    ErrType0 = 5;
    ErrTid1 = 4;    (* id of current thread at error point *)
    ErrTid0 = 0;

    Core0 = 0;
    Core1 = 1;

  TYPE
    RestartDesc* = RECORD
      rstCnt*, rstCode*, rstCid*: INTEGER;
      errCode*, errType*, errTid*: INTEGER
    END;

  VAR
    Initialised*: BOOLEAN; (* program can check is this module is used *)
    RestartRec*: RestartDesc;

  (* core 1 watchdog *)

  PROCEDURE WatchdogReload*; (* run on core 1 *)
  BEGIN
    SYSTEM.PUT(RestartScratchRegAddr + MCU.ASET, {WdReload0, WdReload1})
  END WatchdogReload;


  PROCEDURE CheckWatchdogReload*(VAR wdFail: BOOLEAN);  (* run on core 0 *)
    VAR wdFlags: SET;
  BEGIN
    SYSTEM.GET(RestartScratchRegAddr, wdFlags);
    wdFlags := wdFlags * {WdReload0, WdReload1};
    wdFail := wdFlags = {};
    IF WdReload1 IN wdFlags THEN
      SYSTEM.PUT(RestartScratchRegAddr + MCU.ACLR, {WdReload1})
    ELSE
      SYSTEM.PUT(RestartScratchRegAddr + MCU.ACLR, {WdReload0})
    END
  END CheckWatchdogReload;


  PROCEDURE SetRestartCode*(code, cid: INTEGER);
    VAR scrRestart: INTEGER;
  BEGIN
    SYSTEM.GET(RestartScratchRegAddr, scrRestart);
    BFI(scrRestart, RstCode1, RstCode0, code);
    BFI(scrRestart, RstCid0, cid);
    SYSTEM.PUT(RestartScratchRegAddr, scrRestart)
  END SetRestartCode;


  PROCEDURE WatchdogFail*;  (* run on core 0 *)
  BEGIN
    SetRestartCode(RstWatchdogTimer, Core1);
    Watchdog.Trigger
  END WatchdogFail;


  (* PendSV error handler for RuntimeErrors *)

  PROCEDURE errorHandler[0];
    CONST R12 = 12;
    VAR cid, sl, scrRestart: INTEGER;
  BEGIN
    REPEAT
      SYSTEM.GET(SpinLock, sl)
    UNTIL sl # 0;
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    SYSTEM.PUT(LEDext.LSET, {LEDext.LED[cid + 6]});
    SYSTEM.GET(RestartScratchRegAddr, scrRestart);
    BFI(scrRestart, ErrCode1, ErrCode0, ORD(RuntimeErrors.ErrorRec[cid].errCode));
    BFI(scrRestart, ErrType1, ErrType0, ORD(RuntimeErrors.ErrorRec[cid].errType));
    BFI(scrRestart, ErrTid1, ErrTid0, SYSTEM.REG(R12));
    BFI(scrRestart, RstCid0, cid);
    BFI(scrRestart, RstCode1, RstCode0, RstRuntimeError);
    SYSTEM.PUT(RestartScratchRegAddr, scrRestart);
    (* note: same watchdog reset settings as set for watchdog timeout *)
    (* could be set to any config here, though *)
    Watchdog.Trigger;
    REPEAT UNTIL FALSE
  END errorHandler;


  (* module installation *)

  PROCEDURE collectRestartMode;
  (* collect data from scratch register, to be used in program *)
    VAR scrRestart: INTEGER;
  BEGIN
    SYSTEM.GET(RestartScratchRegAddr, scrRestart);
    RestartRec.rstCnt := BFX(scrRestart, RstCnt1, RstCnt0);
    RestartRec.rstCode := BFX(scrRestart, RstCode1, RstCode0);
    RestartRec.rstCid := BFX(scrRestart, RstCid0);
    (* below: only valid if restart code = RestartRuntimeError *)
    RestartRec.errCode := BFX(scrRestart, ErrCode1, ErrCode0);
    RestartRec.errType := BFX(scrRestart, ErrType1, ErrType0);
    RestartRec.errTid := BFX(scrRestart, ErrTid1, ErrTid0)
  END collectRestartMode;


  PROCEDURE incRstCnt;
    VAR scrRestart, rstCnt: INTEGER;
  BEGIN
    SYSTEM.GET(RestartScratchRegAddr, scrRestart);
    rstCnt := BFX(scrRestart, RstCnt1, RstCnt0);
    INC(rstCnt);
    BFI(scrRestart, RstCnt1, RstCnt0, rstCnt);
    SYSTEM.PUT(RestartScratchRegAddr, scrRestart)
  END incRstCnt;


  PROCEDURE Install*;
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    RuntimeErrors.InstallErrorHandler(cid, errorHandler);
    IF cid = 0 THEN
      collectRestartMode;
      incRstCnt;
      (* preset, since watchdog does direct reset in hardware *)
      (* all other errors via exceptions must "correct" this *)
      SetRestartCode(RstWatchdogTimer, Core0)
    END;
    Initialised := TRUE
  END Install;

BEGIN
  Initialised := FALSE
END Recovery.
