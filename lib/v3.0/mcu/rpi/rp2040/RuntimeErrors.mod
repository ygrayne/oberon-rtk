MODULE RuntimeErrors;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  Exception handling: run-time errors and faults
  Multi-core
  --
  * Error: run-time errors, including ASSERT, triggered by SVC calls in software
  * Fault: hardware faults, triggered by MCU hardware
  --
  MCU: RP2040
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, LED, Config;

  CONST
    NumCores* = Config.NumCoresUsed;
    TraceDepth* = 16;

    (* register offsets from stacked r0 *)
    PCoffset = 24;

    (* register numbers *)
    SP = 13;

    (* EXC_RETURN bits *)
    EXC_RET_Mode  = 3;  (* = 1: thread mode, faulty code was running in thread mode *)
    EXC_RET_SPSEL = 2;  (* = 1: PSP used for stacking *)

    (* MCU.PPB_ICSR bits *)
    PENDSVSET = 28;


  TYPE
    (* data collected for an error/fault *)
    ErrorDesc* = RECORD
      core*: BYTE;       (* MCU core *)
      errCode*: BYTE;    (* error or fault code *)
      errType*: BYTE;    (* type of error: error or fault, handler or thread mode *)
      errAddr*: INTEGER; (* error/fault code address *)
      errLineNo*: INTEGER;      (* error source code line no, if available, else zero *)
      stackframeBase*: INTEGER; (* address of exception frame stack *)
      excRetVal*: INTEGER;      (* EXC_RETURN of exception *)
      xpsr*: INTEGER
    END;


  VAR
    ErrorRec*: ARRAY NumCores OF ErrorDesc;


  PROCEDURE excHandler[0];
    CONST FaultCodeBase = 2; R11 = 11;
    VAR
      cid, excNo, stackframeBase, excRetAddr, excRetVal, retAddr: INTEGER;
      b0, b1: BYTE; icsr: SET;
      er: ErrorDesc;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    excRetAddr := SYSTEM.REG(SP) + 56; (* addr of EXC_RETURN value on stack *)
    SYSTEM.GET(excRetAddr, excRetVal);
    IF EXC_RET_SPSEL IN BITS(excRetVal) THEN (* PSP used for stacking *)
      SYSTEM.EMIT(MCU.MRS_R11_PSP);
      stackframeBase := SYSTEM.REG(R11)
    ELSE (* MSP used *)
      stackframeBase := excRetAddr + 4;
    END;
    SYSTEM.GET(stackframeBase + PCoffset, retAddr);
    SYSTEM.EMIT(MCU.MRS_R11_XPSR);
    er.xpsr := SYSTEM.REG(R11);
    er.core := cid;
    er.excRetVal := excRetVal;
    er.errAddr := retAddr;
    er.stackframeBase := stackframeBase;

    SYSTEM.EMIT(MCU.MRS_R11_IPSR);
    excNo := SYSTEM.REG(R11);
    IF excNo = MCU.EXC_SVC THEN (* SVC exception *)
      (* get source line number *)
      SYSTEM.GET(retAddr + 1, b1);
      SYSTEM.GET(retAddr, b0);
      er.errLineNo := LSL(b1, 8) + b0;
      (* get imm svc value = error code *)
      SYSTEM.GET(retAddr - 2, er.errCode); (* svc instr is two bytes, imm value is lower byte *)
      (* type: 0 = error in handler mode, 1 = error in thread mode *)
      er.errType := BFX(excRetVal, EXC_RET_Mode);
    ELSE (* all others *)
      er.errLineNo := 0;
      er.errCode := excNo;
      (* type: 2 = fault in handler mode, 3 = fault in thread mode *)
      er.errType := FaultCodeBase + BFX(excRetVal, EXC_RET_Mode);
    END;
    ErrorRec[cid] := er;

    (* set PendSV pending to trigger error handler *)
    SYSTEM.GET(MCU.PPB_ICSR, icsr);
    icsr := icsr + {PENDSVSET};
    SYSTEM.PUT(MCU.PPB_ICSR, icsr);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);
    (*SYSTEM.PUT(LEDext.LSET, {LEDext.LED4})*)
  END excHandler;


  PROCEDURE* errorHandler[0];
    (* default handler: simply blink LED *)
    VAR cid, cnt, i: INTEGER; er: ErrorDesc;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    er := ErrorRec[cid];
    IF er.errType IN {0, 1} THEN
      cnt := 1000000
    ELSE
      cnt := 5000000
    END;
    REPEAT
      SYSTEM.PUT(LED.LXOR, {LED.Pico});
      i := 0;
      WHILE i < cnt DO INC(i) END
    UNTIL FALSE
  END errorHandler;


  PROCEDURE* install(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END install;


  PROCEDURE InstallErrorHandler*(cid: INTEGER; eh: PROCEDURE);
    VAR vectorTableBase: INTEGER;
  BEGIN
    vectorTableBase := Config.DataMem[cid].start;
    install(vectorTableBase + MCU.EXC_PendSV_Offset, eh);
  END InstallErrorHandler;


  PROCEDURE Init*;
    VAR cid, addr, vectorTableBase, vectorTableTop: INTEGER;
  BEGIN
    cid := 0;
    WHILE cid < NumCores DO
      (* initialise vector tables for each used core *)
      (* install exception handlers for all errors and faults as implemented in the MCU *)
      vectorTableBase := Config.DataMem[cid].start;
      vectorTableTop := vectorTableBase + MCU.VectorTableSize;
      install(vectorTableBase + MCU.EXC_NMI_Offset, excHandler);
      install(vectorTableBase + MCU.EXC_HardFault_Offset, excHandler);
      install(vectorTableBase + MCU.EXC_SVC_Offset, excHandler);
      (* install default error handler *)
      install(vectorTableBase + MCU.EXC_PendSV_Offset, errorHandler);
      (* install error exception handler across the rest of the vector table *)
      (* will catch any exception with a missing handler *)
      addr := vectorTableBase + MCU.EXC_SysTick_Offset;
      WHILE addr < vectorTableTop DO
        install(addr, excHandler); INC(addr, 4)
      END;
      (* todo: set error handler prio, must be called from corresponding core *
      addr := SHPR0 + (MCU.PPB_PendSV_Exc DIV 4) * 4;
      SYSTEM.GET(addr, x);
      x := x + LSL(MCU.PPB_ExcPrio2, (MCU.PPB_PendSV_Exc MOD 4) * 8);
      SYSTEM.PUT(addr, x);
      *)
      INC(cid)
    END
  END Init;

END RuntimeErrors.
